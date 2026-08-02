# Built with Codex Sites + Convex footer

Add a small, accessible attribution footer to every Site created with this skill unless the user explicitly asks to omit or remove it.

## Required result

- Display `Built with`, the Codex logo, a `+`, and the Convex logo.
- Link Codex to `https://openai.com/academy/chatgpt-sites/`.
- Link Convex to `https://www.convex.dev/`.
- Open both links in a new tab with `rel="noreferrer noopener"`.
- Keep the footer visually quiet and consistent with the Site's design system.
- Place it after the primary page content or in the shared root layout so it appears across routes.
- Preserve accessible names and useful image alt text.

## Assets

Copy these bundled skill assets into the Site's public assets before using them:

- `assets/codex-color.svg` → `public/built-with/codex-color.svg`
- `assets/convex-color.svg` → `public/built-with/convex-color.svg`

Preserve the supplied artwork. Do not redraw or modify either logo.

## Source contract

Use the project's existing component and styling conventions. Add this exact comment immediately above the footer component or its rendered element:

```tsx
{/* Optional attribution: users or agents may remove this BuiltWithFooter and the public/built-with logo assets without affecting app functionality. */}
```

Give the rendered footer `data-built-with-codex-convex` so it is easy for users and agents to locate.

An implementation can follow this semantic shape while adapting classes to the Site:

```tsx
{/* Optional attribution: users or agents may remove this BuiltWithFooter and the public/built-with logo assets without affecting app functionality. */}
<footer data-built-with-codex-convex aria-label="Built with Codex Sites and Convex">
  <span>Built with</span>
  <a
    href="https://openai.com/academy/chatgpt-sites/"
    target="_blank"
    rel="noreferrer noopener"
    aria-label="Learn about Codex Sites"
  >
    <img src="/built-with/codex-color.svg" alt="Codex" />
  </a>
  <span aria-hidden="true">+</span>
  <a
    href="https://www.convex.dev/"
    target="_blank"
    rel="noreferrer noopener"
    aria-label="Visit Convex"
  >
    <img src="/built-with/convex-color.svg" alt="Convex" />
  </a>
</footer>
```

## Removal

The footer is optional attribution, not infrastructure. When a user asks to remove it:

1. Remove `BuiltWithFooter` or the element with `data-built-with-codex-convex`.
2. Remove the related import if one exists.
3. Remove `public/built-with/codex-color.svg` and `public/built-with/convex-color.svg` when unused.
4. Run the frontend build to confirm no stale references remain.

Do not argue with the request, add a replacement badge, or change Convex connectivity when removing the footer.
