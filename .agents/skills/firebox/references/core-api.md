# Core API Reference

## World Setup

### World Configuration

```javascript
// Set world bounds (default is 960x640)
world.set(1200, 800);
// or
world.set({ width: 1200, height: 800 });

// Create physics frame around world
world.frame(1000, 600);

// Create ground at bottom
world.ground();
```

### World Frame

The world frame creates boundaries for physics:

```javascript
world.frame(1000, 600);
// Creates invisible walls at world edges
```

### World Size Best Practices

**Important:** The default world size is 960x640, which matches the display viewport. When using larger world sizes, the camera will only show a portion of the world unless you follow an element:

```javascript
// ✓ GOOD: Stick to default size for most sketches
// No world.set() needed - uses default 960x640

// ⚠️ CAUTION: When using larger worlds, use camera.follow()
world.set(2000, 1500);

const player = display.emoji("🏃", 100, 100);
physics.add(player);

// Essential: Follow a moving element or the view will be wrong
camera.follow(player);

// Now as player moves, camera pans to follow
player.update((event) => {
  player.move(3);
});
```

**Recommendation:** For most sketches, stick to the default 960x640 world size. Only use larger worlds when you specifically need scrolling or exploration gameplay, and always use `camera.follow(element)` to keep the view correct.

## Display Properties

### Screen Dimensions

```javascript
// Display dimensions (default: 960x640)
const w = display.width;
const h = display.height;

// Center point
const cx = display.cx;          // x coordinate of center
const cy = display.cy;          // y coordinate of center
const center = display.center;    // { x, y } object

// Usage examples
display.circle(display.center, 50);
display.rect(display.width / 2 - 50, display.height - 100, 100, 100);
display.emoji("🎯", display.cx, display.cy);
```

### Background Color

```javascript
// Set background color for entire display
display.color = color.hsb(200, 40, 30, 100);
display.color = color.hsb(0, 0, 92, 100);  // Light gray
display.color = color.black;
display.color = color.white;
```

### Iterating Elements

```javascript
// Apply to ALL elements
display.all((elem) => {
  elem.color = color.hsb(random.num(0, 360), 75, 95);
});

// Animate all elements
timer.every(1000, () => {
  display.all((elem) => {
    elem.animate(500, (to) => {
      to.position = random.pos();
    });
  });
});

// Process elements by TAG
display.each("enemy", (enemy) => {
  enemy.color = color.hsb(0, 80, 90, 100);
});

display.each("circle", (circle) => {
  circle.radius += 2;
});

// Add all elements to physics
physics.add(display.elements);
```

## Element Basics

### Creating Elements

All display functions return Element objects:

```javascript
// Emoji
const face = display.emoji("😊", 100, 100);

// Shapes
const box = display.rect(100, 100, 50, 50);
const ball = display.circle(200, 200, 30);
const tri = display.polygon(300, 100, 40, 3);
const star = display.star(400, 100, 50);
const heart = display.heart(500, 100, 40);
const cloud = display.cloud(600, 100, 45);
const ghost = display.ghost(200, 200, 25);

// Lines
const line = display.line(100, 100, 200, 200);

// Ellipses
const ellipse = display.ellipse(300, 300, 40, 60);

// Bubbles (with text)
const bubble = display.bubble("Hello!", 400, 300);
```

### Common Element Properties

All elements share these properties:

