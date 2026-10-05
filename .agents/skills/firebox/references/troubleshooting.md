# Troubleshooting

Common issues and solutions when working with Firebox🔥.

## Performance Issues

### Low Frame Rate

**Symptoms:** Choppy animation, laggy response

**Solutions:**

```javascript
// Reduce element count
const MAX_PARTICLES = 50;  // Not 500

// Use element.update() instead of global update loops
// Good - self-contained element updates:
const particle = display.circle(100, 100, 10);
particle.update((event) => {
  particle.move(2);
});

// Less efficient - checking all in global update:
const particles = [];
update(() => {
  particles.forEach(p => {
    if (p.active) p.move(2);
  });
});

// Limit physics bodies
const MAX_PHYSICS = 30;  // Physics is expensive

// Clean up destroyed elements
for (let i = array.length - 1; i >= 0; i--) {
  if (!array[i].active) {
    array.splice(i, 1);
  }
}
```

### Memory Leaks

**Symptoms:** Slow degradation over time, eventual crash

**Solutions:**

```javascript
// Always clean up destroyed elements from arrays
// Bad:
bullets.forEach(b => {
  if (b.x > width) {
    b.destroy();
  }
});
// b is destroyed but still in array!

// Good:
for (let i = bullets.length - 1; i >= 0; i--) {
  if (bullets[i].x > width) {
    bullets[i].destroy();
    bullets.splice(i, 1);
  }
}

// Or use filter
enemies = enemies.filter(e => e.active);
```

## Physics Issues

### Bodies Not Moving

**Check:**
- Did you call `physics.add()`?
- Are you using physics methods (applyForce) vs direct position (goTo)?

```javascript
// Good:
const ball = display.circle(100, 100, 30);
physics.add(ball);
ball.applyForce(100, 0);  // this works

// This bypasses physics:
ball.goTo(200, 200);  // teleports, ignores physics
```

### Tunneling (Objects Pass Through Each Other)

**Cause:** High velocity, thin objects, low frame rate

**Solutions:**

```javascript
// Limit velocities
ball.update((event) => {
  // Cap max speed
  // (Physics engine handles this internally mostly)
});

// Make collision shapes thicker
// Use larger circles instead of thin lines for physics

// Use sensors for detection-only
display.circle(100, 100, 30).collision((event) => {
  // Detect without physical bounce
});
```

### Jittery Physics

**Cause:** Conflicting forces, too many forces per frame

**Solutions:**

```javascript
// Apply forces in update, not in input callback
// Good:
const player = display.circle(100, 100, 30);
physics.add(player);

let moveRight = false;
input.right((event) => {
  if (event.updated) moveRight = true;
  if (event.ended) moveRight = false;
});

player.update((event) => {
  if (moveRight) {
    player.applyForce(10, 0);
  }
});

// Use impulses for sudden changes (jumps)
input.space((event) => {
  if (event.began) {
    player.applyImpulse(0, -300);
  }
});
```

## Input Issues

### Input Not Responding

**Common mistakes:**
- Trying to poll input in update loop (Firebox is event-based!)
- Not using the correct callback structure

**Wrong approach:**
```javascript
// This does NOT work in Firebox:
update(() => {
  if (input.up()) {  // Error! Firebox doesn't work this way
    player.y -= 5;
  }
});
```

**Correct approach:**
```javascript
// Use event callbacks:
input.up((event) => {
  if (event.updated) {
    player.applyForce(0, -5);
  }
});

input.point((event) => {
  if (event.began) {
    console.log("Clicked at:", event.position.x, event.position.y);
  }
});
```

### Event Object Structure

```javascript
input.key((event) => {
  // event.keyCode - key code number
  // event.phase - "began", "updated", or "ended"
  // event.began - true on key press
  // event.updated - true while holding
  // event.ended - true on release
});

input.point((event) => {
  // event.position.x - x coordinate
  // event.position.y - y coordinate
  // event.phase - "began", "updated", "ended"
  // event.began - true on touch/click start
  // event.updated - true while dragging
  // event.ended - true on release
});

// Element-specific
element.point((event) => {
  // Same as above but only for this element
  // event.self - reference to this element
});

element.collision((event) => {
  // event.phase - "began", "updated", "ended"
  // event.tag - tag of other element
  // event.other - other element in collision
  // event.self - this element
});
```

## Display Issues

