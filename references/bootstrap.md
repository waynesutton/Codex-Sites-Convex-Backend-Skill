# Bootstrap paths

## Where commands run

Open the app folder in Codex and start a task there. Paste the skill prompt into the task; Codex can run the setup commands in its integrated terminal. A user does not need to copy each command manually. If manual execution is requested, open the integrated terminal at the project root, the folder containing `package.json`, and run one command at a time. Explain approval requests before asking a new user to accept them.

Codex guide: https://learn.chatgpt.com/docs/integrated-terminal

## New empty workspace

1. Initialize the Sites starter with the installed Sites workflow.
2. Do not start the Sites server yet.
3. Install `convex` in the same package.
4. Have Codex run `npx convex dev --once` in its terminal to provision an accountless local backend.
5. Run `npx convex ai-files status`, then install only when the managed files are missing or stale.
6. Verify `.env.local` contains a nonempty `NEXT_PUBLIC_CONVEX_URL` and generated API types exist.
7. Add a guarded `ConvexProvider` that renders a helpful setup state instead of throwing when the URL is absent.
8. Start exactly one Sites server after backend readiness passes.
9. Keep `npx convex dev` running alongside Sites for the interactive preview.
10. Build the vertical connection test before product features.

If Sites was already running when Convex created or changed `.env.local`, stop it and restart exactly once. Do not accept a fallback port.

## Existing Sites project

Preserve `.openai/hosting.json`, the package manager, lockfile, Vite/vinext structure, worker entrypoint, and existing scripts. Add only the Convex dependency, `convex/`, generated client types, provider, and requested product code.

Do not treat the manifest alone as a registered Site. A valid nonempty `project_id` means the local folder has registration metadata; confirm that registration with `get_site`. When publication is requested, register the Site exactly once after the local build passes and before Convex production setup can pause the workflow.

## Existing Convex project

Preserve `convex/`, the deployment configuration, schema, generated types, and auth. Add the Sites frontend in the existing project root only when it does not conflict with the current package structure. If it would overwrite an existing application, stop and explain the collision.

## Convex Codex support

Use https://www.convex.dev/agent-setup.md as the current setup source.

### Install one global integration

Prefer the full Convex plugin for Codex. Inspect before changing it:

```bash
codex plugin marketplace list --json
codex plugin list --json
```

If the Convex marketplace is absent, add it. If present, upgrade it using its exact listed name. Then install or update the plugin:

```bash
codex plugin marketplace add get-convex/convex-codex-plugin
codex plugin add convex@convex-codex-plugin
```

Verify with both list commands and confirm the `convex` plugin comes from `convex-codex-plugin`. Restart Codex when it is not available in the current session. Do not install separate Convex skills or MCP when the full plugin succeeds.

Use standalone skills plus MCP only when the plugin path is unavailable. Preserve unrelated user configuration and do not enable production access.

### Install managed project guidance

Treat a folder as an existing Convex project only when its project-level `package.json` includes `convex` and the same root contains either `convex/` or `convex.json`. In a monorepo, stop when ownership is ambiguous.

Record existing changes, then inspect managed AI files:

```bash
git status --short
npx convex ai-files status
```

When status reports missing or stale files, run:

```bash
npx convex ai-files install
```

Let the CLI manage `AGENTS.md`, `CLAUDE.md`, `convex.json`, generated guidance, and project skills. Do not hand-edit managed sections. Verify afterward:

```bash
npx convex ai-files status
git status --short
git diff -- convex.json convex/_generated/ai AGENTS.md CLAUDE.md
```

Read `convex/_generated/ai/guidelines.md` completely before later Convex code work. During integration setup alone, do not initialize Convex, run a development server, log in, deploy, change application code or schema, modify environment variables, or access production data.

Source: https://docs.convex.dev/ai/using-codex

Agent mode: https://docs.convex.dev/cli/agent-mode
