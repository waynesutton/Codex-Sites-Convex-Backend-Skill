# Convex Agent Mode

Read the current official page before provisioning: https://docs.convex.dev/cli/agent-mode.

## Select the correct mode

| Mode | Setup | Account/key |
| --- | --- | --- |
| Local agent development | `npm install` then `npx convex dev --once` | No login or deploy key required |
| Interactive local preview | Keep `npx convex dev` running beside Sites | Uses the selected local or developer deployment |
| Cloud-agent development | Create an isolated cloud dev deployment and mint a deployment-scoped key | Scoped key required; never share a broad personal credential |
| Production publishing | Deploy to a Convex cloud project, then rebuild Sites with its production URL | Convex project/account required |
| Site visitors | Browser connects through the public Convex URL | No Convex account; product auth is separate |

## Accountless local development

In a non-interactive shell, when no deployment is configured and `CONVEX_DEPLOY_KEY` is absent, `npx convex dev --once` automatically provisions a local backend in `.convex/`.

Use:

```bash
npm install
npx convex dev --once
```

Do not force login. Do not use the legacy `CONVEX_AGENT_MODE=anonymous` flag. Full network access may be required the first time to download the local backend binary.

Local mode is best for ephemeral development that does not require inbound public webhooks, dashboard access, or cloud-only integrations.

## Cloud-agent development

Use an isolated cloud dev deployment only when the agent needs cloud capabilities such as public HTTP traffic, dashboard access, default environment variables, or integrations unavailable locally. Follow the current Agent Mode page to create the deployment and mint a key scoped only to it.

Never give a cloud agent a default personal deployment or broadly scoped production credentials.

## Sites ordering

1. Prepare the Sites files without starting the server.
2. Provision the selected Convex backend.
3. Verify `.env.local` contains `NEXT_PUBLIC_CONVEX_URL`.
4. Verify generated API types exist.
5. Start exactly one Sites server.
6. Keep `npx convex dev` running for an interactive preview.

If Sites started before step 3, restart it exactly once after the environment file is ready.

Use only the correct documentation index URL: https://docs.convex.dev/llms.txt.
