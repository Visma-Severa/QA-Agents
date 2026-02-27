import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';
import { exec } from 'child_process';
import { promisify } from 'util';
import { syncAllRepos, SyncReport } from './repo-sync';

const execAsync = promisify(exec);

interface AgentConfig {
    id: string;
    name: string;
    promptFile: string;
}

const AGENTS: AgentConfig[] = [
    {
        id: 'hb-qa-acceptance-tests',
        name: 'Acceptance Tests',
        promptFile: 'qa-acceptance-tests.md'
    },
    {
        id: 'hb-qa-code-review',
        name: 'Code Review',
        promptFile: 'qa-code-review.md'
    },
    {
        id: 'hb-qa-bug-report',
        name: 'Bug Report',
        promptFile: 'qa-bug-report.md'
    },
    {
        id: 'hb-bugfix-rca',
        name: 'Bugfix RCA',
        promptFile: 'bugfix-rca.md'
    },
    {
        id: 'hb-requirements-analysis',
        name: 'Requirements Analysis',
        promptFile: 'requirements-analysis.md'
    },
    {
        id: 'hb-release-analysis',
        name: 'Release Analysis',
        promptFile: 'release-analysis.md'
    },
    {
        id: 'hb-qa-feedback',
        name: 'QA Feedback',
        promptFile: 'qa-feedback.md'
    }
];

const SYNC_COOLDOWN_MS = 5 * 60 * 1000; // 5 minutes
const MAX_TOOL_ROUNDS = 30;

// --- Tools available to the LLM ---
const LLM_TOOLS: vscode.LanguageModelChatTool[] = [
    {
        name: 'runTerminal',
        description: 'Execute a shell command and return stdout/stderr. Use for git commands, listing files, etc.',
        inputSchema: {
            type: 'object',
            properties: {
                command: {
                    type: 'string',
                    description: 'The shell command to execute'
                },
                cwd: {
                    type: 'string',
                    description: 'Working directory (relative to workspace root or absolute). Optional.'
                }
            },
            required: ['command']
        }
    },
    {
        name: 'readFile',
        description: 'Read the contents of a file and return it as text.',
        inputSchema: {
            type: 'object',
            properties: {
                filePath: {
                    type: 'string',
                    description: 'Absolute path or workspace-relative path to the file'
                }
            },
            required: ['filePath']
        }
    },
    {
        name: 'searchFiles',
        description: 'Search for a text pattern across files using grep. Returns matching lines with file paths and line numbers.',
        inputSchema: {
            type: 'object',
            properties: {
                pattern: {
                    type: 'string',
                    description: 'The text or regex pattern to search for'
                },
                directory: {
                    type: 'string',
                    description: 'Directory to search in (relative to workspace root or absolute). Optional, defaults to workspace root.'
                },
                fileGlob: {
                    type: 'string',
                    description: 'File glob pattern to filter, e.g. "*.cs", "*.vb". Optional.'
                }
            },
            required: ['pattern']
        }
    }
];

/**
 * Search all workspace folders for the agent instruction file.
 */
function findAgentFile(promptFile: string): string | undefined {
    const folders = vscode.workspace.workspaceFolders;
    if (!folders) { return undefined; }

    const relativePath = path.join('agents', 'vscode-chat-participants', promptFile);

    for (const folder of folders) {
        const directPath = path.join(folder.uri.fsPath, relativePath);
        if (fs.existsSync(directPath)) {
            return directPath;
        }

        const subfolderPath = path.join(folder.uri.fsPath, 'DEMO-QA-Agents', relativePath);
        if (fs.existsSync(subfolderPath)) {
            return subfolderPath;
        }
    }
    return undefined;
}

/**
 * Find the root directory containing all repositories.
 */
