# Bootstrap paths

## New empty workspace

1. Initialize the Sites starter with the installed Sites workflow.
2. Start its development server and preserve the printed URL.
3. Install `convex` in the same package.
4. Run `npx convex dev` for an interactive hosted development deployment.
5. Run `npx convex ai-files install`.
6. Add `ConvexProvider` using the starter's supported public environment-variable convention.
7. Build the vertical connection test before product features.

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
