# Interaction

Firebox🔥 provides event-based input handling for keyboard, mouse/touch, and physics-based interactions.

## Event-Based Input System

**Important:** Firebox uses an event-based input system with callbacks, not polling. You cannot check `if (input.up())` inside an update loop.

### Correct Pattern

```javascript
// WRONG - This does NOT work:
update(() => {
  if (input.up()) {  // Firebox doesn't work this way!
    player.y -= 5;
  }
});

// CORRECT - Use event callbacks:
input.up((event) => {
  if (event.updated) {
    player.applyForce(0, -5);
  }
});
```

## Keyboard Input

### Directional Controls

All input functions take a callback that receives an event object:

```javascript
// Arrow keys
input.up((event) => {
  if (event.began) {
    // Key just pressed
  }
  if (event.updated) {
    // Key is being held down
    player.applyForce(0, -5);
  }
  if (event.ended) {
    // Key was released
  }
});

input.down((event) => {
  if (event.updated) {
    player.applyForce(0, 5);
  }
});

input.left((event) => {
  if (event.updated) {
    player.applyForce(-5, 0);
  }
});

input.right((event) => {
  if (event.updated) {
    player.applyForce(5, 0);
  }
});
```

### WASD Controls

```javascript
input.w((event) => {
  if (event.began) {
    // Jump on key press
    player.applyImpulse(0, -500);
  }
});

input.a((event) => {
  if (event.updated) {
    player.applyForce(-5, 0);
  }
});

input.s((event) => {
  if (event.updated) {
    player.applyForce(0, 5);
  }
});

input.d((event) => {
  if (event.updated) {
    player.applyForce(5, 0);
  }
});
```

### Action Keys

```javascript
input.space((event) => {
  if (event.began) {
    fireBullet();
  }
});
```

### Generic Key Handler

```javascript
input.key((event) => {
  // event.keyCode - the key code number
  // 38 = up arrow
  // 40 = down arrow
  // 37 = left arrow
  // 39 = right arrow
  // 32 = space
  // 87 = W
  // 65 = A
  // 83 = S
  // 68 = D

  if (event.keyCode == 38) {
    // Handle up arrow
  }
  if (event.keyCode == 32) {
    // Handle space
  }

  // Event phases
  if (event.began) {
    // Key just pressed
  }
  if (event.updated) {
    // Key is held
  }
  if (event.ended) {
    // Key released
  }
});
```

### Event Object Structure

```javascript
input.up((event) => {
  // event properties:
  event.keyCode;    // Number: key code
  event.phase;      // String: "began", "updated", or "ended"
  event.began;      // Boolean: true on key press
  event.updated;    // Boolean: true while held
  event.ended;      // Boolean: true on key release
});
```

### Combined Movement

```javascript
// Normalize diagonal movement
let dx = 0;
let dy = 0;

input.right((event) => {
  if (event.updated) dx = 1;
  if (event.ended) dx = 0;
});

input.left((event) => {
  if (event.updated) dx = -1;
  if (event.ended) dx = 0;
});

input.up((event) => {
  if (event.updated) dy = -1;
  if (event.ended) dy = 0;
});

input.down((event) => {
  if (event.updated) dy = 1;
  if (event.ended) dy = 0;
});

// In global update, normalize and apply
update(() => {
  if (dx !== 0 || dy !== 0) {
    // Normalize diagonal
    const len = Math.sqrt(dx * dx + dy * dy);
    if (len > 0) {
      player.applyForce((dx / len) * speed, (dy / len) * speed);
    }
  }
});
```

## Mouse and Touch Input

### Pointer Events

```javascript
input.point((event) => {
  // event properties:
  event.position.x;   // Number: x coordinate
  event.position.y;   // Number: y coordinate
  event.phase;        // String: "began", "updated", "ended"
  event.began;        // Boolean: true on touch/click start
  event.updated;      // Boolean: true while dragging
  event.ended;        // Boolean: true on release

  if (event.began) {
    // Click/touch started
    print("Started at:", event.position.x, event.position.y);
  }

  if (event.updated) {
    // Dragging
    follower.goTo(event.position.x, event.position.y);
  }

  if (event.ended) {
    // Released
    print("Released at:", event.position.x, event.position.y);
  }
});
```

### Element-Specific Click

