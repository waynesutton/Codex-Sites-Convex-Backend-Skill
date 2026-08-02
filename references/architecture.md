# Architecture contract

## Ownership

| Concern | Owner |
| --- | --- |
| React UI, layout, browser interactions | Codex Sites project |
| Frontend build, URL, access, sharing | Codex Sites |
| Tables, indexes, durable records | Convex |
| Queries, mutations, actions, schedules | Convex |
| Realtime subscriptions | Convex React client |
| Backend secrets | Convex environment variables |
| Development inspection | Convex CLI and MCP |

The browser receives only the public Convex deployment URL and user-facing configuration. It imports generated types from `convex/_generated/api` and connects through `ConvexProvider`.

## Account boundaries

| Context | Convex account requirement |
| --- | --- |
| Accountless local agent development | No account; `npx convex dev --once` provisions a local backend |
| Cloud-agent development | Use an isolated cloud dev deployment and deployment-scoped key when cloud-only capabilities are required |
| Production publishing | A Convex cloud project/account is required |
| Site visitors | No Convex account; product authentication is separate and only added when requested |

## Current integration gate

The OpenAI Academy Sites page currently says Sites cannot connect directly to live data sources. A Convex-backed Site therefore requires an early deployed proof that the published origin permits browser HTTPS and WebSocket traffic to the chosen Convex deployment.

Pass criteria:

- Query returns a record.
- Mutation writes a record.
- The subscribed query updates without a refresh.
- Chrome shows no CSP, CORS, WebSocket, or mixed-content failure.

If this fails, preserve the evidence and stop before building the full product.

## Sources

- https://openai.com/academy/chatgpt-sites/
- https://docs.convex.dev/ai/using-codex
- https://docs.convex.dev/ai/convex-mcp-server
- https://docs.convex.dev/cli/agent-mode
