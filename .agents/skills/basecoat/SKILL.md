---
name: basecoat
description: Basecoat UI (basecoatui.com), the default component library for web apps - shadcn/ui's design as plain HTML classes and a small vanilla JS runtime, no React. Covers installing it on any stack (Tailwind v4 build, standalone Tailwind CLI, or prebuilt CSS with no build), the 1.x markup conventions (one root class plus data-variant and data-size), which components need JS, theming with shadcn tokens, dark mode, and what it lacks. Use when adding or styling buttons, forms, cards, dialogs, menus, tabs, toasts, tables or sidebars in a web app, when starting the UI of a new web app, or when the user mentions Basecoat, basecoat-css or shadcn without React.
---

# Basecoat UI

[Basecoat](https://basecoatui.com) is shadcn/ui's design system as HTML and CSS classes, with a small vanilla JavaScript runtime for the interactive components. It is MIT licensed, needs Tailwind v4 when built from source, and also ships prebuilt CSS that needs no build. It fits any server-rendered stack because a component is just markup. What to build with it is the `web-ui` skill.

## Look It Up, Do Not Recall It

Version 1.0 (June 2026) renamed most of the markup. Older examples, and most of what a model remembers, use pre-1.0 classes such as `btn-primary`, `btn-sm-outline` and `.form`, which no longer exist outside the optional compat CSS. Before writing a component not already used in the app, fetch its page as Markdown from the index at https://basecoatui.com/llms.txt and copy the markup from there. Where the app already uses a component, copy the app.

## Install

Pin an exact version everywhere, in URLs, `package.json` and the vendored copy. 1.1.0 was released on 2026-10-23; prefer the newest release at least two weeks old, and read the release notes before upgrading. Pick one of:

| The app has | Use |
|-------------|-----|
| A Tailwind v4 build with npm | `npm install basecoat-css@<version>`, then `@import "tailwindcss"; @import "basecoat-css";` in the app CSS |
| The standalone Tailwind CLI, such as Rails `tailwindcss-rails`, no Node | Vendor `dist/basecoat.bundle.css` (1.1.0 or later), then `@import "tailwindcss"; @import "./basecoat.bundle.css";` |
| No CSS build, such as a C web app | Vendor `dist/basecoat.cdn.min.css` and serve it as is |
| A prototype | The jsDelivr URLs below, pinned |

```html
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/basecoat-css@1.1.0/dist/basecoat.cdn.min.css">
<script src="https://cdn.jsdelivr.net/npm/basecoat-css@1.1.0/dist/js/all.min.js" defer></script>
```

* **Vendor, do not hotlink, in a real app.** Copy the files into the app's vendored directory with its version recorded (`deps/basecoat/` and `deps.lock` in a `modern-c` project, `vendor/` elsewhere) and serve them from the app.
* **The prebuilt CSS contains only the Tailwind utilities Basecoat itself uses.** Without a Tailwind build, write layout and spacing in the app's own small stylesheet using the theme tokens, `var(--border)`, `var(--muted-foreground)`, rather than utility classes that do not exist.
* **Load order:** anything containing Tailwind's preflight first, then Basecoat, then the app's theme and CSS.
* **One style pack.** The default is Vega; `basecoat-<style>` files and imports (`nova`, `maia`, `lyra` and others) replace it. Never load two.
* **JavaScript:** `dist/js/all.min.js` with `defer` covers every component except Chart. For a smaller page, load `basecoat.min.js` first and then only the `<component>.min.js` files used.

## Markup Conventions (1.x)

* One root class per component plus data attributes: `class="btn" data-variant="outline" data-size="sm"`. No modifier classes.
* Button variants: none (primary), `secondary`, `outline`, `ghost`, `link`, `destructive`. Sizes: `xs`, `sm`, none, `lg`, `icon`, `icon-xs`, `icon-sm`, `icon-lg`. `<a class="btn">` styles a link as a button.
* Root classes: `btn`, `badge`, `alert`, `card`, `field`, `fieldset`, `input`, `select`, `label`, `textarea`, `table`, `table-container`, `tabs`, `dropdown-menu`, `popover`, `dialog`, `drawer`, `sidebar`, `toaster`, `toast`, `accordion`.
* Behaviour and state come from ARIA and native attributes: `aria-expanded`, `aria-controls`, `aria-invalid`, `aria-selected`, `role="menu"`, `hidden`, `disabled`. Every `aria-controls`, `aria-labelledby` and `aria-describedby` id must exist and be unique on the page; generate them from the record or field, never hard-code them in a reused partial.
* Tooltips are CSS only, `data-tooltip="Text"` with `data-side`, one short line. They do not replace an `aria-label`.

```html
<button type="submit" class="btn">Save post</button>
<a class="btn" data-variant="outline" href="/posts">Cancel</a>
<button type="button" class="btn" data-variant="ghost" data-size="icon" aria-label="Close">
  <svg aria-hidden="true">…</svg>
</button>

<div role="group" class="field" data-invalid>
  <label for="post-title">Title</label>
  <p id="post-title-hint">Shown in lists and search results.</p>
  <p id="post-title-error"><span class="sr-only">Error:</span> Enter a title</p>
  <input id="post-title" name="post[title]" aria-invalid="true"
         aria-describedby="post-title-hint post-title-error">
</div>

<div class="card">
  <header><h2>Drafts</h2><p>Posts not yet published.</p></header>
  <section>…</section>
  <footer>…</footer>
</div>
```

The field follows `web-ui`'s error pattern: hint, then error, then control, and no `role="alert"` on the inline error even though Basecoat's own examples add one. The prebuilt CSS does not define `sr-only` (checked in 1.1.0), so define it in the app's stylesheet when there is no Tailwind build.

## Interactive Components

* **Native, no Basecoat JS:** `dialog` and alert dialog (`<dialog>` with `showModal()` and `close()`), `accordion` open and close (`<details>`), native `<select class="select">`, checkbox, radio, switch, tooltip.
* **Need the runtime:** dropdown menu, popover, select, combobox, command, tabs, toast, sidebar, drawer (backdrop close), slider (filled track), accordion (single-open), chart (beta, needs Chart.js, not in `all.min.js`).
* The runtime initializes on `DOMContentLoaded` and watches the DOM, so components in HTML swapped in later by `fetch`, htmx or Turbo initialize and clean up on their own. After restoring cached DOM, such as htmx history, call `window.basecoat.initAll({ force: true })`. After changing the children of an existing select, tabs or dropdown, call `element.refresh()`.
* **Toasts from the server:** put `<div id="toaster" class="toaster"></div>` once at the end of `body`, and render a `<div class="toast" role="status" data-category="success">` into it for the flash message after a redirect. From JavaScript, call `toaster.toast({ category, title, description })`.

## Theme and Dark Mode

* Colours, radius and fonts are shadcn tokens on `:root` and `.dark`: `--background`, `--foreground`, `--primary`, `--secondary`, `--muted`, `--accent`, `--destructive` (each with `-foreground`), `--border`, `--input`, `--ring`, `--radius`, `--font-sans`. A shadcn theme from any generator, such as tweakcn, is a `theme.css` with those variables, loaded after Basecoat.
* Dark mode is the `dark` class on `<html>`, not `prefers-color-scheme`. Set it before first paint with a small inline script in `<head>` that reads the saved choice and falls back to `matchMedia('(prefers-color-scheme: dark)')`; take the current script from the theme switcher page so it matches the key `window.basecoat.theme` saves.
* Never hard-code a colour in app CSS; use `var(--token)` so both themes work.

## Gaps and Gotchas

Basecoat does not provide these; use the alternative instead of hand-rolling a widget:

| Missing | Use |
|---------|-----|
| Date or time picker | Native `<input type="date">` or `type="time"` with `class="input"` |
| Data table logic | `.table` for styling; sorting, filtering and pagination on the server through query parameters |
| Form validation | Server-side validation, `web-ui` Forms |
| Carousel, navigation menu, resizable panels | Simpler layout: a list, a sidebar, tabs |

* Popovers and dropdowns are positioned inline, so a parent with `overflow: hidden` or `.table-container` clips them. Put row actions outside the scroll container or use a dialog.
* Toasts render under an open modal `<dialog>`. Show feedback inside the dialog, or close it first.
* `initAll({ force: true })` resets open menus and focus; use it only after a cache restore.
* Chart and Drawer are beta; their markup and API may change between minor versions.
* Basecoat claims accessible components but publishes no audit. Verify keyboard use of dropdowns, tabs, select and combobox with `web-ui`'s Verify steps.