```javascript
const element = display.circle(100, 100, 50);

// Position - multiple ways to access
element.position.x = 200;
element.position.y = 300;
element.x = 200;  // direct
element.y = 300;  // direct

// Set position
element.goTo(200, 300);  // instant
element.goTo({ x: 200, y: 300 });  // with point object
element.setX(200);  // set x only
element.setY(300);  // set y only

// Relative movement
element.changeX(5);  // add 5 to x
element.changeY(-3);  // add -3 to y
element.shift(1, 0);  // shift by sizes

// Size (read-only for most, settable for rect/line)
element.size.width;
element.size.height;
element.width;  // for rectangles, lines
element.height;  // for rectangles, lines

// Scale
element.scale = 1.5;  // 1.0 is default

// Rotation (degrees)
element.angle = 45;
element.angleOffset = 90;

// Rotation methods
element.rotate(5);  // add to angle
element.turnRight(10);  // clockwise
element.turnLeft(10);  // counter-clockwise
element.pointInDirection(90);  // set absolute angle
element.pointTo(other);  // rotate to face element or point

// Alpha (0-100, 0=transparent, 100=opaque)
element.alpha = 50;  // 50% transparent

// Visibility
element.active = true;   // visible
element.active = false;  // hidden
element.hide();  // hide element
element.show();  // show element
element.hidden();  // returns true/false

// Flip
element.flip = true;  // flip horizontally

// Colors (use color.hsb or color.rgb)
element.color = color.hsb(200, 80, 90);  // HSB
element.color = color.hsb(200, 80, 90, 50);  // HSB with alpha
element.color = color.rgb(255, 128, 64, 100);  // RGB
element.color = color.black;  // predefined
element.color = color.white;  // predefined
element.color = color.clear;  // transparent
element.color = element.color.clone();  // clone a color

// Color manipulation
element.color = element.color.darker();  // make darker
element.color = element.color.darker(3);  // darker by 3 steps
element.color = element.color.lighter();  // make lighter
element.color = element.color.lighter(5);  // lighter by 5 steps

// Border/Stroke
element.borderColor = color.hsb(0, 0, 100, 100);
element.borderWidth = 2;

// Type and tag (read-only type, settable tag)
console.log(element.type);  // "circle", "emoji", etc.
element.tag = "player";   // for identification

// Destroy
element.destroy();
element.remove();

// Wait/pause animation
element.wait(1000);  // wait 1 second

// Speech bubble
element.say("Hello!");  // show temporarily
element.say("Hello!", 2000);  // show for 2 seconds (ms)

// Stop all animations
element.stopAnimations();

// Animation
element.animate(duration, (anim) => { ... }, callback);
element.animate({duration, delay, easing, autoreverse}, (anim) => { ... }, callback);
element.animateKeyframe((anim) => { anim.keyframe(100, (to) => { ... }) });
```

## Subelements and Parent-Child Relationships

Create composite objects by adding elements as children of other elements. Child elements are positioned relative to their parent and inherit all transformations (movement, rotation, scaling).

```javascript
// Create a parent element
const parent = display.rect(display.center, 200, 200);
parent.color = color.skyblue;

// Create child elements positioned relative to parent center (0, 0)
const child1 = display.circle(-50, -50, 25);  // top-left
const child2 = display.circle(50, -50, 25);   // top-right
const child3 = display.circle(50, 50, 25);    // bottom-right
const child4 = display.circle(-50, 50, 25);   // bottom-left

// Add children to parent
parent.add(child1);
parent.add(child2);
parent.add(child3);
parent.add(child4);

// Now all children move/rotate with the parent
update(() => {
  parent.pointTo(input);  // parent rotates toward mouse
  parent.move(2);         // parent moves, children follow
  // All children automatically rotate and move with parent!
});
```

### Multi-Level Nesting

Subelements can have their own subelements, creating complex hierarchies:

```javascript
// Parent → Child → Grandchild
const body = display.rect(display.center, 100, 100);
const head = display.circle(0, -80, 40);
const eye = display.circle(-10, -10, 8);
const pupil = display.circle(0, 0, 3);

body.add(head);    // head attached to body
head.add(eye);     // eye attached to head
eye.add(pupil);    // pupil attached to eye

// Factory shortcuts for simple shapes
const leftEye = Circle(-15, -10, 5);   // creates a circle directly
const rightEye = Circle(15, -10, 5);
head.add(leftEye);
head.add(rightEye);
```

### Relative Positioning

Child positions are relative to the parent's center:

```javascript
// Child at (0, 0) appears at parent's center
const centered = display.circle(0, 0, 20);
parent.add(centered);

// Negative x = left of parent, positive x = right
// Negative y = above parent, positive y = below
const topLeft = display.circle(-50, -50, 15);
const bottomRight = display.circle(50, 50, 15);
parent.add(topLeft);
parent.add(bottomRight);
```

### Building Complex Objects

Use subelements to create detailed composite objects:

```javascript
// Create a car with wheels
const car = display.rect(display.center, 120, 60);
car.color = color.hsb(0, 70, 80);

// Wheels positioned relative to car body
const wheel1 = display.circle(-40, 35, 20);
const wheel2 = display.circle(40, 35, 20);
wheel1.color = color.hsb(0, 0, 20);
wheel2.color = color.hsb(0, 0, 20);

car.add(wheel1);
car.add(wheel2);

// Drive the car
update(() => {
  car.move(3);
  car.pointTo(input);
  // Wheels move and rotate with the car automatically
});
```

### Adding UI Elements to Display Elements

UI elements can also be added as children:

```javascript
const panel = display.rect(0, 0, 200, 100);
panel.color = color.hsb(220, 40, 30);

const button = ui.button("Click Me", 0, 0);
button.action(() => {
  console.log("Button clicked!");
});

// Add button to the display element
panel.add(button);

// Move the panel - button moves with it
panel.moveTo(300, 200);
```

### Key Behaviors