```javascript
const button = display.rect(400, 300, 100, 60);

// Click on this specific element
button.clicked((event) => {
  // Called when element is clicked/tapped
  // event.self refers to the element
  button.color = color.hsb(120, 80, 80);
});

// Aliases
button.click((event) => {
  // Same as clicked
});

button.tap((event) => {
  // Same as clicked (mobile-friendly name)
});

// Point events on element
button.point((event) => {
  if (event.began) {
    // Touch started on element
  }
  if (event.ended) {
    // Touch ended on element
  }
});
```

### Drag and Drop

```javascript
const draggable = display.emoji("📦", 300, 300);
let isDragging = false;
let dragOffsetX = 0;
let dragOffsetY = 0;

// Handle pointer events
draggable.point((event) => {
  if (event.began) {
    isDragging = true;
    dragOffsetX = draggable.x - event.position.x;
    dragOffsetY = draggable.y - event.position.y;
    draggable.scale = 1.2;  // Visual feedback
  }

  if (event.updated && isDragging) {
    draggable.goTo(
      event.position.x + dragOffsetX,
      event.position.y + dragOffsetY
    );
  }

  if (event.ended) {
    isDragging = false;
    draggable.scale = 1.0;
  }
});

// Also need global pointer for dragging outside element
input.point((event) => {
  if (event.updated && isDragging) {
    draggable.goTo(
      event.position.x + dragOffsetX,
      event.position.y + dragOffsetY
    );
  }

  if (event.ended) {
    isDragging = false;
    draggable.scale = 1.0;
  }
});
```

### Follow Mouse/Touch

```javascript
const follower = display.emoji("👀", 0, 0);

// Smooth follow using input events
let targetX = 0;
let targetY = 0;
let hasTarget = false;

input.point((event) => {
  if (event.updated) {
    targetX = event.position.x;
    targetY = event.position.y;
    hasTarget = true;
  }
  if (event.ended) {
    hasTarget = false;
  }
});

// Smooth movement in update
follower.update((event) => {
  if (hasTarget) {
    // Lerp toward target
    follower.x += (targetX - follower.x) * 0.1;
    follower.y += (targetY - follower.y) * 0.1;

    // Point toward movement
    follower.pointTo({ x: targetX, y: targetY });
  }
});
```

### Click to Move

```javascript
const player = display.emoji("🏃", 400, 300);
let moveTarget = null;

input.point((event) => {
  if (event.began) {
    moveTarget = { x: event.position.x, y: event.position.y };
    player.pointTo(moveTarget);
  }
});

player.update((event) => {
  if (moveTarget) {
    // Move toward target
    player.move(3);

    // Check if arrived
    const dist = player.distanceTo({ position: moveTarget });
    if (dist < 5) {
      moveTarget = null;
    }
  }
});
```

## Physics

### Adding Physics Bodies

```javascript
// Create element and make it physical
const ball = display.circle(100, 100, 30);
physics.add(ball);

// With options
const box = display.rect(200, 200, 50, 50);
physics.add(box, {
  type: "dynamic",     // or "static", "kinematic"
  density: 1.0,        // mass calculation
  friction: 0.3,       // 0.0 to 1.0
  restitution: 0.5,   // bounce (0.0 to 1.0)
  bounce: 0.5,         // alias for restitution
  sensor: false,       // collision detection only
  static: false,     // set to true for immovable
  kinematic: false,   // controlled by code, not forces
  angularDamping: 0,   // rotation slowdown
  linearDamping: 0    // movement slowdown
});
```

### Physics Properties

```javascript
// Set gravity (default is 0, 9.8)
physics.setGravity(0, 10);

// Set position (teleport, respects collisions)
physics.setPosition(ball, 200, 300);
physics.setPosition(ball, { x: 200, y: 300 });

// Set angle in radians
physics.setAngle(ball, Math.PI / 4);
```

### Forces and Impulses

```javascript
// On elements with physics:

// Apply continuous force (like wind, gravity boost)
ball.applyForce(100, 0);  // xForce, yForce

// Apply instant impulse (like jumping, explosions)
ball.applyImpulse(0, -500);  // xImpulse, yImpulse

// Apply force in direction of element's angle
ball.moveForce(10);  // force value

// Apply impulse in direction of element's angle
ball.moveImpulse(10);  // impulse value

// Apply torque (rotation force)
ball.applyTorque(50);  // positive = clockwise
ball.applyTorque(-50); // negative = counter-clockwise

// Stop all movement
ball.stop();
```