function findRepoRoot(): string | undefined {
    const folders = vscode.workspace.workspaceFolders;
    if (!folders) { return undefined; }

    for (const folder of folders) {
        // Single-folder workspace: the folder itself contains repos
        if (fs.existsSync(path.join(folder.uri.fsPath, 'HealthBridge-Web'))) {
            return folder.uri.fsPath;
        }
        // Multi-root workspace: parent of any folder contains repos
        const parent = path.dirname(folder.uri.fsPath);
        if (fs.existsSync(path.join(parent, 'HealthBridge-Web'))) {
            return parent;
        }
    }
    return undefined;
}

/**
 * Execute a tool call from the LLM and return the result string.
 */
async function executeTool(name: string, input: Record<string, string>, workspaceRoot: string): Promise<string> {
    switch (name) {
        case 'runTerminal': {
            const cwd = input.cwd
                ? path.isAbsolute(input.cwd) ? input.cwd : path.resolve(workspaceRoot, input.cwd)
                : workspaceRoot;
            try {
                const { stdout, stderr } = await execAsync(input.command, {
                    cwd,
                    timeout: 60000,
                    maxBuffer: 2 * 1024 * 1024
                });
                let result = stdout || '';
                if (stderr) { result += `\nSTDERR: ${stderr}`; }
                return result || '(no output)';
            } catch (err: any) {
                return `Exit code ${err.code ?? 'unknown'}\n${err.stdout || ''}${err.stderr ? '\nSTDERR: ' + err.stderr : ''}\n${err.message}`;
            }
        }
        case 'readFile': {
            const filePath = path.isAbsolute(input.filePath)
                ? input.filePath
                : path.resolve(workspaceRoot, input.filePath);
            try {
                const content = fs.readFileSync(filePath, 'utf-8');
                // Truncate very large files
                if (content.length > 100000) {
                    return content.substring(0, 100000) + '\n\n... (truncated, file too large)';
                }
                return content;
            } catch (err: any) {
                return `Error reading file: ${err.message}`;
            }
        }
        case 'searchFiles': {
            const dir = input.directory
                ? (path.isAbsolute(input.directory) ? input.directory : path.resolve(workspaceRoot, input.directory))
                : workspaceRoot;
            const globArg = input.fileGlob ? `--include="${input.fileGlob}"` : '';
            const cmd = `grep -rn ${globArg} --max-count=100 -- ${JSON.stringify(input.pattern)} ${JSON.stringify(dir)}`;
            try {
                const { stdout } = await execAsync(cmd, { timeout: 30000, maxBuffer: 2 * 1024 * 1024 });
                return stdout || '(no matches found)';
            } catch (err: any) {
                if (err.code === 1) { return '(no matches found)'; }
                return `Search error: ${err.message}`;
            }
        }
        default:
            return `Unknown tool: ${name}`;
    }
}

