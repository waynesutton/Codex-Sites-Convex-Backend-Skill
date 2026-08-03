# Deployment and QA

Lifecycle order: local Sites project → registered Site → Convex production backend → production Convex URL → Sites production build → saved Sites version → Sites deployment → live URL and access verification.

Apply the account matrix, credential-detection rules, public-data warning, and accountless-to-production handoff in [accounts-access-and-ownership.md](accounts-access-and-ownership.md).

Apply the hosted management, environment-layer, and update rules in [sites-settings-and-environment.md](sites-settings-and-environment.md).

## Contents

- Copy-paste local and production prompts
- Convex development and production
- Sites lifecycle and early registration
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

## Copy-paste prompts

Use the first prompt for a local preview. An anonymous local deployment cannot power a published `.chatgpt.site` URL. Use the second prompt to move the app to Convex Cloud production and publish the Site.

Open the app folder in Codex, start a task, and paste one complete prompt into the task. Codex runs the commands in its integrated terminal. Users who want to run commands themselves should open the terminal at the project root, the folder containing `package.json`. See https://learn.chatgpt.com/docs/integrated-terminal.

### Accountless local development

```text
$codex-sites-convex Set up this app for accountless local development with
Codex Sites and Convex. If this folder is not already a Codex Sites project,
initialize Sites in this same folder and preserve its normal project structure.
Run npm install and npx convex dev --once to provision an anonymous local
backend. Confirm .env.local has NEXT_PUBLIC_CONVEX_URL and that the generated
Convex API exists before starting the frontend. Keep one Convex watcher and one
Sites development server running, then verify a query, mutation, and realtime
update locally. Give me the localhost URL. Do not require a Convex login, create
a second frontend or database, publish the Site, or claim the local backend can
power a .chatgpt.site URL.
```

### Production backend and Sites URL

```text
$codex-sites-convex Move this validated local app to production and publish it
with Codex Sites.

First rerun the local production build. Inspect .openai/hosting.json without
displaying secrets. If it lacks a valid project_id, create the Site exactly
once, save its project ID, and call get_site to confirm it appears in the
ChatGPT Sites sidebar. Explain that this registers the Site but does not save a
version or publish it.

Next inspect the current Convex configuration without displaying credentials.
Tell me whether this folder is connected to Convex Cloud. Confirm the Convex
account, team, project, and exact production deployment with me before making
production changes.

If Convex Cloud is not configured, walk me through signing in, choosing or
creating the correct project, and linking this folder. Do not select an
unrelated project or create a project without telling me.

List the production environment variable names the app requires. Show me how
to enter secret values securely through the Convex dashboard or CLI. Never ask
me to paste secret values into chat.

Announce the exact production target and explain what the deployment will
change. Get my fresh confirmation before deploying.

Deploy Convex first, capture the exact production convex.cloud URL, and rebuild
the Codex Site with that URL. Confirm the browser bundle contains no localhost
URL, development deployment URL, deploy key, or backend secret.

Save the production Sites build as a version, then publish it privately unless
I approve another audience. Wait for the Sites deployment to finish. Require a
nonempty get_site.current_live_url before calling the Site published. Verify a
query, mutation, and realtime update through that live Site. Confirm its access
mode, open the Site, then give me the exact .chatgpt.site URL and management
instructions. If work stops, report the last completed Sites state and the next
required action. Do not add product authentication unless I request it.
```

## Distinguish the four Sites states

| State | What proves it | What it does not prove |
| --- | --- | --- |
| Local Sites project | The editable Sites project files exist in the folder | Registration, a saved version, or a live URL |
| Registered Site | `.openai/hosting.json` has a valid nonempty `project_id`, and `get_site` confirms the hosted record | A version was saved or deployed |
| Saved Sites version | The current build was uploaded and saved through the Sites hosting workflow | The version is live |
| Published Site | Deployment succeeded and `get_site.current_live_url` is nonempty and matches the deployment URL | Nothing further about application correctness; complete production QA separately |

