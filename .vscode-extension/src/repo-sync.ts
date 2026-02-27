import { execFile } from 'child_process';
import { promisify } from 'util';
import * as fs from 'fs';
import * as path from 'path';

const execFileAsync = promisify(execFile);

// --- Types ---

export interface RepoConfig {
    folder: string;
    defaultBranch: string;
    displayName: string;
}

export type SyncOutcome =
    | 'pulled'
    | 'skipped-dirty'
    | 'skipped-wrong-branch'
    | 'skipped-not-found'
    | 'error';

export interface SyncResult {
    repo: RepoConfig;
    outcome: SyncOutcome;
    detail: string;
}

export interface SyncReport {
    results: SyncResult[];
    timestamp: Date;
}

// --- Repo configuration (single source of truth) ---

const REPO_CONFIGS: RepoConfig[] = [
    { folder: 'HealthBridge-Web', defaultBranch: 'main', displayName: 'HealthBridge-Web' },
    { folder: 'HealthBridge-Portal', defaultBranch: 'main', displayName: 'HealthBridge-Portal' },
    { folder: 'HealthBridge-Api', defaultBranch: 'main', displayName: 'HealthBridge-Api' },
    { folder: 'HealthBridge-Mobile', defaultBranch: 'main', displayName: 'HealthBridge-Mobile' },
    { folder: 'HealthBridge-Claims-Processing', defaultBranch: 'main', displayName: 'Claims-Processing' },
    { folder: 'HealthBridge-Prescriptions-Api', defaultBranch: 'main', displayName: 'Prescriptions-Api' },
    { folder: 'HealthBridge-Selenium-Tests', defaultBranch: 'main', displayName: 'Selenium Tests' },
    { folder: 'HealthBridge-E2E-Tests', defaultBranch: 'main', displayName: 'E2E Tests' },
    { folder: 'HealthBridge-Mobile-Tests', defaultBranch: 'main', displayName: 'Mobile Tests' },
    { folder: 'DEMO-QA-Agents', defaultBranch: 'main', displayName: 'QA Agents' },
];

// --- Git helpers ---

async function execGit(args: string[], cwd: string): Promise<string> {
    const { stdout } = await execFileAsync('git', args, {
        cwd,
        timeout: 30000,
        maxBuffer: 1024 * 1024,
    });
    return stdout.trim();
}

async function getCurrentBranch(repoPath: string): Promise<string> {
    return execGit(['rev-parse', '--abbrev-ref', 'HEAD'], repoPath);
}

async function isDirty(repoPath: string): Promise<boolean> {
    try {
        await execGit(['diff', '--quiet'], repoPath);
        await execGit(['diff', '--quiet', '--cached'], repoPath);
        return false;
    } catch {
        return true;
    }
}

// --- Main sync function ---

export async function syncAllRepos(
    workspaceRoot: string,
    log?: (message: string) => void
): Promise<SyncReport> {
    const results: SyncResult[] = [];
    const logMsg = log ?? (() => {});

    for (const repo of REPO_CONFIGS) {
        const repoPath = path.join(workspaceRoot, repo.folder);

        // Safety gate 1: folder exists
        if (!fs.existsSync(repoPath)) {
            results.push({ repo, outcome: 'skipped-not-found', detail: 'Folder not found' });
            logMsg(`[${repo.displayName}] Skipped: folder not found`);
            continue;
        }

        try {
            // Safety gate 2: on default branch
            const branch = await getCurrentBranch(repoPath);
            if (branch !== repo.defaultBranch) {
                results.push({
                    repo,
                    outcome: 'skipped-wrong-branch',
                    detail: `On branch "${branch}" (expected "${repo.defaultBranch}")`,
                });
                logMsg(`[${repo.displayName}] Skipped: on branch "${branch}"`);
                continue;
            }

            // Safety gate 3: clean working tree
            if (await isDirty(repoPath)) {
                results.push({
                    repo,
                    outcome: 'skipped-dirty',
                    detail: 'Uncommitted changes detected',
                });
                logMsg(`[${repo.displayName}] Skipped: uncommitted changes`);
                continue;
            }

            // Safe to sync: fetch + fast-forward pull
            logMsg(`[${repo.displayName}] Fetching...`);
            await execGit(['fetch', 'origin'], repoPath);
            logMsg(`[${repo.displayName}] Pulling (ff-only)...`);
            await execGit(['pull', '--ff-only', 'origin', repo.defaultBranch], repoPath);

            results.push({ repo, outcome: 'pulled', detail: 'Updated successfully' });
            logMsg(`[${repo.displayName}] Updated`);
        } catch (err) {
            const message = err instanceof Error ? err.message : String(err);
            results.push({ repo, outcome: 'error', detail: message });
            logMsg(`[${repo.displayName}] Error: ${message}`);
        }
    }

    return { results, timestamp: new Date() };
}
