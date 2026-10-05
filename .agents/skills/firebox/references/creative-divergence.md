# Creative Divergence Strategies

Use these strategies when users request experimental, creative, surprising, or unconventional output. Select the strategy that best fits and reason through its steps BEFORE generating code.

---

## Conceptual Blending

**When to use:** The user names two things to combine or wants hybrid aesthetics.

**Method:**
1. Name two distinct systems (e.g., physics + emoji reactions)
2. Map correspondences (force magnitude = emoji expression, collisions = particle bursts)
3. Blend selectively — keep mappings that produce interesting emergent behavior
4. Code the blend as a unified system, not two systems side-by-side

**Example:** A physics simulation where emoji expressions change based on velocity, and collisions spawn emoji particle bursts.

---

## SCAMPER Transformation

**When to use:** The user wants a twist on a known pattern.

**Method:** Systematically transform a familiar concept:

| Letter | Action | Example |
|--------|--------|---------|
| **S**ubstitute | Replace circles with emojis, lines with trails | Instead of balls, use bouncing emojis |
| **C**ombine | Merge physics with timed spawning | Physics bodies that spawn on a rhythm |
| **A**dapt | Apply game mechanics to visual art | Score-keeping in an abstract art piece |
| **M**odify | Exaggerate scale, warp physics | 10x gravity, microscopic elements |
| **P**urpose | Use physics for art generation | Let physics settle into a composition |
| **E**liminate | Remove gravity, remove collisions | Zero-gravity particle field |
| **R**everse | Inverse controls, upside-down world | Inverted gravity, mirrored controls |

---

## Distance Association

**When to use:** The user gives a single concept and wants exploration.

**Method:**
1. Anchor on the user's concept (e.g., "relaxation")
2. Generate associations at three distances:

| Distance | Association Type | Examples |
|----------|------------------|----------|
| **Close** (obvious) | Direct interpretations | Slow movement, soft colors, gentle sounds |
| **Medium** (interesting) | Related concepts | Floating bubbles, drifting clouds, swaying trees |
| **Far** (abstract) | Conceptual mappings | Sine wave breathing, color temperature shifts, gravity-free physics |

3. **Develop the medium-distance associations** — specific enough to implement but unexpected enough to be interesting

**Example:** For "relaxation," instead of just slow movement (close), use drifting clouds with variable opacity responding to "breathing" rhythm (medium), or color temperature that slowly warms and cools in a 4-second cycle (far).

---

## Applying These Strategies

### Before Coding

1. Identify which strategy fits the request
2. Work through the steps methodically
3. Document your creative decisions
4. Sketch the intended behavior mentally or in notes

### During Implementation

1. Start with the core concept from your strategy work
2. Layer technical elements (physics, animation, color) to serve the creative vision
3. Iterate on the output — if it feels generic, revisit your strategy choices

### Quality Check

Ask yourself:
- Does this deliver what the strategy promised?
- Is the output meaningfully different from a basic example?
- Would a user recognize this as intentionally creative?

---

## Example Applications

### Conceptual Blending: "Physics + Music"

**Mapping:**
- Velocity → Note pitch (faster = higher)
- Collision intensity → Sound volume
- Element type → Instrument (emoji = synth, circle = drum)
- Rest → Silence

**Result:** A physics simulation that generates procedural music from collisions and movement.

### SCAMPER: "Bouncing Ball"

**Apply REVERSE:**
- Instead of gravity pulling down, anti-gravity pushes up
- Ball falls "upward" and bounces off the top
- Visual: Invert the color scheme to reinforce the "upside-down" world

### Distance Association: "Chaos"

**Close:** Random movement, erratic colors  
**Medium:** Emergent flocking behavior with sudden phase transitions  
**Far:** Cellular automata rules applied to emoji states, creating unpredictable large-scale patterns from simple local rules

**Choose:** Medium — Implement boids (flocking) that occasionally "panic" and scatter, then reform.

---

## Remember

Creative divergence is not about complexity — it's about **intentional novelty**. A simple sketch with a clear, surprising concept beats a complex one with no creative focus.