- **Transform inheritance**: Children inherit parent's position, rotation, and scale
- **Relative coordinates**: Child (0, 0) is at parent's center
- **Deep nesting**: Unlimited levels of parent-child relationships
- **Factory functions**: Use `Circle()`, `Rectangle()` for quick child creation
- **Mixed types**: UI elements can be added to display elements and vice versa

## Coordinate System

- Origin: top-left (0, 0)
- X increases rightward
- Y increases downward
- Angles: degrees (0-360)

```javascript
// Center of display
const cx = display.cx;
const cy = display.cy;

// Random position
const pos = random.position();
```

## Element Update Loop

Firebox has two update mechanisms:

### Global Update

```javascript
update(() => {
  // Runs every frame (~60fps)
  // Game logic, global state management
});
```

### Element-Specific Update

```javascript
const element = display.circle(100, 100, 50);

element.update((event) => {
  // Runs every frame for this specific element
  // event.self refers to the element

  // Built-in movement
  element.move(2);  // move in direction of angle
});
```

### Frame Control

```javascript
// Check if element is still valid
if (element && element.active) {
  // safe to use
}

// Stop processing (but keep element)
element.active = false;

// Resume processing
element.active = true;

// Permanently remove
element.destroy();

// Wait/pause
element.wait(1000);  // wait 1 second
```

## Positioning and Movement

### Direct Position Setting

```javascript
// Absolute positioning - multiple methods
element.position.x = 100;
element.position.y = 200;
element.x = 100;
element.y = 200;
element.goTo(100, 200);
element.goTo({ x: 100, y: 200 });
```

### Movement Methods

```javascript
// Move in direction of current angle
element.angle = 45;
element.move(10);  // moves 10 pixels at 45 degrees

// Move to target with animation
element.moveTo(300, 400);  // animated movement
element.moveTo({ x: 300, y: 400 });

// Follow another element or input
element.follow(targetElement, 2);  // follow at speed 2
element.pointTo(targetElement);  // rotate to face target

// Relative changes
element.changeX(5);  // add 5 to x
element.changeY(-3);  // subtract 3 from y
element.shift(1, 0);  // shift by element sizes
```

### Rotation

```javascript
// Set absolute rotation (degrees)
element.angle = 45;
element.pointInDirection(90);

// Relative rotation
element.rotate(5);
element.turnRight(10);  // clockwise
element.turnLeft(10);  // counter-clockwise

// Point toward position or element
element.pointTo(otherElement);
element.pointTo({ x: 200, y: 300 });  // point to coordinates
element.pointTo(input);  // point to mouse/touch
```

### Edge Handling

```javascript
// In element.update() callback
element.update((event) => {
  element.move(2);

  // Bounce off edges
  element.ifOnEdgeBounce();

  // Or wrap around
  element.ifOnEdgeContinue();

  // Check edges manually
  if (element.onEdge()) {
    console.log("On any edge");
  }
  if (element.onEdgeX()) {
    console.log("On left or right edge");
  }
  if (element.onEdgeY()) {
    console.log("On top or bottom edge");
  }

  // Check if in view/world
  if (element.inView()) {
    // Visible in camera view
  }
  if (element.inWorld()) {
    // Inside world bounds
  }
  if (element.notInView()) {
    // Outside camera view
  }
});
```

### Bouncing

```javascript
// Manual bounce
element.update((event) => {
  element.move(2);

  if (element.x > 500) {
    element.bounceX();  // mirror x direction
  }
  if (element.y > 500) {
    element.bounceY();  // mirror y direction
  }
});
```

## Element Manipulation

### Changing Appearance

```javascript
// Scale
element.scale = 2.0;  // double size
element.scale = 0.5;  // half size

// Alpha
element.alpha = 1.0;   // fully visible
element.alpha = 0.5;   // 50% transparent
element.alpha = 0.0;   // invisible

// Hide/show
element.hide();
element.show();
if (element.hidden()) {
  element.show();
}

// Color
element.color = color.hsb(200, 80, 90);
element.color = color.hsb(200, 80, 90, 50);  // with alpha

// Color manipulation
element.color = element.color.darker(2);
element.color = element.color.lighter(3);
const clonedColor = element.color.clone();

// Border
element.borderColor = color.hsb(0, 0, 100, 100);
element.borderWidth = 2;

// Flip
element.flip = true;
element.flip = false;
```

### Drawing Order

```javascript
// Change z-order
element.moveToFront();  // draw on top
element.moveToBack();   // draw behind

// Last created = on top by default
// Create background first
const bg = display.rect(0, 0, display.width, display.height);
bg.color = color.hsb(220, 40, 30, 100);

// Then foreground:
const player = display.emoji("🏃", 100, 100);
```

### Element State Management

