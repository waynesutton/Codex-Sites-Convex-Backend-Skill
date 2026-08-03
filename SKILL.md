---
name: codex-sites-convex
description: Build, extend, validate, and publish a Codex Sites application whose durable database and backend functions run on Convex. Use when a user invokes $codex-sites-convex, selects this skill from the skill picker, asks for a Codex Site backed by Convex, or asks to add Convex data, realtime queries, mutations, authentication, files, schedules, or actions to an existing Codex Sites project.
---

# Codex Sites + Convex

Build the complete application, validate both halves, and publish it unless the user explicitly requests local-only work.

## Non-negotiable architecture

- Keep the frontend, frontend build, published URL, and sharing in Codex Sites.
- Keep all durable application data and backend execution in Convex.
- Connect browser components through the public Convex React client and generated `api` types.
- Treat the Convex MCP server as a development tool, never as the visitor runtime.
- Never expose deploy keys, admin credentials, or third-party secrets to browser code.
- Do not add a second application database, mock persistence, or placeholder records.

## Load only the references needed

- Always read [references/architecture.md](references/architecture.md).
- Before selecting a Convex environment or explaining accounts, access, ownership, or authentication, read [references/accounts-access-and-ownership.md](references/accounts-access-and-ownership.md).
- Before publishing or changing a published Site, hosted environment variable, connected Convex deployment, or sharing setting, read [references/sites-settings-and-environment.md](references/sites-settings-and-environment.md).
- For a new project, read [references/bootstrap.md](references/bootstrap.md).
- Before provisioning any development backend, read [references/agent-mode.md](references/agent-mode.md).
- Before editing `convex/`, read [references/convex-rules.md](references/convex-rules.md).
- Before selecting backend packages or implementing a capability, read [references/components.md](references/components.md).
- Before completing the frontend, read [references/built-with-footer.md](references/built-with-footer.md).
- Before publishing, read [references/deployment-and-qa.md](references/deployment-and-qa.md).
- For authentication, file storage, scheduled jobs, search, migrations, or external APIs, use the official links routed by [references/convex-doc-map.md](references/convex-doc-map.md).

If the installed `sites:sites-building`, `sites:sites-hosting`, `convex:convex-expert`, or `convex:convex-reviewer` skills are available, read and follow the relevant skill before acting. This skill sets the cross-product architecture; those skills own their product-specific implementation details.

## Workflow

### 1. Inspect before changing anything

Run `scripts/preflight.sh` from the target project root. Inspect `AGENTS.md`, `.openai/hosting.json`, `package.json`, the lockfile, `app/`, `convex/`, and `.env.example` when present. Preserve the existing package manager and working structure.

Report these Sites states separately; never use one as proof of another:

1. **Local Sites project:** the editable project files exist in the current folder. A hosting manifest may exist without a registration.
2. **Registered Site:** `.openai/hosting.json` contains a valid nonempty `project_id`, and `get_site` confirms the hosted record. Sidebar visibility is checked separately and may lag.
3. **Saved Sites version:** the current build was uploaded and saved as a version. Registration alone does not create or deploy a version.
4. **Published Site:** a saved version deployed successfully and `get_site.current_live_url` is nonempty. A deployment URL or successful save alone is not sufficient.

For a new Codex user, explain that they paste the `$codex-sites-convex` prompt into a Codex task opened on their app folder. Codex can run the listed commands in its integrated terminal. If the user chooses to run a command manually, tell them to open the integrated terminal in the same project root and show the exact command. Do not assume they know what “project root,” “terminal,” or a command approval means.

Classify `CONVEX_DEPLOYMENT`, the presence and scope of `CONVEX_DEPLOY_KEY`, saved Convex CLI user configuration, and the public Convex URL without printing credentials or configuration contents. No login prompt does not prove accountless mode; saved CLI credentials may already be active.

Classify the task:

- **Empty/projectless directory:** initialize Codex Sites first, then add Convex to that same project.
- **Existing local Sites project:** preserve its structure, report whether it is registered, and add or extend Convex.
- **Existing Convex project without Sites:** preserve `convex/` and initialize the Sites frontend around it; do not scaffold another product app.
- **Both already present:** make only the requested product changes.

### 2. Prepare or preserve the Sites frontend

For a new project, use the installed Sites building workflow to initialize the local project files, but do not start or open the Sites server yet. This cross-product ordering overrides the usual Sites-only preview order: provision Convex and pass the backend-readiness gate first. Treat `.openai/hosting.json` as a local hosting manifest, not proof of registration; only a valid nonempty `project_id` identifies a registered Site. Do not replace the project's vinext/Vite/Cloudflare Worker structure.

