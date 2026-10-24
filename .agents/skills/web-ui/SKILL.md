---
name: web-ui
description: UI and UX rules for web apps on any stack - semantic HTML first, WCAG 2.2 AA with concrete numbers, forms and validation in the GOV.UK pattern, every state designed (empty, loading, error, success), responsive down to 320px, light and dark. Use when building, changing or reviewing pages, components, forms, layouts, navigation or styling in a web app, or when the user mentions UI, UX, accessibility, a11y, design, forms or validation. Components come from the basecoat skill.
---

# Web UI

Most UI defects are predictable: a missing label, an error that clears the form, an empty table with no explanation, a button that is only a coloured div. Build every page against the rules below. Components and styling come from the `basecoat` skill; this skill is what to build with them.

## Order of Work

1. **HTML first.** The page is semantic HTML that works without CSS and JavaScript: real links, buttons, forms and headings.
2. **Components from Basecoat.** Do not hand-roll buttons, inputs, dialogs, menus or tabs. Hand-rolled controls lose keyboard and screen reader behaviour.
3. **JavaScript last**, as an enhancement of something that already works.
4. **Check it in a browser** before calling it done: see Verify.

## Structure

* `<html lang>` set (`nb` for Norwegian bokmål), a unique `<title>` per page in the form "Page – App".
* One `<h1>` per page, heading levels in order, landmarks `header`, `nav`, `main`, `footer`, and a skip link to `main`.
* Links go somewhere, buttons do something. Never a clickable `div` or `span`.
* Tables only for tabular data, with `<th scope>`. Wide tables scroll inside their own container, not the page.

## Accessibility: WCAG 2.2 AA

* **Contrast:** text 4.5:1, large text (24px, or 18.66px bold) 3:1, component borders, focus rings and meaningful icons 3:1. Use the theme tokens; they are built to pass.
* **Colour is never the only cue.** Errors, required fields, status and links in text also have words, icons or underlines.
* **Keyboard:** everything works with Tab, Shift+Tab, Enter, Space and Esc, in a logical order, with no traps. Focus is always visible, and never hidden behind a sticky header or a toast.
* **Targets** are at least 24×24 CSS px; make primary touch targets 44×44.
* **Names:** an icon-only button has an `aria-label`; a control's accessible name contains its visible label.
* **Zoom and reflow:** usable at 200% text size and at 320 CSS px width without horizontal page scroll.
* **Hover and focus popups** can be dismissed with Esc, stay while hovered, and do not hold anything that is only reachable by hover.
* **Dragging** always has a click or keyboard alternative.
* **Status messages** ("Saved", "3 results") use `role="status"` and do not move focus.
* **Motion** respects `prefers-reduced-motion`. Nothing flashes more than three times a second.
* **Images:** informative ones have `alt` text that says what they show; decorative ones `alt=""`.

## Forms

Follow the GOV.UK Design System patterns: https://design-system.service.gov.uk/patterns/validation/

* A visible `<label>` above every field, in sentence case, without a trailing colon. Placeholder text is never a label or a hint.
* A hint is one short sentence, linked from the field's `aria-describedby`.
* Group related choices in `<fieldset>` with a `<legend>`.
* Set `autocomplete` on personal data fields, `inputmode="numeric"` instead of `type="number"` for codes and numbers, and turn `spellcheck` off for names, emails and reference numbers. Never block paste.
* Size fields to the expected answer. Do not ask for the same information twice.
* Validate on submit, always on the server. Use `novalidate` on the form so the browser's bubbles do not compete. Do not validate while the user is typing or on blur.
* Accept unambiguous input: trim spaces, allow `1 234`, `1234` and `12 34` for the same number.

**On error**, render the page again with status 422 and:

1. Every answer kept.
2. `<title>` prefixed with "Error: ".
3. An error summary at the top of `main`, above the `<h1>`, titled "There is a problem", focused on load, with `role="alert"` and a link to each field in error.
4. The same message inline, between the field's hint and the control, with a visually hidden "Error:" prefix, `aria-invalid="true"` on the control and the error's id added to its `aria-describedby`. Inline errors do not get `role="alert"`; the summary already announces.

**Messages** say what to do, specifically: "Enter your email address", "Name must be 35 characters or less". Not "Invalid input", "This field is required", "Please", or "Sorry".

## States

Every view that shows data designs all of these, not just the full one:

* **Empty:** say what will appear here and offer the action that creates it.
* **Loading:** server-rendered pages load complete. For in-page updates, show a skeleton for content and a spinner inside the button that was pressed; disable that button while pending so it cannot submit twice.
* **Error:** what happened and what the user can do, with their input kept.
* **Success:** redirect to the result with a short confirmation, or a toast for in-place changes.
* **Long and odd content:** long Norwegian compound words, æ, ø and å, 200-character names, zero, one and many items. Text wraps or truncates with the full value available.
* **Permission denied and not found** get their own page, not a form error.

## Actions and Navigation

* One primary action per view, visually primary. Secondary actions are outline or ghost buttons.
* Button labels are verbs naming the result: "Save post", "Send invoice", not "OK" or "Submit".
* Destructive actions use the destructive variant and either a confirmation dialog that names what is deleted, or undo. Anything legal, financial or data-changing can be reviewed, corrected or reversed.
* After a successful POST, redirect with 303 so refresh and back do not resubmit.
* State a user would share or return to, such as filters, sort order, tab and page, lives in the URL query string.

## Layout and Visual

* Mobile first: one column at narrow widths, more where there is room. Test at 320, 768 and 1280 px.
* Colours, radii and fonts come from the theme tokens, never hard-coded values, so light and dark both work. Check both.
* Spacing from one scale (multiples of 4px). Group related things by proximity, separate sections by space before lines or boxes.
* Body text at least 16px, line height about 1.5, lines 45 to 75 characters.
* Images and embeds have `width` and `height` so the page does not shift as they load; lazy-load what is below the fold.
* Dates, numbers and currency are formatted for the page language: `24. okt. 2026`, `1 234,50 kr` for `nb`.

## Verify

Before calling UI work done, open the changed pages in a browser with whatever browser tool the session has, and check:

1. Light and dark, at 320 px and 1280 px wide.
2. The whole flow by keyboard alone: focus visible and in order, Esc closes popups, dialogs return focus to their trigger.
3. Empty, error and long-content states, including a failed form submit.
4. No console errors. Run axe-core in the page when the browser tool can inject a script, and fix every violation it reports.

Report what was checked and what could not be.
