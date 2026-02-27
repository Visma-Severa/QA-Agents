# Scripts

## update-all-repos.sh

Updates all critical repositories to their latest state. Run this regularly to ensure E2E tests, mobile app, and QA agents are up-to-date.

### Repositories Updated

| Repository | Branch | Purpose |
|------------|--------|---------|
| HealthBridge-Selenium-Tests | main | Selenium UI & integration tests |
| HealthBridge-E2E-Tests | main | Playwright E2E tests |
| HealthBridge-Mobile-Tests | main | Mobile automation tests |
| HealthBridge-Mobile | main | HealthBridge mobile app |
| DEMO-QA-Agents | main | QA agent prompts and configs |

### Usage

```bash
# Run from the scripts/ directory
./update-all-repos.sh

# Or from the QA Agents root
./scripts/update-all-repos.sh
```

### Safety Features

- **Stash detection**: Checks for uncommitted changes before pulling
- **Auto-stash**: Stashes changes with timestamped message if found
- **Branch switching**: Switches to correct branch if needed
- **Fetch first**: Always fetches before pulling

### Automating with Cron

```bash
# Run daily at 8 AM
0 8 * * * /path/to/DEMO-QA-Agents/scripts/update-all-repos.sh >> /tmp/repo-update.log 2>&1
```

### Troubleshooting

- **Permission denied**: Run `chmod +x scripts/update-all-repos.sh`
- **Stash conflicts**: Navigate to the repo and run `git stash pop`, resolve conflicts manually
- **Authentication errors**: Ensure SSH keys or Git credentials are configured
