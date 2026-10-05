# Visual Effects

## Color Effects

### Color Cycling

```javascript
const element = display.circle(300, 400, 50);

element.color.saturation = 80
element.color.brightness = 90

let hue = 0;
element.update((event) => {
  hue = (hue + 1) % 360;
  element.color.hue = hue
});
```

### Color with Alpha

```javascript
const ghost = display.circle(300, 300, 60);
// HSB with alpha (0-100)
ghost.color = color.hsb(200, 40, 90, 50);  // 50% transparent
ghost.borderWidth = 0;

// Fade in/out
let alpha = 0;
let fadingIn = true;

ghost.update((event) => {
  if (fadingIn) {
    alpha += 1;
    if (alpha >= 100) fadingIn = false;
  } else {
    alpha -= 1;
    if (alpha <= 0) fadingIn = true;
  }
  //ghost.color = color.hsb(200, 40, 90, alpha);
  ghost.color.alpha = alpha
});
```

### Color Pulses

```javascript
const sun = display.circle(400, 300, 80);
let pulse = 0;

sun.update((event) => {
  pulse += 0.05;
  const brightness = 70 + Math.sin(pulse) * 20;  // 50-90
  sun.color = color.hsb(45, 90, brightness, 100);
});
```

### Color Transitions

```javascript
// Lerp between two colors manually
function lerpColor(h1, s1, b1, h2, s2, b2, t) {
  return color.hsb(
    h1 + (h2 - h1) * t,
    s1 + (s2 - s1) * t,
    b1 + (b2 - b1) * t,
    100
  );
}

const element = display.rect(100, 100, 100, 100);
let t = 0;

element.update((event) => {
  t = (t + 0.01) % 1;
  // Transition from blue to red
  element.color = lerpColor(200, 80, 80, 0, 80, 80, t);
});
```

## Simple Particle Systems

### Basic Particles

```javascript
const particles = [];

function spawnParticle(x, y) {
  const p = display.circle(x, y, random.num(2, 8));
  p.color = color.hsb(random.number(0, 360), 70, 90, 80);
  p.borderWidth = 0;

  const particle = {
    el: p,
    vx: random.num(-3, 3),
    vy: random.num(-3, 3),
    life: 100
  };

  particles.push(particle);

  // Self-contained particle update
  p.update((event) => {
    p.x += particle.vx;
    p.y += particle.vy;
    particle.life -= 2;

    // Fade by alpha
    const alpha = Math.max(0, particle.life);
    p.color = color.hsb(
      (p.color.hue || 200),
      (p.color.saturation || 70),
      (p.color.brightness || 90),
      alpha
    );

    if (particle.life <= 0) {
      p.destroy();
    }
  });
}

// Spawn on timer
timer.every(200, () => {  // every 200ms
  spawnParticle(400, 300);
});
```

### Emoji Particles

```javascript
const emojis = ["✨", "⭐", "💫", "🌟"];
const stars = [];

times(20, () => {
  const star = display.emoji(emojis[Math.floor(random.number(0, emojis.length))],
                           random.pos());
  star.scale = random.num(0.5, 1.5);
  star.alpha = random.num(50, 100);

  stars.push({
    el: star,
    speed: random.num(0.5, 2),
    wobble: random.number(0, Math.PI * 2),
    wobbleSpeed: random.num(0.02, 0.05),
    baseX: star.x
  });

  star.update((event) => {
    star.y -= star.speed;
    star.wobble += star.wobbleSpeed;
    star.x = star.baseX + Math.sin(star.wobble) * 30;

    // Reset if off-screen
    if (star.y < -50) {
      star.y = world.height + 50;
      star.x = random.number(0, world.width);
      star.baseX = star.x;
    }
  });
});
```

### Physics-Based Particles

```javascript
function explode(x, y, baseColor) {
  times(30, () => {
    const p = display.circle(x, y, random.num(3, 10));
    p.color = baseColor;
    p.borderWidth = 0;
    physics.add(p, { density: 0.1 });

    const angle = random.number(0, Math.PI * 2);
    const speed = random.num(200, 500);
    const vx = Math.cos(angle) * speed;
    const vy = Math.sin(angle) * speed;

    p.applyImpulse(vx, vy);

    // Fade and destroy
    let life = 100;
    p.update((event) => {
      life -= 2;
      if (life <= 0) {
        p.destroy();
      }
    });
  });
}

// Trigger on click
display.rect(0, 0, world.width, world.height).clicked((event) => {
  explode(event.position.x, event.position.y, color.hsb(45, 90, 90));
});
```