export function activate(context: vscode.ExtensionContext) {
    console.log('HealthBridge QA Agents extension is now active');

    // --- Sync infrastructure ---
    const outputChannel = vscode.window.createOutputChannel('HealthBridge QA Sync');
    let lastSyncReport: SyncReport | null = null;
    let syncInProgress: Promise<SyncReport> | null = null;

    function getWorkspaceRoot(): string | undefined {
        const folders = vscode.workspace.workspaceFolders;
        if (!folders || folders.length === 0) { return undefined; }
        return path.dirname(folders[0].uri.fsPath);
    }

    function runSync(): Promise<SyncReport> {
        const workspaceRoot = getWorkspaceRoot();
        if (!workspaceRoot) {
            return Promise.reject(new Error('Could not determine workspace root'));
        }
        outputChannel.appendLine(`[${new Date().toISOString()}] Starting sync...`);
        return syncAllRepos(workspaceRoot, (msg) => outputChannel.appendLine(msg));
    }

    function ensureSync(): Promise<SyncReport> {
        if (syncInProgress) { return syncInProgress; }
        syncInProgress = runSync().finally(() => { syncInProgress = null; });
        return syncInProgress;
    }

    function formatSyncNotification(report: SyncReport): string {
        const pulled = report.results.filter(r => r.outcome === 'pulled');
        const skipped = report.results.filter(r =>
            r.outcome === 'skipped-dirty' ||
            r.outcome === 'skipped-wrong-branch' ||
            r.outcome === 'error'
        );

        const parts: string[] = [];
        if (pulled.length > 0) {
            parts.push(`Synced: ${pulled.map(r => r.repo.displayName).join(', ')}`);
        }
        if (skipped.length > 0) {
            parts.push(`Skipped: ${skipped.map(r => `${r.repo.displayName} (${r.detail})`).join(', ')}`);
        }
        return parts.join(' | ') || 'All repos up to date';
    }

    // --- Register manual sync command ---
    const syncCommand = vscode.commands.registerCommand('hb-qa-agents.syncRepos', async () => {
        await vscode.window.withProgress(
            {
                location: vscode.ProgressLocation.Notification,
                title: 'HealthBridge QA: Syncing repositories...',
                cancellable: false,
            },
            async () => {
                try {
                    const report = await runSync();
                    lastSyncReport = report;
                    const message = formatSyncNotification(report);
                    const hasSkipped = report.results.some(r =>
                        r.outcome === 'skipped-dirty' ||
                        r.outcome === 'skipped-wrong-branch' ||
                        r.outcome === 'error'
                    );
                    if (hasSkipped) {
                        vscode.window.showWarningMessage(`HealthBridge Sync: ${message}`);
                    } else {
                        vscode.window.showInformationMessage(`HealthBridge Sync: ${message}`);
                    }
                } catch (err) {
                    vscode.window.showErrorMessage(
                        `HealthBridge Sync failed: ${err instanceof Error ? err.message : String(err)}`
                    );
                }
            }
        );
    });
    context.subscriptions.push(syncCommand);

    // --- Register each agent as a chat participant ---
    for (const agent of AGENTS) {
        const participant = vscode.chat.createChatParticipant(agent.id, async (request, _context, stream, token) => {
            try {
                // --- Pre-agent sync (with cooldown) ---
                const now = Date.now();
                const lastSyncTime = lastSyncReport?.timestamp.getTime() ?? 0;

                if (now - lastSyncTime > SYNC_COOLDOWN_MS) {
                    stream.markdown('*Syncing repositories...*\n\n');
                    try {
                        const report = await ensureSync();
                        lastSyncReport = report;

                        const pulled = report.results.filter(r => r.outcome === 'pulled');
                        const skipped = report.results.filter(r =>
                            r.outcome === 'skipped-dirty' ||
                            r.outcome === 'skipped-wrong-branch' ||
                            r.outcome === 'error'
                        );

                        if (pulled.length > 0) {
                            stream.markdown(`Updated: ${pulled.map(r => r.repo.displayName).join(', ')}\n\n`);
                        }
                        if (skipped.length > 0) {
                            for (const s of skipped) {
                                stream.markdown(`> **${s.repo.displayName}**: ${s.detail}\n`);
                            }
                            stream.markdown('\n');
                        }
                    } catch (err) {
                        stream.markdown(`> ⚠️ Sync warning: ${err instanceof Error ? err.message : String(err)}\n\n`);
                    }
                }

                // --- Find agent instruction file ---
                const agentFilePath = findAgentFile(agent.promptFile);
                if (!agentFilePath) {
                    const folders = vscode.workspace.workspaceFolders;
                    const folderList = folders
                        ? folders.map(f => `- \`${f.uri.fsPath}\``).join('\n')
                        : '(no workspace folders found)';
                    stream.markdown(`❌ Agent instruction file not found: ${agent.promptFile}\n\n`);
                    stream.markdown(`**Workspace folders searched:**\n${folderList}\n\n`);
                    stream.markdown('Make sure the **DEMO-QA-Agents** folder is in your workspace.');
                    return;
                }

                const workspaceRoot = findRepoRoot() || path.dirname(agentFilePath);
                const agentInstructions = fs.readFileSync(agentFilePath, 'utf-8');

                stream.markdown(`🤖 **${agent.name} Agent Activated**\n\n`);
                stream.markdown(`Analyzing your request: "${request.prompt}"\n\n`);

                // request.model may be "Auto" which doesn't have a valid sendRequest endpoint
                let model: vscode.LanguageModelChat = request.model;
                const modelId = (model.id || '').toLowerCase();
                const modelName = (model.name || '').toLowerCase();
                if (modelId === 'auto' || modelId.includes('auto') || modelName === 'auto' || modelName.includes('auto')) {
                    const availableModels = await vscode.lm.selectChatModels();
                    if (availableModels.length === 0) {
                        stream.markdown('❌ No language models available. Please select a specific model (e.g. GPT-4o or Claude) in the chat model dropdown instead of "Auto".');
                        return;
                    }
                    // Prefer Claude or GPT-4o for agentic tasks
                    model = availableModels.find(m =>
                        m.id.includes('claude') || m.id.includes('gpt-4o')
                    ) || availableModels[0];
                }
                stream.markdown(`*Using model: ${model.name}*\n\n`);

                // --- Tool-calling loop ---
                const messages: vscode.LanguageModelChatMessage[] = [
                    vscode.LanguageModelChatMessage.User(agentInstructions),
                    vscode.LanguageModelChatMessage.User(
                        `Workspace root: ${workspaceRoot}\n\n` +
                        `You have tools available: runTerminal, readFile, searchFiles. ` +
                        `Use them to execute commands and read files - do NOT output raw command text.\n\n` +
                        `User Request: ${request.prompt}`
                    )
                ];

                for (let round = 0; round < MAX_TOOL_ROUNDS; round++) {
                    if (token.isCancellationRequested) { break; }

                    const response = await model.sendRequest(messages, { tools: LLM_TOOLS }, token);

                    const textParts: string[] = [];
                    const toolCalls: vscode.LanguageModelToolCallPart[] = [];

                    for await (const chunk of response.stream) {
                        if (chunk instanceof vscode.LanguageModelTextPart) {
                            stream.markdown(chunk.value);
                            textParts.push(chunk.value);
                        } else if (chunk instanceof vscode.LanguageModelToolCallPart) {
                            toolCalls.push(chunk);
                        }
                    }

                    // No tool calls = model is done
                    if (toolCalls.length === 0) { break; }

                    // Build assistant message with text + tool calls
                    const assistantParts: (vscode.LanguageModelTextPart | vscode.LanguageModelToolCallPart)[] = [];
                    if (textParts.length > 0) {
                        assistantParts.push(new vscode.LanguageModelTextPart(textParts.join('')));
                    }
                    assistantParts.push(...toolCalls);
                    messages.push(vscode.LanguageModelChatMessage.Assistant(assistantParts));

                    // Execute tool calls and collect results
                    const resultParts: vscode.LanguageModelToolResultPart[] = [];
                    for (const call of toolCalls) {
                        stream.markdown(`\n> 🔧 *${call.name}*: \`${(call.input as any).command || (call.input as any).filePath || (call.input as any).pattern || ''}\`\n`);
                        const result = await executeTool(call.name, call.input as Record<string, string>, workspaceRoot);
                        resultParts.push(new vscode.LanguageModelToolResultPart(
                            call.callId,
                            [new vscode.LanguageModelTextPart(result)]
                        ));
                    }
                    messages.push(vscode.LanguageModelChatMessage.User(resultParts));
                }

            } catch (error) {
                stream.markdown(`\n\n❌ Error: ${error instanceof Error ? error.message : String(error)}`);
            }
        });

        participant.iconPath = vscode.Uri.file(
            path.join(context.extensionPath, 'icon.png')
        );

        context.subscriptions.push(participant);
    }

    vscode.window.showInformationMessage('✅ HealthBridge QA Agents loaded! Use @hb-qa-code-review, @hb-bugfix-rca, etc. in chat');
}

export function deactivate() {}
