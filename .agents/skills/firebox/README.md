# Firebox🔥 Skill

Creative coding and game development for the browser-based Firebox🔥 editor.

## Overview

Firebox🔥 is a creative coding environment for building:
- **Games** — Physics-based interactive games with keyboard/mouse/touch controls
- **Interactive Experiences** — User-driven visual explorations
- **Physics Simulations** — Gravity, collisions, forces, and particle systems
- **Emoji Art** — Expressive compositions using emoji as visual elements
- **Animations** — Timeline-based and keyframe-driven motion
- **Data Visualizations** — Charts and graphs using shapes and colors

## Quick Start

1. Open https://firebox.no in your browser
2. Write code in the editor
3. See changes render live

### Minimal Example

```javascript
// Create a bouncing emoji
display.color = color.hsb(220, 40, 30);

const ball = display.emoji("🏀", 400, 300);
physics.add(ball);

input.up((event) => {
  if (event.began) ball.applyImpulse(0, -500);
});

world.ground();
```

## Project Philosophy

Firebox🔥 follows a **Creative First** approach:

1. **Concept before Code** — Articulate the creative vision before writing anything
2. **First-Run Excellence** — The output must be engaging on first load
3. **Beyond Basics** — Never ship default-looking examples; invent and layer effects
4. **Cohesive Aesthetic** — All elements serve a unified visual style

## Directory Structure

```
.agents/skills/firebox/
├── SKILL.md                    # Compact skill reference (~200 lines)
├── README.md                   # This file - overview and quick start
└── references/
    ├── core-api.md             # World setup, element basics, positioning
    ├── shapes-and-geometry.md  # All display elements
    ├── animation.md            # Animation system, easing, keyframes
    ├── interaction.md          # Input, physics, collision, timers
    ├── color-systems.md        # HSB, RGB, palettes
    ├── visual-effects.md       # Particles, effects, patterns
    ├── troubleshooting.md      # Common issues, debugging
    └── creative-divergence.md  # Creative strategies for unique output
```

## The 5-Stage Pipeline

Every Firebox🔥 project follows:

```
CONCEPT → DESIGN → CODE → PREVIEW → ITERATE
```

1. **Concept** — Define mood, interaction style, color world, uniqueness
2. **Design** — Choose mode, world size, interaction model
3. **Code** — Write in Firebox🔥 editor with proper structure
4. **Preview** — Test live at firebox.no
5. **Iterate** — Polish parameters, ensure vision match

## Key Principles

### Event-Based Input

Firebox🔥 uses **callbacks**, not polling:

```javascript
// Correct:
input.up((event) => {
  if (event.updated) player.applyForce(0, -5);
});

// Wrong:
update(() => {
  if (input.up()) player.y -= 5;  // DOES NOT WORK
});
```

### HSB Colors

Use HSB for intuitive palettes:

```javascript
const sky = color.hsb(200, 80, 90);     // Blue
const sunset = color.hsb(20, 80, 90);   // Orange
const shade = sky.darker(2);            // Darker blue
```

### Physics Integration

Add physics to any element:

```javascript
const body = display.circle(100, 100, 30);
physics.add(body);
body.applyForce(100, 0);
```

### Animations

Smooth transitions with easing:

```javascript
element.animate({
  duration: 1000,
  easing: Easing.easeInOutCubic,
  autoreverse: true
}, (anim) => {
  anim.scale = 2;
  anim.angle = 360;
});
```

## Creative Strategies

For experimental or unique projects, see `references/creative-divergence.md`:

- **Conceptual Blending** — Combine two distinct systems (e.g., physics + emoji reactions)
- **SCAMPER** — Systematically transform known patterns (Substitute, Combine, Adapt...)
- **Distance Association** — Explore associations at different conceptual distances

## Default World Size

The default world is **960×640**, matching the viewport. For larger worlds:

```javascript
world.set(2000, 1500);
camera.follow(player);  // REQUIRED for larger worlds
```

## Resources

- **Firebox Editor**: https://firebox.no
- **SKILL.md**: Quick reference for agents
- **references/**: Detailed API documentation

## Performance Guidelines

- Target 60fps sustained
- Limit physics bodies to ~200
- Clean up destroyed elements from arrays
- Use `element.update()` instead of global loops where possible
