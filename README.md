# devops-toolkit

A modular GitHub App for DevOps automation — deployed as a serverless function on **Vercel** (free).

## Features

### `/cherry-pick <target-branch>`

Comment `/cherry-pick <target-branch>` on a **merged** pull request to:

1. Create a branch `cherry-pick/pr-<number>-to-<target>` from the target branch
2. Apply the PR's changes onto that branch
3. Post a link to open a cherry-pick PR against the target branch

If there are merge conflicts, the bot will create the branch and provide manual cherry-pick instructions.

## Deploy to Vercel

### 1. Create the GitHub App

1. Go to [github.com/settings/apps/new](https://github.com/settings/apps/new)
2. Fill in:
   - **App name**: `devops-toolkit` (pick a unique name)
   - **Homepage URL**: your repo URL
   - **Webhook URL**: `https://your-vercel-app.vercel.app/api/github/webhooks` (update after deploy)
   - **Webhook secret**: run `openssl rand -hex 20` and save the value
3. **Permissions** → Repository permissions:
   - **Contents**: Read & Write
   - **Issues**: Read & Write
   - **Pull requests**: Read & Write
4. **Subscribe to events**: check **Issue comment**
5. Click **Create GitHub App** — note the **App ID**
6. Scroll to **Private keys** → **Generate a private key** (downloads a `.pem`)

### 2. Deploy to Vercel

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/praveendhra/devops-toolkit)

Or manually:

```bash
npm i -g vercel
vercel
```

### 3. Set environment variables in Vercel

Go to your Vercel project → **Settings → Environment Variables** and add:

| Variable | Value |
|---|---|
| `APP_ID` | Your GitHub App ID |
| `WEBHOOK_SECRET` | The secret you generated |
| `PRIVATE_KEY` | Contents of the `.pem` file (paste the full key including `-----BEGIN...`) |

Then redeploy: `vercel --prod`

### 4. Update the webhook URL

Go back to your GitHub App settings and set **Webhook URL** to:

```
https://your-vercel-app.vercel.app/api/github/webhooks
```

### 5. Install the app

Go to `https://github.com/settings/apps/YOUR-APP-NAME/installations` → **Install** → select your repos.

## Usage

1. Merge a pull request
2. Comment on the merged PR: `/cherry-pick release-1.0`
3. The bot reacts with 👀, creates the branch, and posts a link to create the cherry-pick PR

## Project Structure

```
api/
└── github/
    └── webhooks.ts           # Vercel serverless entry point
src/
├── index.ts                  # Standalone server entry point
├── app.ts                    # Probot app — registers event handlers
├── commands/
│   ├── types.ts              # Command & CommandContext interfaces
│   ├── registry.ts           # CommandRegistry — maps names to handlers
│   ├── cherry-pick.ts        # /cherry-pick command implementation
│   └── index.ts              # Wires commands into the registry
├── handlers/
│   └── issue-comment.ts      # issue_comment.created webhook handler
├── services/
│   └── github.ts             # GitHub API wrappers
└── utils/
    └── command-parser.ts     # Parses /slash commands
```

### Adding a new command

1. Create `src/commands/my-command.ts` implementing the `Command` interface
2. Register it in `src/commands/index.ts`

The handler infrastructure picks it up automatically.