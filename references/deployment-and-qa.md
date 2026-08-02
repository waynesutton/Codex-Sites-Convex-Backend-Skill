# Deployment and QA

Deployment order: Convex backend → production Convex URL → Sites production build → Sites publish → URL and access verification.

Apply the account matrix, credential-detection rules, public-data warning, and accountless-to-production handoff in [accounts-access-and-ownership.md](accounts-access-and-ownership.md).

Apply the hosted management, environment-layer, and update rules in [sites-settings-and-environment.md](sites-settings-and-environment.md).

## Contents

- Convex development and production
- Sites publishing and access choice
- New and existing Site deployment
- Access changes and private login
- Production QA and response templates

## Before deployment

- Confirm no unrelated user changes will be overwritten.
- Run Convex code generation and backend validation.
- Run the frontend production build, lint, and type check when defined.
- Confirm the browser uses only a public Convex deployment URL.
- Confirm `.env.local` contains a nonempty `NEXT_PUBLIC_CONVEX_URL` before starting Sites.
- Confirm third-party secrets exist only in Convex environment variables.

## Convex development and production

### Local or development backend

Use this while building and testing. It is not the backend for the published Site.

1. Install dependencies.
2. Run `npx convex dev --once` to configure a development backend, push functions once, generate API types, and write the development deployment URL to `.env.local`.
3. Verify the frontend's public Convex URL variable is present. For this Sites starter it is normally `NEXT_PUBLIC_CONVEX_URL`; follow the actual starter convention if different.
4. During an interactive preview, keep `npx convex dev` running beside exactly one Sites development server.
5. Verify development reads, writes, and realtime updates.

Accountless agent development may use a local backend without a Convex account. A cloud development deployment requires a Convex project and suitably scoped credentials.

### Production backend

Use this only after development checks pass:

1. Confirm the developer is authenticated to the intended Convex project, or that a production-scoped `CONVEX_DEPLOY_KEY` is configured for the deployment workflow.
2. Configure production-only backend environment variables in Convex. Local `.env.local` values are not automatically backend environment variables. Use the dashboard or `npx convex env set --prod NAME`, without exposing secret values in logs or browser variables.
3. Run `npx convex deploy`. This deploys to the project's production deployment when the local project is configured through `CONVEX_DEPLOYMENT`; when `CONVEX_DEPLOY_KEY` is set, it deploys to the deployment scoped by that key.
4. Capture the production Convex URL returned by the deployment workflow or deployment settings.
5. Configure the Sites production-build public environment variable with that production URL.
6. Run a clean frontend production build. Inspect the built configuration and ensure it does not reference a local or development Convex URL.

Never use `npx convex dev` as the production deployment step, and never publish a Sites bundle connected to a development backend.

## Choose who can open the Codex Site

Resolve and explain the access choice before calling a Sites deployment or access-update tool:

- **No sign-in for visitors:** use `public`. Anyone with the URL can open the Site. Public publishing is an external side effect and requires explicit user authorization.
- **Sign-in required for all workspace members:** use `workspace_all`. Visitors sign in with an active ChatGPT/OpenAI account in that workspace.
- **Sign-in required for selected people or groups:** use `custom`. Visitors sign in with the explicitly allowed ChatGPT/OpenAI account. Adding an email grants access but sends no invitation email.
- **Owner/admin access only:** use `admins_only`.

If the user has not requested public access, publish privately with the existing access policy. Do not silently choose `public`. Sites sign-in controls access to the frontend; application authentication controls what a signed-in visitor can do inside the product. Neither requires the visitor to own a Convex account.

Example intent mapping:

- “Publish this so anyone with the link can use it without logging in” → explain `public`, request/confirm authorization, then publish or update access as public.
- “Publish this only for my workspace” → use `workspace_all`.
- “Share this only with alex@example.com” → inspect existing `custom` access, explain the full resulting allowlist, obtain authorization, then pass the complete existing-plus-desired allowlist to `update_site_access`.
- “Publish it privately” with no audience specified → preserve the current private policy or use the private deployment path; report who can access it.

## Publish a new version

1. Deploy Convex functions and schema with the current Convex deployment workflow.
2. Obtain and record the production Convex URL. A Convex cloud project/account is required for developers managing or publishing this backend.
3. Configure the Sites production-build environment with that public URL.
4. Stop stale development bundles and rebuild the frontend cleanly with the production URL.
5. Resolve the desired access mode. Prefer the private deployment path when public access was not explicitly authorized. If public or shared deployment requires approval, state the resolved access level and wait for authorization.
6. Publish with the Sites hosting workflow and retain the deployment identifier.
7. Poll `get_deployment_status` until it returns `succeeded` or `failed`. Do not treat an intermediate state as completion.
8. On success, require a non-null deployment `url` and use that exact value. Never guess, derive, or reconstruct a URL from a slug.
9. Read `project_id` from `.openai/hosting.json`, call `get_site`, and confirm that `current_live_url` matches the successful deployment `url`. Also inspect and report the current access configuration.
10. Open the exact deployed URL in Codex.
11. Complete production QA, then return the clickable Sites URL as the first item in the final answer.