## Patterns

### Checkerboard

```javascript
const cols = 8;
const rows = 8;
const cellW = world.width / cols;
const cellH = world.height / rows;

times(cols * rows, (i) => {
  const col = i % cols;
  const row = Math.floor(i / cols);
  const cell = display.rect(
    col * cellW,
    row * cellH,
    cellW,
    cellH
  );

  // Alternate colors
  const isEven = (col + row) % 2 === 0;
  cell.color = color.hsb(isEven ? 0 : 0, 0, isEven ? 90 : 30);
  cell.borderWidth = 0;
});
```

### Stripes

```javascript
const count = 20;
const stripeW = world.width / count;

times(count, (i) => {
  const stripe = display.rect(i * stripeW, 0, stripeW, world.height);
  stripe.color = color.hsb(i * 18, 70, 80);
  stripe.borderWidth = 0;
});
```

### Concentric Shapes

```javascript
const cx = world.width / 2;
const cy = world.height / 2;

times(20, (i) => {
  const r = 30 + i * 25;
  const shape = display.circle(cx, cy, r);
  shape.color = color.hsb(i * 20, 60, 80, 30);  // semi-transparent
  shape.borderWidth = 3;
  shape.borderColor = color.hsb((i * 20 + 180) % 360, 60, 80);
});
```

### Spiral of Shapes

```javascript
const cx = world.width / 2;
const cy = world.height / 2;
const count = 50;

times(count, (i) => {
  const angle = i * 0.4;
  const r = i * 8;
  const x = cx + Math.cos(angle) * r;
  const y = cy + Math.sin(angle) * r;

  const shape = display.polygon(x, y, 10 + i, 3);
  shape.angle = angle * (180 / Math.PI);
  shape.color = color.hsb(i * 7, 70, 80);
});
```

## Trail Effects

### Simple Trail

```javascript
const player = display.circle(100, 100, 20);
player.color = color.hsb(200, 80, 90);

// Create trail elements
const trail = [];
const maxTrail = 20;

player.update((event) => {
  // Follow mouse
  input.point((e) => {
    if (e.updated) {
      // Smooth follow
      player.x += (e.position.x - player.x) * 0.1;
      player.y += (e.position.y - player.y) * 0.1;
    }
  });

  // Add trail point periodically
  if (trail.length === 0 ||
      Math.abs(player.x - trail[trail.length - 1].x) > 10 ||
      Math.abs(player.y - trail[trail.length - 1].y) > 10) {

    const t = display.circle(player.x, player.y, 15);
    t.color = color.hsb(200, 40, 90, 80);
    t.borderWidth = 0;
    trail.push({ el: t, age: 0 });

    // Limit trail length
    if (trail.length > maxTrail) {
      const old = trail.shift();
      old.el.destroy();
    }
  }

  // Fade trail
  trail.forEach((t, i) => {
    t.age++;
    const alpha = Math.max(0, 100 - t.age * 5);
    t.el.color = color.hsb(200, 40, 90, alpha);
    t.el.scale = 1 - (t.age / 20);
  });
});
```

### Emoji Trail

```javascript
const star = display.emoji("⭐", 100, 100);
const trail = [];
let trailIndex = 0;

star.update((event) => {
  // Circular motion
  const time = Date.now() / 1000;
  const cx = world.width / 2;
  const cy = world.height / 2;
  const r = 200;

  star.x = cx + Math.cos(time) * r;
  star.y = cy + Math.sin(time * 1.5) * r;
  star.angle = time * 50;

  // Leave trail every few frames
  trailIndex++;
  if (trailIndex % 3 === 0) {
    const t = display.emoji("✨", star.x, star.y);
    t.scale = 0.5;
    t.alpha = 80;
    trail.push({ el: t, age: 0 });
  }

  // Fade trail
  for (let i = trail.length - 1; i >= 0; i--) {
    trail[i].age++;
    const life = 1 - trail[i].age / 30;
    trail[i].el.scale = 0.5 * life;
    trail[i].el.alpha = 80 * life;

    if (life <= 0) {
      trail[i].el.destroy();
      trail.splice(i, 1);
    }
  }
});
```

## Visual Feedback

### Selection Highlight