### Elements Not Visible

**Check:**
- Position is within world bounds
- `active` property is `true`
- `alpha` is greater than 0
- Not behind another element (z-order)
- Color is not fully transparent

**Debug:**

```javascript
// Add visual debug
const element = display.circle(x, y, 30);
element.color = color.hsb(0, 80, 90, 100);  // Bright red, full alpha
element.borderColor = color.hsb(0, 0, 100, 100);  // White border
element.borderWidth = 3;

// Check properties
print("Position:", element.x, element.y);
print("Active:", element.active);
print("Alpha:", element.alpha);
print("Scale:", element.scale);

// Check bounds
if (element.x < 0 || element.x > world.width) {
  console.warn("Element off-screen horizontally");
}
```

### Z-Order Issues

**Cause:** Elements rendered in creation order

**Solutions:**

```javascript
// Last created = on top
// Create background first:
const bg = display.rect(0, 0, world.width, world.height);
bg.color = color.hsb(220, 40, 30, 100);
bg.borderWidth = 0;

// Then foreground:
const player = display.emoji("🏃", 100, 100);

// Change order with methods:
player.moveToFront();  // move on top
bg.moveToBack();       // move behind
```

### Color Not Working

**Check:**
- Using correct color function: `color.hsb()` or `color.rgb()`
- Values in valid ranges (HSB: H:0-360, S:0-100, B:0-100, A:0-100)
- Alpha is set (defaults to 100 if not specified)

**Solutions:**

```javascript
// Correct HSB with alpha
const valid = color.hsb(200, 80, 90, 100);  // full opacity

// Common mistakes:
// RGB in HSB function
const wrong = color.hsb(255, 128, 64);  // These are RGB values!

// Use RGB for RGB values
const rgbColor = color.rgb(255, 128, 64, 100);

// Check alpha
console.log(element.alpha);  // should be > 0
```

## Logic Issues

### Code Not Running

**Check:**
- No syntax errors (check browser console with F12)
- Functions called correctly
- Variables defined before use

**Debug:**

```javascript
// Add console logs
print("Setup starting");

const element = display.circle(100, 100, 50);
print("Element created:", element);

update(() => {
  print("Global update running");
});

element.update((event) => {
  print("Element update running");
  element.x += 1;
});

print("Setup complete");
```

### Variable Scope Issues

**Problem:** Variables not accessible in callbacks

```javascript
// Wrong:
function setup() {
  const player = display.circle(100, 100, 30);
}
update(() => {
  player.x += 1;  // Error! player not defined
});

// Right:
let player;  // Declare at top level

function init() {
  player = display.circle(100, 100, 30);
}

player.update((event) => {
  player.x += 1;  // Works!
});

// Or use objects for organization
const game = {
  player: null,
  enemies: [],
  score: 0
};

game.player = display.circle(100, 100, 30);
```

### Infinite Loops

**Symptoms:** Browser freeze, "Page Unresponsive" error

**Solutions:**

```javascript
// Avoid infinite loops
// Bad - infinite loop inside timer:
forever(() => {
  while (true) {  // This freezes!
    // do something
  }
});

// Good - use condition that becomes false:
let count = 10;
forever(() => {
  if (count > 0) {
    count--;
    // do something
  }
});

// Or use times() for finite repetition
times(10, () => {
  // Runs exactly 10 times
});
```

## Common Errors

### "undefined" or "null" errors

```javascript
// Check before use
if (element && element.active) {
  element.x += 1;
}

// Safe array access
if (array[i] && array[i].active) {
  array[i].doSomething();
}

// Check input event exists
input.point((event) => {
  if (event && event.position) {
    console.log(event.position.x);
  }
});
```

### Type Errors

```javascript
// Ensure numbers
const x = Number(someValue);
const y = parseInt(otherValue);

// Check type
console.log(typeof value, value);

// Safe math
const result = (Number(a) || 0) + (Number(b) || 0);
```

## Camera and World Issues

### Scene Only Shows Partial View / Elements Disappear

**Symptoms:** When using `world.set()` with larger dimensions, you only see part of the scene or elements appear to disappear.

**Cause:** The default world size is 960x640. When you set a larger world, the camera doesn't automatically pan - it shows a 960x640 viewport into the larger world.

**Solutions:**