For an existing project, install dependencies only when absent. Inspect the actual starter before choosing its public environment-variable convention.

### 3. Add Convex to the same project

Use the current Convex workflow rather than hand-writing setup. Prefer the callable Convex start/runbook tools when available. Otherwise:

```bash
npm install convex
npx convex dev
npx convex ai-files install
```

For accountless local agent development, use the supported non-interactive flow:

```bash
npm install
npx convex dev --once
```

Do not require login and do not set the legacy `CONVEX_AGENT_MODE=anonymous` flag. In a non-interactive shell with no configured deployment or deploy key, Convex automatically provisions a local backend.

After provisioning, run `scripts/check-backend-ready.sh`. Do not start the Sites server or open a browser until `.env.local` contains a nonempty `NEXT_PUBLIC_CONVEX_URL` and the generated Convex API exists.

For an interactive preview, keep `npx convex dev` running alongside Sites after the initial provisioning succeeds. Do not overwrite existing environment files. Keep `.env.local` ignored and `.env.example` limited to public names without values.

Treat Convex development and production as separate targets:

- **Development:** use `npx convex dev --once` to provision/push once, then keep `npx convex dev` running for an interactive preview. The frontend uses the development URL written to `.env.local`.
- **Production:** after development validation, use `npx convex deploy`. Capture the production deployment URL and rebuild Sites with that URL; never publish a bundle connected to the development deployment.

### 4. Complete the official capability check

Before implementing any product capability:

1. Fetch the current official component catalog from `https://www.convex.dev/components/get-convex.md`.
2. Fetch or search the current Convex documentation index at `https://docs.convex.dev/llms.txt`.
3. Match the requested capability against both sources.
4. If an official component clearly fits, fetch and read that component's linked `SKILL.md` completely before writing code.
5. Inspect the current project for an already-installed solution before adding a package.
6. Use the component only when it materially reduces custom infrastructure; otherwise use the documented built-in Convex primitive.
7. Record the selected component or the reason no component was selected in the task update.

Never select or install a Convex static-hosting component. Codex Sites owns the frontend build, published URL, and sharing.

Use `scripts/check-components.sh <keywords>` for a quick catalog search. Treat its output as discovery only; read the matched component skill and official documentation before implementation.

### 5. Configure development assistance

When Convex MCP is unavailable, tell the user to add this to `~/.codex/config.toml` and restart Codex:

```toml
[mcp_servers.convex]
command = "npx"
args = ["-y", "convex@latest", "mcp", "start"]
```

Continue implementing without MCP when normal CLI access is sufficient. Do not enable broad production access by default.

### 6. Start exactly one Sites server

Start Sites only after the backend-readiness gate passes. Before starting it, inspect retained sessions and the intended port:

- Reuse a healthy Sites server for this project when one already exists.
- Stop duplicate Sites servers started by this task before continuing.
- Never accept a fallback port as success; it usually means another server is still running.
- Never stop an unrelated user process. If ownership is unclear, report the port conflict and ask.

If Sites was started before Convex wrote `.env.local`, stop it and restart it exactly once after `NEXT_PUBLIC_CONVEX_URL` exists. Environment variables are captured when the client bundle starts; a running server will not reliably pick up a newly created public URL.

When `.env.local`, dependencies, and hosting configuration change together, allow those changes to settle and perform one clean restart. Treat JSON parse errors, overlapping Vite restarts, fallback ports, multiple-renderer warnings, and worker errors appearing in that window as one cascading server-state failure until the clean restart proves otherwise.

### 7. Prove the deployed connection early

Before building a large data-driven product, create the smallest vertical slice:

1. One validated table.
2. One query returning a small bounded result.
3. One idempotent mutation.
4. One Sites component wrapped by `ConvexProvider`.
5. One UI control that writes and visibly receives the reactive update.

Validate locally, then publish this slice when publishing is authorized. Confirm the published origin can make HTTPS and WebSocket connections to Convex. If Content Security Policy, CORS, WebSocket, or mixed-content restrictions block it, stop and report the exact evidence. Do not disguise the failure with local-only success.

### 8. Build the requested product

Propose schema changes before implementing them. Then build the smallest coherent product:

- Use `schema.ts`, validators, and explicit indexes.
- Use generated `api.module.functionName` references.
- Use `useQuery` for reactive reads and `useMutation` for writes.
- Include loading, empty, error, success, and disabled states.
- Put secret-dependent or third-party calls in Convex actions.
- Add authentication only when required; enforce authorization in every protected Convex function.
- Use Convex file storage, schedules, search, or an approved official component only when the requested feature needs it.
- Keep UI data real and backed by Convex; do not ship placeholders.
- Never throw during React render when `NEXT_PUBLIC_CONVEX_URL` is missing. Render a clear configuration/setup state and construct `ConvexReactClient` only after a valid URL exists.
- Keep developer account and deployment setup out of normal visitor UI. If a public Site lacks product authentication and per-user authorization, warn that visitors share Convex data before requesting authorization to publish publicly.