```javascript
const buttons = [];

// Create buttons
times(5, (i) => {
  const btn = display.rect(100 + i * 120, 300, 100, 60);
  btn.color = color.hsb(200, 60, 70);
  btn.cornerRadius = 8;
  btn.tag = "button";
  buttons.push(btn);

  // Click handler
  btn.clicked((event) => {
    // Click action
    btn.color = color.hsb(120, 80, 70);  // Flash green

    timeout(200, () => {
      btn.color = color.hsb(200, 60, 70);  // Return to normal
    });
  });

  // Hover effect using point
  btn.point((event) => {
    if (event.began || event.updated) {
      btn.scale = 1.1;
      btn.color = color.hsb(200, 70, 80);
    }
    if (event.ended) {
      btn.scale = 1.0;
      btn.color = color.hsb(200, 60, 70);
    }
  });
});
```

### Collision Flash

```javascript
const objects = [];

// Create physics objects
times(10, () => {
  const obj = display.circle(random.pos(), random.num(20, 40));
  obj.color = color.hsb(random.number(0, 360), 70, 80);
  physics.add(obj);
  objects.push(obj);

  // Collision flash
  obj.collision((event) => {
    if (event.began) {
      // Flash white on collision
      obj.color = color.hsb(0, 0, 100);

      // Return to normal
      timeout(100, () => {
        if (obj.active) {
          obj.color = color.hsb(random.number(0, 360), 70, 80);
        }
      });
    }
  });
});
```

## Combinations

### Fireworks

```javascript
function launchFirework() {
  const x = random.number(100, world.width - 100);
  const y = world.height;
  const targetY = random.number(100, world.height / 2);

  const rocket = display.circle(x, y, 5);
  rocket.color = color.hsb(random.number(0, 360), 90, 90);
  physics.add(rocket, { density: 0.1 });

  // Launch up
  rocket.applyImpulse(0, -random.num(300, 500));

  // Watch for peak and explode
  let exploded = false;

  rocket.update((event) => {
    if (!exploded && rocket.vy > -10) {  // Slowing down
      exploded = true;

      // Save position and destroy rocket
      const explodeX = rocket.x;
      const explodeY = rocket.y;
      rocket.destroy();

      // Explode!
      explode(explodeX, explodeY, rocket.color);
    }
  });
}

function explode(x, y, baseColor) {
  times(40, () => {
    const p = display.circle(x, y, random.num(2, 6));
    p.color = baseColor;
    p.borderWidth = 0;
    physics.add(p, { density: 0.1 });

    const angle = random.number(0, Math.PI * 2);
    const speed = random.num(100, 300);
    const vx = Math.cos(angle) * speed;
    const vy = Math.sin(angle) * speed;

    p.applyImpulse(vx, vy);

    // Fade and remove
    let life = 100;
    p.update((event) => {
      life -= 2;
      p.alpha = life;

      if (life <= 0) {
        p.destroy();
      }
    });
  });
}

// Launch periodically
timer.every(2000, launchFirework);  // every 2 seconds
```

### Floating Bubbles

```javascript
const bubbles = [];

times(15, () => {
  const b = display.circle(random.pos(), random.num(10, 30));
  b.color = color.hsb(190, 40, 90, 70);
  b.borderColor = color.hsb(190, 60, 100);
  b.borderWidth = 2;
  physics.add(b, {
    density: 0.5,
    restitution: 0.8  // bouncy
  });

  bubbles.push({
    el: b,
    speed: random.num(1, 3),
    wobble: random.number(0, Math.PI * 2),
    wobbleSpeed: random.num(0.02, 0.05)
  });

  // Gentle upward force
  b.update((event) => {
    b.applyForce(random.num(-2, 2), -b.speed);
  });
});

// Ground to bounce off
world.ground();
```

### Rain Effect

```javascript
// Create rain drops
times(50, () => {
  const drop = display.line(0, 0, 0, 15);
  drop.color = color.hsb(200, 60, 80, 60);
  drop.x = random.number(0, world.width);
  drop.y = random.number(-500, 0);
  drop.angle = 15;  // slight tilt

  drop.update((event) => {
    drop.y += random.num(5, 10);

    // Reset if below screen
    if (drop.y > world.height) {
      drop.y = random.number(-100, -20);
      drop.x = random.number(0, world.width);
    }
  });
});
```

## Set Fill/Stroke Defaults

```javascript
// Set defaults for all new elements
fill(color.hsb(200, 80, 90));  // fill color
stroke(color.hsb(0, 0, 0), 2);  // border color and width

// Now all new elements use these
times(10, () => {
  display.circle(random.pos(), 30);  // uses fill/stroke above
});

// Override per element
const special = display.circle(400, 300, 50);
special.color = color.hsb(0, 80, 90);  // override fill
special.borderColor = color.hsb(60, 90, 90);  // override stroke
special.borderWidth = 5;
```
