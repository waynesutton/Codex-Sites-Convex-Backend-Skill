# Changelog

All notable changes to this project are documented here. This file follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added

- A production-bundle guard that rejects localhost, development deployment URLs, and Convex credential markers.
- A publication-state classifier and regression fixture for a registered, public Site with no saved version or live URL.
- Project file documentation, task tracking, and a PRD for the durable-publication workflow.

### Changed

- Added separate first-creation and existing-Site update prompts, including a beginner walkthrough for publishing later changes.
- Made every successful handoff include the literal `$codex-sites-convex` future-update command and removed the unmatched quotation mark.
- Required update workflows to preserve the existing Site and access policy, while redeploying Convex only when backend changes require it.
- Made “Default: Build and publish a durable shared Site” the first and default README and skill workflow for publish or share requests.
- Required fresh target-specific Convex production consent, exact production URL configuration, exact validated source commits, Sites deployment polling, canonical live URL verification, and production read/write/realtime QA.
- Clarified that accountless Agent Mode is local-only, does not create hosted Sites environment variables, and cannot power a published Site.
- Preserved already-public access without repeating the access-change request while retaining production deployment consent.
- Updated skill metadata and official Convex agent-setup guidance.

### Fixed

- Prevented registered or public Sites from being described as published without a matching nonempty `get_site.current_live_url`.
- Fixed the README architecture diagram's duplicate node identifier.