```javascript
// Check if element is still valid
if (element && element.active) {
  // safe to use
}

// Safe destroy
function safeDestroy(el) {
  if (el && el.active) {
    el.destroy();
  }
}

// Speech bubble
element.say("Hello!");  // show temporarily
element.say("Hello!", 2000);  // show for 2 seconds

// Distance check
const dist = element.distanceTo(otherElement);
if (dist < 100) {
  // Close enough
}
```

## Math Utilities

Firebox uses standard JavaScript Math, plus these helpers:

```javascript
// Point creation
const point = Point(100, 200);  // or { x: 100, y: 200 }

// Distance
function dist(x1, y1, x2, y2) {
  return Math.sqrt((x2-x1)**2 + (y2-y1)**2);
}

// Trigonometry (available globally)
const x = Math.cos(angle) * radius;
const y = Math.sin(angle) * radius;

// Map value from one range to another
function map(value, start1, stop1, start2, stop2) {
  return start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1));
}

// Constrain
function constrain(value, min, max) {
  return Math.min(Math.max(value, min), max);
}

// Linear interpolation
function lerp(start, stop, amt) {
  return start + (stop - start) * amt;
}

// Random (Firebox provides random.*)
const n = random.number(0, 100);
const pos = random.position();
```

## Composition Patterns

### Grid Layout

```javascript
const cols = 10;
const rows = 8;
const cellW = display.width / cols;
const cellH = display.height / rows;

times(cols * rows, (i) => {
  const col = i % cols;
  const row = Math.floor(i / rows);
  const x = col * cellW + cellW / 2;
  const y = row * cellH + cellH / 2;
  display.rect(x, y, cellW - 5, cellH - 5);
});
```

### Radial Layout

```javascript
const n = 12;
const cx = display.cx;
const cy = display.cy;
const radius = 200;

times(n, (i) => {
  const angle = (i / n) * Math.PI * 2;
  const x = cx + Math.cos(angle) * radius;
  const y = cy + Math.sin(angle) * radius;
  display.circle(x, y, 20);
});
```

### Spiral Layout

```javascript
const cx = display.cx;
const cy = display.cy;
const count = 50;

times(count, (i) => {
  const angle = i * 0.5;  // 0.5 radians per step
  const r = i * 5;        // 5px per step
  const x = cx + Math.cos(angle) * r;
  const y = cy + Math.sin(angle) * r;
  display.circle(x, y, 10);
});
```

### Margin-Aware Layout

```javascript
const MARGIN = 80;
const drawW = display.width - 2 * MARGIN;
const drawH = display.height - 2 * MARGIN;

function mapX(t) { return MARGIN + t * drawW; }
function mapY(t) { return MARGIN + t * drawH; }

// Use normalized 0-1 coordinates
const element = display.rect(mapX(0.5), mapY(0.3), 100, 100);
```

## Fill and Stroke Defaults

```javascript
// Set default fill color for new elements
fill(color.hsb(200, 80, 90, 100));

// Set default stroke/border for new elements
stroke(color.hsb(0, 0, 0, 100), 2);  // color and width

// Now new elements will use these defaults
const rect = display.rect(100, 100, 50, 50);  // uses fill/stroke above
```

## Performance Tips

### Efficient Updates

```javascript
// Use element.update() for element-specific logic
// instead of checking in global update

// Good:
const particle = display.circle(100, 100, 10);
particle.update((event) => {
  particle.move(2);
  if (particle.onEdge()) {
    particle.destroy();
  }
});

// Less efficient:
const particles = [];
update(() => {
  particles.forEach(p => {
    if (p.active) {
      p.move(2);
      // ...
    }
  });
});
```

### Object Pooling

```javascript
// Reuse elements instead of creating/destroying
const pool = [];
const maxPool = 20;

function getBullet() {
  // Find inactive bullet
  const bullet = pool.find(b => !b.active);
  if (bullet) {
    bullet.show();
    bullet.goTo(0, 0);
    return bullet;
  }

  // Create new if pool not full
  if (pool.length < maxPool) {
    const b = display.circle(0, 0, 5);
    b.hide();
    pool.push(b);
    return getBullet();
  }

  return null;
}

function returnBullet(bullet) {
  bullet.hide();
  bullet.goTo(-1000, -1000);  // move off-screen
}
```

### Cleanup

```javascript
// Clean up destroyed elements from arrays
const particles = [];

times(10, () => {
  const p = display.circle(random.pos(), 10);
  particles.push(p);
});

update(() => {
  // Remove inactive from array
  for (let i = particles.length - 1; i >= 0; i--) {
    if (!particles[i].active) {
      particles.splice(i, 1);
    }
  }
});
```