Do not infer registration from `.openai/hosting.json` alone. Do not infer publication from registration, a saved version, deployment initiation, or a deployment URL that `get_site.current_live_url` does not confirm.

### Register early for publication work

When the user requests publication:

1. Complete the local build and local validation first.
2. Run `scripts/verify-project.sh --publish`. If it reports a missing `project_id`, call `create_site` exactly once with the Sites hosting workflow.
3. Persist the returned `project_id` in `.openai/hosting.json`.
4. Call `get_site` and confirm the Site record appears in the ChatGPT Sites sidebar.
5. Report `Registered Site` as the current state, then continue with Convex production setup.

Registration is intentionally early so the user can find the Site even if Convex production setup later pauses for account, team, project, environment, or authorization input. Do not save a placeholder version or claim a publication at this checkpoint.

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

1. Confirm the local build passed and the early registration checkpoint produced a valid `project_id` confirmed by `get_site`.
2. Deploy Convex functions and schema with the current Convex deployment workflow.
3. Obtain and record the production Convex URL. A Convex cloud project/account is required for developers managing or publishing this backend.
4. Configure the Sites production-build environment with that public URL.
5. Stop stale development bundles and rebuild the frontend cleanly with the production URL.
6. Call `save_site_version` once for that exact production build and retain its version identifier. Report `Saved Sites version`, not `Published Site`.
7. Resolve the desired access mode. Prefer the private deployment path when public access was not explicitly authorized. If public or shared deployment requires approval, state the resolved access level and wait for authorization.
8. Deploy the saved version with the Sites hosting workflow and retain the deployment identifier.
9. Poll `get_deployment_status` until it returns `succeeded` or `failed`. Do not treat an intermediate state as completion.
10. On success, require a non-null deployment `url` and retain that exact value. Never guess, derive, or reconstruct a URL from a slug.
11. Call `get_site` with the registered `project_id`. Require a nonempty `current_live_url`, confirm that it matches the successful deployment `url`, and inspect the current access configuration.
12. Only now report `Published Site`, open the confirmed `current_live_url` in Codex, and complete production QA.
13. Return the clickable Sites URL as the first item in the final answer.

If deployment fails or work pauses, report the last completed state and one next required action. Examples:

- `Last completed state: Local Sites project. Next action: register the Site and persist its project_id.`
- `Last completed state: Registered Site. Next action: connect and authorize the intended Convex production deployment.`
- `Last completed state: Saved Sites version. Next action: deploy that version and wait for a successful status.`
- `Last completed state: Sites deployment succeeded, publication unconfirmed. Next action: call get_site and require a nonempty current_live_url.`

Do not present an older URL as the new deployment and do not use the word “published” until `get_site.current_live_url` confirms it.

## Discover an already-published Site

1. Read `project_id` from `.openai/hosting.json`.
2. Call `get_site` with that project identifier.
3. Use `current_live_url` as the canonical Codex Sites URL.

If `current_live_url` is empty, report that the Site is registered but not confirmed published. Never guess, derive, or reconstruct the URL from the project slug.

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
- [ ] The handoff does not call the Site published unless `get_site.current_live_url` is nonempty.
- [ ] The current access mode is reported accurately.
- [ ] Private login requirements are explained when applicable.
- [ ] The user is told that visitors do not need Convex accounts.
- [ ] The handoff names the production deployment type and who can manage it without exposing credentials.
- [ ] The handoff states whether app data is shared or isolated by authenticated user.
- [ ] A new developer is told what account, project selection, or scoped key is required before a future backend deployment.
- [ ] Reads, writes, and realtime updates work through production Convex.
- [ ] The final response begins with the clickable Sites URL and includes the future-update instruction.
- [ ] The final response explains how to reopen the Site in ChatGPT Sites and manage it through Settings.
- [ ] A stopped workflow reports the last completed state and the next required action.

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