If deployment fails, report the failed status and useful error details. Do not present an older URL as the new deployment.

## Discover an already-published Site

1. Read `project_id` from `.openai/hosting.json`.
2. Call `get_site` with that project identifier.
3. Use `current_live_url` as the canonical Codex Sites URL.

Never guess, derive, or reconstruct the URL from the project slug.

## Explain access accurately

- `public`: anyone with the URL can visit without signing in.
- `workspace_all`: active workspace members sign in with their ChatGPT/OpenAI workspace account.
- `custom`: only explicitly allowed users and groups can sign in.
- `admins_only`: only the owner or administrators can visit.

Visitors never need a Convex account. A Convex account is needed only by developers managing or deploying the backend. Product-level authentication may still require visitors to sign in to the application, independently of Sites access and Convex developer access.

## Hand off a private Site

- Tell the visitor to open the Sites URL.
- Tell them to sign in with the ChatGPT/OpenAI account that was granted access.
- Explain that signing in to the Convex dashboard does not grant access to the Site.
- If access fails, call `get_site` and inspect the current access policy instead of guessing.
- Never generate a sign-in bypass token unless the user explicitly requests one.

## Change Site access only with authorization

Access changes are external side effects:

- Never make a Site public automatically.
- Never add users or groups without explicit authorization.
- Before changing access, explain the access level resolved from `get_site` and the proposed change.
- Use `update_site_access` only after the user authorizes the change.
- When preserving custom users, pass the complete existing and desired email allowlist; do not pass only the newly added address.
- Explain that adding an email grants access but does not send an invitation email.

## Published QA

Use Chrome for the final deployed check. Verify:

- initial query and loading state;
- mutation success, duplicate submission behavior, and errors;
- reactive update without refresh;
- authentication and authorization when present;
- responsive layout, keyboard controls, and touch targets;
- empty, offline, and backend-error states;
- browser console and network panel for CSP, CORS, WebSocket, and mixed-content failures.

## Development-server recovery

- Run only one Sites server for the project and require the intended port.
- If `.env.local`, dependencies, or hosting configuration change after startup, let the writes settle and restart exactly once.
- Treat JSON parsing, worker startup, multiple-renderer, and fallback-port errors immediately after those changes as cascading restart failures first.
- Keep `npx convex dev` running during an interactive local preview.
- Treat Grammarly-injected hydration attributes as extension noise after reproducing cleanly with extensions disabled.

Sharing or widening access is an external side effect. Ask before changing the audience unless the user explicitly requested sharing.

## Post-deployment checklist

- [ ] `get_deployment_status` is `succeeded`.
- [ ] The successful deployment `url` is non-null.
- [ ] `get_site.current_live_url` matches the successful deployment URL.
- [ ] The current access mode is reported accurately.
- [ ] Private login requirements are explained when applicable.
- [ ] The user is told that visitors do not need Convex accounts.
- [ ] The handoff names the production deployment type and who can manage it without exposing credentials.
- [ ] The handoff states whether app data is shared or isolated by authenticated user.
- [ ] A new developer is told what account, project selection, or scoped key is required before a future backend deployment.
- [ ] Reads, writes, and realtime updates work through production Convex.
- [ ] The final response begins with the clickable Sites URL and includes the future-update instruction.
- [ ] The final response explains how to reopen the Site in ChatGPT Sites and manage it through Settings.

## Required final-response templates

Use the applicable template after all checks pass. The clickable URL must be the first item in the response.

After the opening paragraph, add: the exact Sites access mode; whether ChatGPT/OpenAI sign-in is required; production Convex deployment type; backend owner or manager; whether data is shared or isolated; and what a new developer needs for the next backend deployment. Never include credentials.

### Private Site

Your Site is live: [Open the Site](SITE_URL)

It is private. Open the link and sign in with an authorized ChatGPT/OpenAI account. Visitors do not need Convex accounts.

For future updates, ask Codex: ‘Build, validate, and publish the latest version to Codex Sites.’

To manage this Site later, open Sites in ChatGPT or visit https://chatgpt.com/sites, select the Site, then open Settings.

### Public Site

Your Site is live: [Open the Site](SITE_URL)

It is public, so anyone with the link can visit without signing in or creating a Convex account.

For future updates, ask Codex: ‘Build, validate, and publish the latest version to Codex Sites.’

To manage this Site later, open Sites in ChatGPT or visit https://chatgpt.com/sites, select the Site, then open Settings.

For `workspace_all`, `custom`, or `admins_only`, use the private template and add the precise access explanation returned by `get_site`. Every successful handoff must include this exact sentence:

For future updates, ask Codex: ‘Build, validate, and publish the latest version to Codex Sites.’

Sources:

- https://openai.com/academy/chatgpt-sites/
- https://docs.convex.dev/production/overview
- https://docs.convex.dev/cli/reference/dev
- https://docs.convex.dev/cli/reference/deploy
- https://docs.convex.dev/client/react/deployment-urls
- https://docs.convex.dev/ai/convex-mcp-server
- https://docs.convex.dev/cli/agent-mode