### Static Bodies

```javascript
// Ground
world.ground();

// Static platforms (don't move)
const platform = display.rect(400, 500, 200, 20);
physics.add(platform, { static: true });
// or
physics.add(platform, { type: "static" });
```

### Kinematic Bodies

```javascript
// Kinematic bodies are controlled by code, not forces
// Good for moving platforms, elevators

const elevator = display.rect(400, 300, 100, 20);
physics.add(elevator, { kinematic: true });

// Move by setting position
physics.setPosition(elevator, 400, 200);
```

### Destroying Physics Bodies

```javascript
// Remove physics from element (element remains)
physics.destroyBody(ball);

// Element stays but no longer has physics
ball.color = color.hsb(0, 0, 50);  // grayed out
```

### Debug Visualization

```javascript
// Show physics bodies and collision shapes
physics.debug();
```

## Collision Detection

### Collision Events

```javascript
const player = display.emoji("🏃", 100, 300);
physics.add(player);

// Collision event handler
player.collision((event) => {
  if (event.began) {
    // Collision just started
    print("Hit something tagged:", event.tag);

    // event.other - the other element in collision
    // event.self - this element
    // event.tag - tag of other element
  }

  if (event.updated) {
    // Still colliding
  }

  if (event.ended) {
    // Collision ended (objects separated)
  }
});

// Check tag in collision
const coin = display.emoji("💰", 300, 300);
coin.tag = "coin";
physics.add(coin, { sensor: true });  // detect only, no bounce

player.collision((event) => {
  if (event.tag === "coin" && event.began) {
    // Collect coin
    event.other.destroy();
    score += 10;
  }
});
```

### Manual Collision Check

```javascript
// Check collision in update loop
player.update((event) => {
  enemies.forEach(enemy => {
    if (player.collide(enemy)) {
      // Collision detected
      takeDamage();
    }
  });
});
```

### Distance Check

```javascript
// Use built-in distance method
const dist = player.distanceTo(enemy);
if (dist < 50) {
  // Close enough
}

// Or check multiple
enemies.forEach(enemy => {
  if (player.distanceTo(enemy) < 50) {
    enemy.color = color.hsb(0, 80, 90);  // highlight
  }
});
```

## Camera

### Following a Target

**Important:** The default world size is 960x640. When using larger worlds, you must use `camera.follow()` or the view will show only a portion of the scene:

```javascript
// ⚠️ Using larger world - MUST use camera.follow()
world.set(2000, 1500);

const player = display.emoji("🤩", 100, 100);
physics.add(player);

// Camera follows player
camera.follow(player);  // REQUIRED for worlds larger than 960x640

// Player movement
input.right((event) => {
  if (event.updated) {
    player.applyForce(10, 0);
  }
});

input.left((event) => {
  if (event.updated) {
    player.applyForce(-10, 0);
  }
});
```

**Best Practice:** For most sketches, use the default 960x640 world size. Only use larger worlds for scrolling/exploration games, and always include `camera.follow(element)`.

## UI Interactions

### Button Clicks

```javascript
const btn = ui.button("Start!", 400, 300);

// Handle click
btn.action(() => {
  startGame();
});

// Aliases
btn.click(() => {
  startGame();
});

btn.clicked(() => {
  startGame();
});
```

### Progress Bar Updates

```javascript
const healthBar = ui.progress(100, 50, 200, 25);
healthBar.progressColor = color.hsb(0, 80, 80);
healthBar.trackColor = color.hsb(0, 0, 30);

// Update value (0.0 to 1.0)
healthBar.value = 0.75;  // 75%

// Update during game
player.collision((event) => {
  if (event.tag === "enemy" && event.began) {
    health -= 10;
    healthBar.value = health / maxHealth;
  }
});
```

### Dynamic Labels

```javascript
const scoreLabel = ui.label("Score", 50, 50);
scoreLabel.value = 0;

// Update when score changes
timer.every(1000, () => {
  score += 10;
  scoreLabel.value = score; // `value` is formatted "Score: ${value}"
});
```

## Game Mechanics

### Player Movement with Physics

