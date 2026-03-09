"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.syncAllRepos = syncAllRepos;
const child_process_1 = require("child_process");
const util_1 = require("util");
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
const execFileAsync = (0, util_1.promisify)(child_process_1.execFile);
// --- Repo configuration (single source of truth) ---
const REPO_CONFIGS = [
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
async function execGit(args, cwd) {
    const { stdout } = await execFileAsync('git', args, {
        cwd,
        timeout: 30000,
        maxBuffer: 1024 * 1024,
    });
    return stdout.trim();
}
async function getCurrentBranch(repoPath) {
    return execGit(['rev-parse', '--abbrev-ref', 'HEAD'], repoPath);
}
async function isDirty(repoPath) {
    try {
        await execGit(['diff', '--quiet'], repoPath);
        await execGit(['diff', '--quiet', '--cached'], repoPath);
        return false;
    }
    catch {
        return true;
    }
}
// --- Main sync function ---
async function syncAllRepos(workspaceRoot, log) {
    const results = [];
    const logMsg = log ?? (() => { });
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
        }
        catch (err) {
            const message = err instanceof Error ? err.message : String(err);
            results.push({ repo, outcome: 'error', detail: message });
            logMsg(`[${repo.displayName}] Error: ${message}`);
        }
    }
    return { results, timestamp: new Date() };
}
//# sourceMappingURL=repo-sync.js.map