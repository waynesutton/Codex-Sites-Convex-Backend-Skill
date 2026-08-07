# Default durable publication workflow

Created: 2026-08-07T07:46:53Z

## Goal

Make durable Convex production plus a deployed Codex Sites URL the default whenever a user asks to publish or share an app. Preserve explicit local-only and temporary-preview paths.

## Required behavior

- Complete local build and Convex query, mutation, and realtime validation first.
- Register or reuse the Site without treating registration or public access as publication.
- Inspect and preserve an already-public access policy; request authorization only before changing access.
- Confirm the exact Convex production target and obtain fresh consent immediately before deployment.
- Set the public, non-secret `NEXT_PUBLIC_CONVEX_URL` only after the production URL is known, then rebuild and scan the bundle.
- Push the exact validated source commit, save one Sites version, deploy it, poll to success, require `get_site.current_live_url`, and run live QA.
- Recover an already-registered, already-public, never-deployed Site that still points to accountless local Convex.

## Deliverables

- Updated `SKILL.md`, README prompts, deployment/access/environment references, and agent metadata where needed.
- A deterministic publication-state classifier plus regression fixture and test.
- Updated repository file map, changelog, and completed-task record.
- Passing skill validation, shell syntax checks, regression tests, and consistency searches.

## Non-goals

- Do not weaken Convex project detection or production-consent safeguards.
- Do not infer publication from registration, access policy, or environment configuration.
- Do not publish against localhost or an accountless local backend.
- Do not include Convex deployment credentials in Sites environment variables or browser bundles.
