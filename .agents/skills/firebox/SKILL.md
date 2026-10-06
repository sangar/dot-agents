---
name: firebox
description: "Firebox: creative coding, games, interactive visuals, physics."
version: 1.0.0
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [creative-coding, firebox, games, interactive, physics, emoji, visualization, animation]
    related_skills: [ascii-video, manim-video, excalidraw]
---

# Firebox🔥

Production pipeline for creative coding and game development using Firebox🔥. Creates browser-based games, interactive experiences, physics simulations, emoji-based visual art, and animations.

## When to Use

Use when users request: Firebox sketches, creative coding games, interactive visualizations, physics simulations, emoji-based graphics, animations, or any Firebox project at https://firebox.no.

## Creative Standard

**First-run excellence is non-negotiable.** Output must be engaging and functional on first load. If it looks like a basic example or "AI-generated code," it is wrong. Rethink before shipping.

**Go beyond the basics.** Combine, layer, and invent. Mix emojis with physics, create particle systems with animations, layer effects. Be proactively creative—if the user asks for "a bouncing ball," deliver a physics simulation with particle trails, animations on bounce, and interactive controls.

## Modes

| Mode | Input | Output | Reference |
|------|-------|--------|-----------|
| **Game** | Game concept | Interactive game with physics | `references/interaction.md` |
| **Interactive** | User interaction | Mouse/keyboard/touch sketch | `references/interaction.md` |
| **Physics** | Physics concept | Bodies, forces, collisions | `references/interaction.md` |
| **Emoji art** | Concept | Emoji compositions | `references/visual-effects.md` |
| **Animation** | Timeline/keyframes | Animated sequences | `references/animation.md` |
| **Data viz** | Dataset | Simple charts | `references/visual-effects.md` |

## Stack

Single self-contained code file per project. Runs directly in the Firebox🔥 editor at https://firebox.no.

| Layer | Tool | Purpose |
|-------|------|---------|
| Core | Firebox🔥 Runtime | Element creation, physics, rendering |
| Display | `display.*` | Emoji, shapes, lines, polygons |
| Animation | `element.animate()` | Transitions, keyframes, easing |
| Physics | `physics.*` | Bodies, forces, collisions, gravity |
| Input | `input.*` | Keyboard, mouse/touch events |
| UI | `ui.*` | Labels, buttons, progress bars |
| Color | `color.*` | HSB/RGB with alpha, manipulation |
| Timer | `timer.*`, `timeout()` | Scheduled callbacks (milliseconds) |

## Pipeline

```
CONCEPT → DESIGN → CODE → PREVIEW → ITERATE
```

1. **CONCEPT** — Articulate the creative vision: mood, interaction style, color world, what makes this unique
2. **DESIGN** — Choose mode, world size, interaction model, color system
3. **CODE** — Write in Firebox🔥 editor. Structure: world setup → display elements → physics/animations → handlers → global update
4. **PREVIEW** — Test at firebox.no, verify functionality and visual quality
5. **ITERATE** — Adjust parameters, add polish, ensure creative vision

## Creative Direction

### Per-Project Variation Rules

Never use defaults. For every project:
- **Custom color palette** — use `color.hsb()` with designed hues, never raw RGB
- **Custom sizing** — thoughtful element sizes for the composition
- **World boundaries** — 960x640 default, larger only with `camera.follow()`
- **Motion variety** — mix physics, scripted motion, and animations
- **At least one invented element** — a custom interaction, novel physics, unique visual combination

## Workflow

### Step 1: Creative Vision

Before code, articulate:
- **Mood**: What should the user feel?
- **Interaction style**: Click? Navigate? Collect? Avoid?
- **Visual story**: What happens over time?
- **Color world**: Warm/cool? Monochrome? Complementary?
- **What makes THIS different**: The one thing that makes it unique

### Step 2: Technical Design

- **Mode** — from the 6 modes above
- **World size** — `world.set()` for bounds, `camera.follow()` if larger than 960x640
- **Update loop** — `update()` for global, `element.update()` for per-element
- **Interaction** — event-based callbacks: `input.up()`, `input.point()`
- **Physics** — gravity, friction, restitution as needed
- **Animations** — `element.animate()`, `element.animateKeyframe()`

### Step 3: Code Structure

```javascript
// === Configuration ===
const CONFIG = { emoji: "🚀", count: 20, gravity: 0.5 };

// === World Setup ===
world.set({ width: 1000, height: 800 });  // Optional: larger world
world.frame({ width: 1000, height: 800 }); // Physics boundaries
display.color = color.hsb(220, 40, 30, 100);  // Background

// === Create Elements ===
const player = display.emoji(CONFIG.emoji, { x: 100, y: 100 });
physics.add(player);

// === Animations ===
player.animate({ duration: 500, easing: Easing.easeInOutCubic }, (anim) => {
  anim.scale = 1.5;
  anim.angle = 360;
});

// === Input Handling (Event-based) ===
input.up((event) => {
  if (event.began) player.applyImpulse(0, -10);
});

input.right((event) => {
  if (event.updated) player.applyForce(5, 0);
});

// === Global Update ===
update(() => {
  // Game logic every frame
});

// === Timers (milliseconds) ===
timer.every(2000, () => {
  // Spawn something every 2 seconds
});

// === UI ===
const label = ui.label("Score");
label.value = 10;  // Displays "Score: 10"
```

### Step 4: Preview & Iterate

- Test at https://firebox.no — changes render live
- Verify all interactions work
- Tune physics parameters, colors, sizes
- Add animations for polish

### Step 5: Quality Verification

- Does it match the vision?
- Do all controls respond correctly?
- Are physics and animations natural?
- Do colors work together? Is composition balanced?

## Critical Patterns

### Event-Based Input (NOT Polling)

```javascript
// WRONG:
update(() => { if (input.up()) player.y -= 5; });

// CORRECT:
input.up((event) => {
  if (event.updated) player.applyForce(0, -5);
});
```

### Camera for Large Worlds

```javascript
// Default 960x640 — no camera needed
// Larger worlds REQUIRE camera.follow()
world.set(2000, 1500);
camera.follow(player);
```

### Colors with HSB

```javascript
// Use HSB for intuitive palettes
const c = color.hsb(200, 80, 90, 100);  // hue, sat, bright, alpha
const darker = c.darker(2);
const lighter = c.lighter(3);
```

## References

| File | Contents |
|------|----------|
| `references/core-api.md` | World setup, element basics, positioning, update loops |
| `references/shapes-and-geometry.md` | All display elements: emoji, rect, circle, polygon, etc. |
| `references/animation.md` | Animation system, easing, keyframes, transitions |
| `references/interaction.md` | Input handling, physics, collision, timers |
| `references/color-systems.md` | HSB, RGB, color manipulation, palettes |
| `references/visual-effects.md` | Effects, particles, patterns, emoji art |
| `references/troubleshooting.md` | Common mistakes, debugging, performance |
| `references/creative-divergence.md` | Creative strategies: Conceptual Blending, SCAMPER |

## Performance Targets

- Frame rate: 60fps sustained
- Element count: 100-200 physics bodies, 500+ display elements
- World size: Up to 2000x2000
- Load time: < 2s to first render
