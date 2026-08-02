# Deployment and QA

Deployment order: Convex backend → production Convex URL → Sites production build → Sites publish → URL and access verification.

## Before deployment

- Confirm no unrelated user changes will be overwritten.
- Run Convex code generation and backend validation.
- Run the frontend production build, lint, and type check when defined.
- Confirm the browser uses only a public Convex deployment URL.
- Confirm `.env.local` contains a nonempty `NEXT_PUBLIC_CONVEX_URL` before starting Sites.
- Confirm third-party secrets exist only in Convex environment variables.

## Publish a new version

1. Deploy Convex functions and schema with the current Convex deployment workflow.
2. Obtain and record the production Convex URL. A Convex cloud project/account is required for developers managing or publishing this backend.
3. Configure the Sites production-build environment with that public URL.
4. Stop stale development bundles and rebuild the frontend cleanly with the production URL.
5. Publish with the Sites hosting workflow and retain the deployment identifier.
6. Poll `get_deployment_status` until it returns `succeeded` or `failed`. Do not treat an intermediate state as completion.
7. On success, require a non-null deployment `url` and use that exact value. Never guess, derive, or reconstruct a URL from a slug.
8. Read `project_id` from `.openai/hosting.json`, call `get_site`, and confirm that `current_live_url` matches the successful deployment `url`. Also inspect and report the current access configuration.
9. Open the exact deployed URL in Codex.
10. Complete production QA, then return the clickable Sites URL as the first item in the final answer.

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
- [ ] Reads, writes, and realtime updates work through production Convex.
- [ ] The final response begins with the clickable Sites URL and includes the future-update instruction.

## Required final-response templates

Use the applicable template after all checks pass. The clickable URL must be the first item in the response.

### Private Site

Your Site is live: [Open the Site](SITE_URL)

It is private. Open the link and sign in with an authorized ChatGPT/OpenAI account. Visitors do not need Convex accounts.

For future updates, ask Codex: ‘Build, validate, and publish the latest version to Codex Sites.’

### Public Site

Your Site is live: [Open the Site](SITE_URL)

It is public, so anyone with the link can visit without signing in or creating a Convex account.

For future updates, ask Codex: ‘Build, validate, and publish the latest version to Codex Sites.’

For `workspace_all`, `custom`, or `admins_only`, use the private template and add the precise access explanation returned by `get_site`. Every successful handoff must include this exact sentence:

For future updates, ask Codex: ‘Build, validate, and publish the latest version to Codex Sites.’

Sources:

- https://openai.com/academy/chatgpt-sites/
- https://docs.convex.dev/production/overview
- https://docs.convex.dev/ai/convex-mcp-server
- https://docs.convex.dev/cli/agent-mode