```javascript
const player = display.emoji("🤖", 100, 300);
physics.add(player);

// Movement forces
const speed = 15;
const jumpForce = 300;
let onGround = false;

input.right((event) => {
  if (event.updated) {
    player.applyForce(speed, 0);
  }
});

input.left((event) => {
  if (event.updated) {
    player.applyForce(-speed, 0);
  }
});

input.space((event) => {
  if (event.began && onGround) {
    player.applyImpulse(0, -jumpForce);
    onGround = false;
  }
});

// Ground collision for jumping
world.ground();
player.collision((event) => {
  if (event.began && event.tag === "ground") {
    onGround = true;
  }
});
```

### Collectibles

```javascript
const player = display.circle(100, 100, 30);
physics.add(player);

// Spawn coins
const coins = [];
times(10, () => {
  const coin = display.emoji("💰", random.pos());
  coin.tag = "coin";
  physics.add(coin, { sensor: true });
  coins.push(coin);
});

let score = 0;
const scoreLabel = ui.label("Score", 50, 50);
scoreLabel.value = score;

// Collect on collision
player.collision((event) => {
  if (event.tag === "coin" && event.began) {
    score += 10;
    scoreLabel.value = score;

    // Visual feedback
    event.other.say("+10!", 500);
    event.other.destroy();
  }
});
```

### Shooting

```javascript
const player = display.emoji("🚀", 100, 300);
physics.add(player);

let lastShot = 0;
const fireRate = 200;  // milliseconds

input.space((event) => {
  if (event.began) {
    const now = Date.now();
    if (now - lastShot > fireRate) {
      lastShot = now;

      // Create bullet
      const bullet = display.circle(player.x + 30, player.y, 8);
      bullet.color = color.hsb(60, 90, 95);
      physics.add(bullet, { density: 0.1 });

      // Shoot
      bullet.applyImpulse(500, 0);

      // Destroy after delay
      timeout(2000, () => {
        bullet.destroy();
      });
    }
  }
});
```

### Enemy AI (Simple Patrol)

```javascript
const enemies = [];

times(5, () => {
  const enemy = display.emoji("👾", random.pos());
  physics.add(enemy, { friction: 1.0 });
  enemy.tag = "enemy";

  const enemyData = {
    el: enemy,
    direction: 1,
    speed: 5
  };

  // Patrol behavior
  enemy.update((event) => {
    enemy.applyForce(enemyData.speed * enemyData.direction, 0);

    // Turn at edges
    if (enemy.onEdgeX()) {
      enemyData.direction *= -1;
    }
  });

  enemies.push(enemyData);
});
```

## Timers

### Repeating Actions

```javascript
// timer.every takes milliseconds!
timer.every(1000, () => {
  // Called every 1 second
  spawnEnemy();
});

timer.every(5000, () => {
  // Called every 5 seconds
  increaseDifficulty();
});
```

### One-Time Delays

```javascript
// timeout takes milliseconds!
timeout(3000, () => {
  // Called after 3 seconds
  levelComplete();
});

// Use in sequence
const msg = ui.label("Get Ready!", 400, 300);

timeout(1000, () => {
  msg.text = "3";
});

timeout(2000, () => {
  msg.text = "2";
});

timeout(3000, () => {
  msg.text = "1";
});

timeout(4000, () => {
  msg.text = "Go!";
  startGame();
});
```

### Global Delay Setting

```javascript
// Set default delay for forever() and repeat()
delay(100);  // 100ms

repeat(10, () => {
  // Called 10 times with 100ms delay between
  spawnParticle();
});

forever(() => {
  // Called forever with 100ms delay
  updateWeather();
});
```

### Immediate Repetition

```javascript
// times() has no delay - immediate execution
times(10, (i) => {
  // Called 10 times immediately
  display.circle(100 + i * 50, 300, 20);
});
```

## Best Practices

- **Always use event callbacks** for input, never polling
- **Check `event.updated`** for continuous actions (holding key)
- **Check `event.began`** for one-shot actions (jump, fire)
- **Check `event.ended`** for release detection
- **Use `element.update()`** for per-element frame logic
- **Use global `update()`** for global game state
- **Remember timers are in milliseconds**, not seconds
- **Use element methods** (`move()`, `rotate()`, `pointTo()`) for convenience
- **Use physics methods** (`applyForce()`, `applyImpulse()`) for physics bodies
- **Set tags** on elements for collision identification
- **Clean up** destroyed elements from arrays to prevent memory leaks
