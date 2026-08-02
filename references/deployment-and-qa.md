# Deployment and QA

## Before deployment

- Confirm no unrelated user changes will be overwritten.
- Run Convex code generation and backend validation.
- Run the frontend production build, lint, and type check when defined.
- Confirm the browser uses only a public Convex deployment URL.
- Confirm `.env.local` contains a nonempty `NEXT_PUBLIC_CONVEX_URL` before starting Sites.
- Confirm third-party secrets exist only in Convex environment variables.

## Deployment order

1. Deploy Convex functions and schema with the current Convex deployment workflow.
2. Record the production Convex URL.
3. Configure the Sites production-build environment with that public URL.
4. Stop stale development bundles and rebuild the frontend cleanly with the production URL.
5. Publish with the Sites hosting workflow.

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

Sources:

- https://openai.com/academy/chatgpt-sites/
- https://docs.convex.dev/production/overview
- https://docs.convex.dev/ai/convex-mcp-server
- https://docs.convex.dev/cli/agent-mode
