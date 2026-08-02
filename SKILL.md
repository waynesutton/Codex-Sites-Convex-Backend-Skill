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
- For a new project, read [references/bootstrap.md](references/bootstrap.md).
- Before editing `convex/`, read [references/convex-rules.md](references/convex-rules.md).
- Before selecting backend packages or implementing a capability, read [references/components.md](references/components.md).
- Before publishing, read [references/deployment-and-qa.md](references/deployment-and-qa.md).
- For authentication, file storage, scheduled jobs, search, migrations, or external APIs, use the official links routed by [references/convex-doc-map.md](references/convex-doc-map.md).

If the installed `sites:sites-building`, `sites:sites-hosting`, `convex:convex-expert`, or `convex:convex-reviewer` skills are available, read and follow the relevant skill before acting. This skill sets the cross-product architecture; those skills own their product-specific implementation details.

## Workflow

### 1. Inspect before changing anything

Run `scripts/preflight.sh` from the target project root. Inspect `AGENTS.md`, `.openai/hosting.json`, `package.json`, the lockfile, `app/`, `convex/`, and `.env.example` when present. Preserve the existing package manager and working structure.

Classify the task:

- **Empty/projectless directory:** initialize Codex Sites first, then add Convex to that same project.
- **Existing Sites project:** preserve its structure and add or extend Convex.
- **Existing Convex project without Sites:** preserve `convex/` and initialize the Sites frontend around it; do not scaffold another product app.
- **Both already present:** make only the requested product changes.

### 2. Start or preserve the Sites frontend

For a new project, use the installed Sites building workflow and retain its development server. A Sites project is identified by `.openai/hosting.json`; do not replace its vinext/Vite/Cloudflare Worker structure.

For an existing project, install dependencies only when absent. Inspect the actual starter before choosing its public environment-variable convention.

### 3. Add Convex to the same project

Use the current Convex workflow rather than hand-writing setup. Prefer the callable Convex start/runbook tools when available. Otherwise:

```bash
npm install convex
npx convex dev
npx convex ai-files install
```

Interactive local work uses `npx convex dev`. A non-interactive agent or cloud setup uses:

```bash
npm install
npx convex dev --once
```

Do not overwrite existing environment files. Keep `.env.local` ignored and `.env.example` limited to public names without values.

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

### 6. Prove the deployed connection early

Before building a large data-driven product, create the smallest vertical slice:

1. One validated table.
2. One query returning a small bounded result.
3. One idempotent mutation.
4. One Sites component wrapped by `ConvexProvider`.
5. One UI control that writes and visibly receives the reactive update.

Validate locally, then publish this slice when publishing is authorized. Confirm the published origin can make HTTPS and WebSocket connections to Convex. If Content Security Policy, CORS, WebSocket, or mixed-content restrictions block it, stop and report the exact evidence. Do not disguise the failure with local-only success.

### 7. Build the requested product

Propose schema changes before implementing them. Then build the smallest coherent product:

- Use `schema.ts`, validators, and explicit indexes.
- Use generated `api.module.functionName` references.
- Use `useQuery` for reactive reads and `useMutation` for writes.
- Include loading, empty, error, success, and disabled states.
- Put secret-dependent or third-party calls in Convex actions.
- Add authentication only when required; enforce authorization in every protected Convex function.
- Use Convex file storage, schedules, search, or an approved official component only when the requested feature needs it.
- Keep UI data real and backed by Convex; do not ship placeholders.

### 8. Validate in proportion to risk

Run the project scripts that exist, plus the applicable checks:

```bash
npx convex dev --once
npx convex codegen
npm run build
```

Run lint and a separate type check when defined. Use `scripts/verify-project.sh` for structural checks. Review changed Convex functions for validators, authentication, public/internal visibility, indexes, pagination, bounded reads, and mutation conflicts.

Fix failures and rerun the failing check. Do not declare completion from a local UI preview alone.

### 9. Publish in dependency order

When the user wants a live result:

1. Deploy the Convex backend and confirm its production deployment URL.
2. Configure the Sites frontend with that public URL using the project-supported public-variable mechanism.
3. Run the final frontend build.
4. Publish through the Sites hosting workflow.
5. Test the published URL in Chrome for reads, writes, reactive updates, authentication, responsive layout, and error states.
6. Return the Sites URL as the primary deliverable and explain any sharing action the user must take.

Do not enable production MCP writes or share the Site with additional people unless the user authorizes that action.

## Completion contract

Finish only when:

- the requested workflow uses Convex-backed data end to end;
- the official component catalog and current Convex documentation were checked before capability implementation;
- backend generation/checks and the frontend build pass;
- no browser bundle contains a secret;
- the published connection was tested when publishing was requested;
- the final response includes the published Sites URL, or clearly states the exact remaining blocker.
