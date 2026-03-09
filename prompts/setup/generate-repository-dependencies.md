# Generate Repository Dependencies Map

**Purpose:** Analyze all repositories in the workspace and generate `context/<project>-repository-dependencies.md` with actual service dependencies, shared databases, shared packages, and architecture diagram.

---

## When to Run

- After initial project setup (bootstrap + @setup agent)
- When new repositories are added to the workspace
- When service architecture changes (new APIs, new shared databases, new message queues)

---

## Input

No input required — the prompt analyzes all repositories found in the workspace.

**Optional input:** If the user provides repository names or a workspace file, use those instead of auto-detecting.

---

## Execution Steps

### Step 1: Identify All Repositories

Read the workspace file (`.code-workspace`) or scan the parent directory for git repositories. For each repository, record:
- Repository name
- Technology stack (detect from project files: `.csproj`, `package.json`, `pubspec.yaml`, `requirements.txt`, etc.)
- Purpose (infer from README, project structure, or directory name)

### Step 2: Analyze HTTP/API Dependencies

For each repository, search for outbound HTTP calls to other services:

```bash
# .NET / C# — search for HttpClient usage, service URLs, API client references
git grep -n "HttpClient\|BaseAddress\|ApiHost\|ServiceUrl" origin/main -- "*.cs" "*.json" "appsettings*.json"

# TypeScript / JavaScript — search for fetch, axios, API base URLs
git grep -n "fetch(\|axios\.\|baseURL\|apiUrl" origin/main -- "*.ts" "*.js" "*.json"

# Flutter / Dart — search for http package usage, API endpoints
git grep -n "http\.\|dio\.\|baseUrl\|apiEndpoint" origin/main -- "*.dart" "*.yaml"

# Python — search for requests, httpx, API URLs
git grep -n "requests\.\|httpx\.\|base_url\|api_url" origin/main -- "*.py" "*.cfg" "*.ini"
```

For each dependency found, record:
- Consumer (who calls)
- Provider (who is called)
- Protocol (REST, GraphQL, gRPC, message queue)
- What data is consumed
- Configuration key or URL pattern

### Step 3: Analyze Database Dependencies

Search for database connection strings, DbContext registrations, and database access patterns:

```bash
# .NET — connection strings, DbContext, database names
git grep -n "ConnectionString\|DbContext\|Database=" origin/main -- "*.cs" "*.json" "appsettings*.json"

# Check for shared database names across repos
git grep -n "Server=\|Data Source=\|Host=" origin/main -- "appsettings*.json" "*.config"
```

For each database dependency:
- Which repository accesses which database(s)
- Access type (Read/Write or Read-only)
- Whether the database is shared with other repositories

### Step 4: Analyze Shared Package Dependencies

```bash
# .NET — shared internal NuGet packages
git grep -n "PackageReference" origin/main -- "*.csproj" | grep -i "<project-name>\|shared\|common\|platform"

# Node.js — shared internal packages
git grep -n "\"@" origin/main -- "package.json" | grep -i "<org-name>"

# Dart — shared packages
git grep -n "path:\|git:" origin/main -- "pubspec.yaml"
```

### Step 5: Generate the Output File

Create `context/<project-lowercase>-repository-dependencies.md` following the structure of the demo file (`context/healthbridge-repository-dependencies.md`).

**Required sections:**
1. Repository Overview (table: #, Repository, Tech Stack, Purpose, Status)
2. Consumer / Provider: HTTP API Dependencies (table with Consumer, Provider, Protocol, What is Consumed, Integration Details)
3. Consumer / Provider: Shared Database Dependencies (table with Consumer, Database(s), Access Type, What is Read/Written)
4. Consumer / Provider: Shared Package Dependencies (table with Package Family, Version, Consumer Repositories)
5. Architecture Diagram (ASCII art showing service relationships)
6. Key Findings (narrative analysis of architectural patterns, hotspots, isolation)
7. Team Ownership (table — leave blank if unknown, user fills in later)
8. QA Impact section (how dependencies affect code review and testing)

**Mark uncertain findings:** If a dependency is inferred but not confirmed, prefix with `[VERIFY]`.

---

## Output

```
context/<project-lowercase>-repository-dependencies.md
```

---

## Quality Checks

After generating:
- Every repository from the workspace should appear in the Repository Overview
- Every HTTP dependency should have both Consumer and Provider identified
- Shared databases should be flagged as high-impact change areas
- The architecture diagram should be consistent with the dependency tables
- No placeholder values — use `[VERIFY]` for uncertain items, actual data for confirmed items