Add the removable “Built with Codex Sites + Convex” footer from [references/built-with-footer.md](references/built-with-footer.md) unless the user explicitly asks to omit or remove it. Use the bundled light/dark logo assets, follow the Site's resolved theme, use the Phosphor GitHub logo for the repository link, link each brand to its official site, and preserve the removal comment in source code.

### 9. Validate in proportion to risk

Run the project scripts that exist, plus the applicable checks:

```bash
npx convex dev --once
npx convex codegen
npm run build
```

Run lint and a separate type check when defined. Use `scripts/verify-project.sh` for local structural checks, or `scripts/verify-project.sh --publish` when publication was requested. Review changed Convex functions for validators, authentication, public/internal visibility, indexes, pagination, bounded reads, and mutation conflicts.

Fix failures and rerun the failing check. Do not declare completion from a local UI preview alone.

### 10. Register the Site early when publication is requested

After the local production build passes, inspect `.openai/hosting.json`. If publication was requested and no valid `project_id` exists, call `create_site` exactly once through the Sites hosting workflow and persist the returned `project_id`. Call `get_site` to confirm the registration before starting or resuming Convex production setup. Check `list_sites` or the Sites UI separately for sidebar visibility.

This checkpoint registers the Site only. Do not claim that a Sites version was saved or that the Site was published. If `get_site` succeeds but the Site is not listed yet, preserve the existing `project_id`, do not call `create_site` again, report `Registered Site; sidebar indexing pending`, and ask the user to refresh or reopen Sites. Report `Registered Site` as the last completed lifecycle state and name the next required Convex action.

If a hydration warning mentions attributes injected by Grammarly or another browser extension, verify once in a clean Chrome profile or with extensions disabled. Do not change application code when the warning disappears and the server-rendered markup otherwise matches.

### 11. Publish and hand off

Read and follow [references/deployment-and-qa.md](references/deployment-and-qa.md) completely.

Lifecycle order: local Sites project → registered Site → Convex production backend → production Convex URL → Sites production build → saved Sites version → Sites deployment → live URL and access verification.

Before publishing, resolve whether the Site should be public or require sign-in. Default to private when the user has not requested public access. Explain the resolved access mode and obtain explicit authorization before public publishing or any access-list change.

An accountless local backend cannot power a published Site. Before production deployment, confirm the intended Convex team, project, production deployment, and authorized account or production-scoped key. Reject any production bundle containing localhost, `127.0.0.1`, a local URL, or an unintended development deployment.

Call `save_site_version` once for the production build, then deploy that saved version. Poll the Sites deployment to success or failure and retain its exact returned `url`, but report the Site as published only after `get_site.current_live_url` is nonempty and matches that URL. Open the confirmed live URL in Codex and make its clickable link the first item in the final answer. For an existing Site, read `project_id` from `.openai/hosting.json`, call `get_site`, and treat `current_live_url` as canonical; never reconstruct a URL from a slug.

If work stops at any point, report the last completed state using the four state names above and the single next required action. Never upgrade the wording from local, registered, or saved to published without a confirmed `get_site.current_live_url`.

Every published handoff must explain how to reopen the Site in ChatGPT Sites and manage it through Settings. Hosted Site management is not available through a standalone Codex CLI or IDE screen.

Do not enable production MCP writes, generate a sign-in bypass token, make a Site public, or add users or groups unless the user explicitly authorizes that action.

## Completion contract

Finish only when:

- the requested workflow uses Convex-backed data end to end;
- the selected agent mode matches the environment and account requirements;
- backend readiness passed before the Sites server or browser started;
- the official component catalog and current Convex documentation were checked before capability implementation;
- backend generation/checks and the frontend build pass;
- no browser bundle contains a secret;
- the removable built-with footer is present unless the user explicitly opted out;
- the footer remains legible in the Site's explicit light and dark modes;
- the published connection was tested when publishing was requested;
- the handoff states Sites access, visitor sign-in, Convex backend ownership, production deployment type, shared versus per-user data, and future developer requirements without exposing credentials;
- the final response starts with the published Sites URL and includes the required access and future-update handoff, or clearly states the exact remaining blocker.
- every incomplete handoff names the last completed Sites state and the next required action.