```javascript
// ✗ WRONG: Large world without camera follow
world.set(2000, 1500);
const player = display.emoji("🏃", 100, 100);
player.update((event) => {
  player.move(5);  // Player moves off-screen quickly!
});
// View only shows the top-left 960x640 of the 2000x1500 world

// ✓ CORRECT: Use camera.follow() for larger worlds
world.set(2000, 1500);
const player = display.emoji("🏃", 100, 100);
physics.add(player);

camera.follow(player);  // Camera pans to follow player

player.update((event) => {
  player.move(5);
});

// ✓ BETTER: Stick to default size for most sketches
// No world.set() needed - uses 960x640
const elem = display.emoji("🎯", display.center);
elem.update((event) => {
  elem.move(3);
  elem.ifOnEdgeBounce();
});
```

**Best Practice:**
- **Default size (960x640):** Works perfectly for most sketches - no camera needed
- **Larger worlds:** Only use for scrolling/exploration games
- **Always use** `camera.follow(element)` with larger worlds
- **Never use** larger worlds without camera follow (view will be wrong)

## Debugging Tips

### Console Logging

```javascript
// Log values
print("Position:", x, y);

// Log objects
print("Element:", JSON.stringify({
  x: element.x,
  y: element.y,
  active: element.active
}));

// Conditional logging
const DEBUG = true;
if (DEBUG) {
  print("Debug info");
}

// Group logs
console.group("Update");
console.log("Player pos:", player.x, player.y);
console.log("Enemy count:", enemies.length);
console.groupEnd();
```

### Visual Debugging

```javascript
// Draw debug point
const debugPoint = display.circle(x, y, 5);
debugPoint.color = color.hsb(0, 100, 100, 100);  // Bright red
debugPoint.borderWidth = 0;

// Show collision bounds
const debugBounds = display.rect(x, y, w, h);
debugBounds.color = color.hsb(120, 100, 50, 30);  // Green, semi-transparent
debugBounds.borderWidth = 2;
debugBounds.borderColor = color.hsb(120, 100, 100, 100);

// Remove after delay
timeout(1000, () => {
  debugPoint.destroy();
  debugBounds.destroy();
});

// Show physics debug
physics.debug();
```

### Performance Profiling

```javascript
// Time a function
console.time("update");
// ... code ...
console.timeEnd("update");  // "update: 0.5ms"

// Count update calls
let updateCount = 0;
update(() => {
  updateCount++;
  if (updateCount % 60 === 0) {
    print("60 frames passed");
  }
});

// Check element count
print("Total elements:", display.length);
```

## Timer Issues

### Timers Not Working

**Common mistake:** Using seconds instead of milliseconds

```javascript
// WRONG - too fast, executes immediately
timer.every(1, () => {
  // This tries to run every 1 millisecond!
});

// CORRECT - use milliseconds
timer.every(1000, () => {
  // Runs every 1 second
});

timeout(3000, () => {
  // Runs after 3 seconds
});
```

### Setting Default Delay

```javascript
// Set default delay for forever() and repeat()
delay(50);  // 50ms between calls

repeat(10, () => {
  // Called 10 times with 100ms between
  spawnParticle();
});

delay(100);  // 100ms between calls for forever

forever(() => {
  // Called forever with 100ms delay
});
```

## Browser-Specific Issues

### Firefox
- Performance may differ from Chrome
- Test on target browser

### Safari
- Some JavaScript features may behave differently
- Use standard ES6 syntax only

### Mobile Browsers
- Touch input works through `input.point()`
- Screen size varies - use `world.width`, `world.height`
- Performance may be reduced

## Getting Help

### Resources
- Firebox documentation: https://firebox.no/docs
- Examples: https://firebox.no/examples
- Book: "20 Games with Firebox🔥"

### Debugging Steps
1. Check browser console for errors (F12)
2. Add console.log statements
3. Isolate the problematic code
4. Test in different browser
5. Simplify to minimal reproduction case

### Minimal Example Template

```javascript
// Minimal test case
world.set(800, 600);

const test = display.circle(400, 300, 50);
test.color = color.hsb(200, 80, 90, 100);

print("Element created:", test);

test.update((event) => {
  test.rotate(1);
  print("Rotating, angle:", test.angle);
});

input.point((event) => {
  if (event.began) {
    print("Clicked at:", event.position);
    test.color = color.hsb(0, 80, 90, 100);  // Red on click
  }
});
```
