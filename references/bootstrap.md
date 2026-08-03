# Bootstrap paths

## Where commands run

Open the app folder in Codex and start a task there. Paste the skill prompt into the task; Codex can run the setup commands in its integrated terminal. A user does not need to copy each command manually. If manual execution is requested, open the integrated terminal at the project root, the folder containing `package.json`, and run one command at a time. Explain approval requests before asking a new user to accept them.

Codex guide: https://learn.chatgpt.com/docs/integrated-terminal

## New empty workspace

1. Initialize the Sites starter with the installed Sites workflow.
2. Do not start the Sites server yet.
3. Install `convex` in the same package.
4. Have Codex run `npx convex dev --once` in its terminal to provision an accountless local backend.
5. Run `npx convex ai-files install`.
6. Verify `.env.local` contains a nonempty `NEXT_PUBLIC_CONVEX_URL` and generated API types exist.
7. Add a guarded `ConvexProvider` that renders a helpful setup state instead of throwing when the URL is absent.
8. Start exactly one Sites server after backend readiness passes.
9. Keep `npx convex dev` running alongside Sites for the interactive preview.
10. Build the vertical connection test before product features.

If Sites was already running when Convex created or changed `.env.local`, stop it and restart exactly once. Do not accept a fallback port.

## Existing Sites project

Preserve `.openai/hosting.json`, the package manager, lockfile, Vite/vinext structure, worker entrypoint, and existing scripts. Add only the Convex dependency, `convex/`, generated client types, provider, and requested product code.

## Existing Convex project

Preserve `convex/`, the deployment configuration, schema, generated types, and auth. Add the Sites frontend in the existing project root only when it does not conflict with the current package structure. If it would overwrite an existing application, stop and explain the collision.

## Convex Codex support

Install project guidance:

```bash
npx convex ai-files install
```

This manages a Convex section in `AGENTS.md` and installs current Convex agent skills in `.agents/skills/`.

Optional full Convex plugin installation:

```bash
codex plugin marketplace add get-convex/convex-codex-plugin
codex plugin add convex@convex-codex-plugin
```

Source: https://docs.convex.dev/ai/using-codex

Agent mode: https://docs.convex.dev/cli/agent-mode
