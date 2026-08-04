# Convex Agent Mode

Read the current official page before provisioning: https://docs.convex.dev/cli/agent-mode.

For deployment creation, expiration, selection, and scoped tokens, also read https://docs.convex.dev/cli/reference/deployment and https://docs.convex.dev/production/multiple-deployments.

Read [accounts-access-and-ownership.md](accounts-access-and-ownership.md) before deciding whether the environment is accountless, using saved developer credentials, or using a scoped key.

## Select the correct mode

| Mode | Setup | Account/key |
| --- | --- | --- |
| Local agent development | `npm install` then `npx convex dev --once` | No login or deploy key required |
| Interactive local preview | Keep `npx convex dev` running beside Sites | Uses the selected local or developer deployment |
| Cloud-agent development | Create an isolated cloud dev deployment and mint a deployment-scoped key | Scoped key required; never share a broad personal credential |
| Temporary shared preview | Publish Sites against an isolated, expiring cloud dev deployment | Scoped key for developers; visitors need no Convex account |
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

The local backend runs as a subprocess of `npx convex dev` and stops when that process stops. It cannot serve a published Codex Site. Never infer accountless mode only from the absence of a login prompt; saved CLI credentials may have been reused.

## Cloud-agent development

Use an isolated cloud dev deployment only when the agent needs cloud capabilities such as public HTTP traffic, dashboard access, default environment variables, or integrations unavailable locally. Follow the current Agent Mode page to create the deployment and mint a key scoped only to it.

Never give a cloud agent a default personal deployment or broadly scoped production credentials.

For a new isolated deployment, confirm the intended team and project, choose an expiration, and follow the current CLI form:

```bash
npx convex deployment create --type dev --select \
  team-slug:project-slug:dev/agent/app-name \
  --expiration "in 5 days"
npx convex deployment token create agent-token --save-env
npx convex dev --once
```

Set required deployment environment variables after creating or selecting the deployment and before pushing functions. Prefer project defaults when every new cloud deployment should inherit the same names; otherwise use `npx convex env set` without printing values. Keep `CONVEX_DEPLOY_KEY` in an ignored environment file and verify it never enters browser code or the Sites bundle.

## Temporary shared Sites preview

An isolated cloud dev deployment is publicly reachable and may back a temporary shared Codex Site. Treat this as an explicit preview exception to the production-only publishing path:

1. Confirm the Convex team, project, isolated dev deployment, and exact expiration.
2. Reuse a suitable isolated deployment or create one with `--type dev`, `--select`, and `--expiration`.
3. Mint or reuse only a deployment-scoped dev key.
4. Configure required backend environment variables, then run `npx convex dev --once`.
5. Build Sites with that deployment's public `convex.cloud` URL.
6. Confirm Sites access before saving and deploying the version.
7. Verify reads, writes, and realtime updates through the live Site.
8. Label the result `Temporary shared preview`, report the expiration, and explain that the Site may remain reachable after the backend expires but its data operations will fail.

Do not call this production, use a production key, or imply that preview data automatically moves to production.

## Sites ordering

1. Prepare the Sites files without starting the server.
2. Provision the selected Convex backend.
3. Verify `.env.local` contains `NEXT_PUBLIC_CONVEX_URL`.
4. Verify generated API types exist.
5. Start exactly one Sites server.
6. Keep `npx convex dev` running for an interactive preview.

If Sites started before step 3, restart it exactly once after the environment file is ready.

Use only the correct documentation index URL: https://docs.convex.dev/llms.txt.
