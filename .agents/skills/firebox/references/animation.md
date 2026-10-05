# Animation

Firebox provides a powerful animation system for smooth transitions and keyframe-based animations.

## Basic Animation

### Simple Animation

Animate any element property over time:

```javascript
const elem = display.emoji("🤩", 100, 100);

// Animate with duration in milliseconds
elem.animate(500, (to) => {
  to.position.x = 300;
  to.position.y = 200;
  to.scale = 2;
  to.angle = 45;
});
```

### Animation with Callback

Execute code when animation completes:

```javascript
elem.animate(500, (to) => {
  to.position = { x: 300, y: 200 };
  to.scale = 2;
}, () => {
  // Animation complete
  console.log("Animation finished!");
  
  // Chain another animation
  elem.animate(300, (to) => {
    to.scale = 1;
    to.angle += 360;
  });
});
```

## Animation Configuration

### Configuration Object

Control animation with detailed options:

```javascript
elem.animate({
  duration: 1000,    // milliseconds
  delay: 200,        // delay before starting (ms)
  easing: Easing.easeInOutCubic,  // easing function
  autoreverse: true  // reverse after completion
}, (to) => {
  to.position = random.pos();
  to.scale = 2;
  to.angle = 360;
}, (retval) => {
  // Complete callback
  print("Animation complete!", retval);
});
```

### Easing Functions

Available easing functions in the `Easing` object:

```javascript
// Linear
Easing.linear

// Quad
Easing.easeInQuad
Easing.easeOutQuad
Easing.easeInOutQuad

// Cubic
Easing.easeInCubic
Easing.easeOutCubic
Easing.easeInOutCubic

// Quart
Easing.easeInQuart
Easing.easeOutQuart
Easing.easeInOutQuart

// Quint
Easing.easeInQuint
Easing.easeOutQuint
Easing.easeInOutQuint

// Sine
Easing.easeInSine
Easing.easeOutSine
Easing.easeInOutSine

// Expo
Easing.easeInExpo
Easing.easeOutExpo
Easing.easeInOutExpo

// Circ
Easing.easeInCirc
Easing.easeOutCirc
Easing.easeInOutCirc

// Elastic
Easing.easeInElastic
Easing.easeOutElastic
Easing.easeInOutElastic

// Back
Easing.easeInBack
Easing.easeOutBack
Easing.easeInOutBack

// Bounce
Easing.easeInBounce
Easing.easeOutBounce
Easing.easeInOutBounce
```

### Alternative: String Easing

You can also pass easing as a string:

```javascript
elem.animate({
  duration: 500,
  easing: "easeInOutCubic"  // string version
}, (to) => {
  to.position = random.pos();
});
```

## Keyframe Animations

### Basic Keyframes

Chain multiple animations with keyframes:

```javascript
const elem = display.emoji("🤩");

elem.animateKeyframe((anim) => {
  // First keyframe: rotate and scale
  anim.keyframe(100, (to) => {
    to.angle -= 30;
    to.scale = 2;
  });
  
  // Second keyframe: rotate back
  anim.keyframe(100, (to) => {
    to.angle += 60;
  });
  
  // Third keyframe: rotate other way
  anim.keyframe(100, (to) => {
    to.angle -= 60;
    to.scale = 2;
  });
  
  // Final keyframe: return to normal
  anim.keyframe(200, (to) => {
    to.angle = 0;
    to.scale = 1;
  });
});
```

### Interactive Keyframes

Trigger keyframe animations on events:

```javascript
const elem = display.emoji("🤩");
const btn = ui.button("Click me", display.center.x, 540);

btn.action(() => {
  elem.animateKeyframe((anim) => {
    anim.keyframe(100, (to) => {
      to.angle -= 40;
      to.scale = 2;
    });
    anim.keyframe(100, (to) => {
      to.angle += 80;
    });
    anim.keyframe(100, (to) => {
      to.angle -= 80;
    });
    anim.keyframe(100, (to) => {
      to.angle += 80;
    });
    anim.keyframe(200, (to) => {
      to.angle = 0;
      to.scale = 1;
    });
  });
});
```

## Animation Properties

### Animatable Properties

Most element properties can be animated:

```javascript
elem.animate(500, (to) => {
  // Position
  to.position.x = 300;
  to.position.y = 200;
  to.position = { x: 300, y: 200 };  // or object
  
  // Size (for resizable elements)
  to.size.width = 100;
  to.size.height = 100;
  to.width = 100;
  to.height = 100;
  
  // Scale
  to.scale = 2;
  
  // Rotation
  to.angle = 360;
  to.angle += 180;  // relative rotation
  
  // Radius (circles)
  to.radius = 50;
  
  // Colors
  to.color = color.hsb(200, 80, 90);
  to.borderColor = color.hsb(0, 0, 100);
  
  // Border
  to.borderWidth = 5;
  
  // Transparency
  to.alpha = 50;  // 0-100
  
  // Corner radius (rectangles)
  to.cornerRadius = 10;
});
```

## Staggered Animations

### Delayed Animations

Create wave effects with delays:

```javascript
times(10, (i) => {
  const c = display.circle(display.center, 4 * i);
  c.delay = 50 * i;  // custom property for delay
  c.color = color.clear;
  c.borderColor = color.hsb(random.num(0, 360), 75, 95);
  c.borderWidth = 2;
});

input.point((event) => {
  if (!event.ended) return;
  
  display.all((elem) => {
    elem.animate({
      duration: 500,
      delay: elem.delay,  // use custom delay
      easing: "easeInOutCubic"
    }, (to) => {
      to.position = event.position;
    });
  });
});
```

### Circle Wave Animation

```javascript
times(10, (i) => {
  const circ = display.circle(
    { x: 100, y: display.height / 2 },
    4 * i
  );
  circ.delay = 50 * i;
  circ.color = color.clear;
  circ.borderColor = color.hsb(random.num(0, 360), 75, 95);
  circ.borderWidth = 2;
});

timer.every(1000, () => {
  const pos = random.pos();
  display.all((elem) => {
    elem.animate({
      duration: 500,
      delay: elem.delay,
      easing: "easeInOutCubic"
    }, (to) => {
      to.position = pos;
    });
  });
});
```

## Auto-Reverse Animations

### Pulsing Effect

```javascript
times(100, (i) => {
  const c = display.circle(display.center, 50);
  c.borderWidth = 2;
  
  c.animate({
    duration: 3500,
    delay: i * 25,
    autoreverse: true,  // reverse after completion
    easing: Easing.easeInOutQuart
  }, (to) => {
    to.radius = 25;
    to.color = color.hsb(random.num(0, 360), 42, 92);
    to.borderColor = color.hsb(random.num(0, 360), 42, 92);
    to.borderWidth = 10;
    to.position = random.pos();
  });
});
```

### Color Pulse with Reverse

```javascript
const player = display.emoji("🚀");

player.animate({
  duration: 1000,
  delay: 400,
  autoreverse: true,
  easing: Easing.easeInOutCubic
}, (to) => {
  to.position = random.pos();
  to.angle = 720;
  to.size = {
    width: player.size.width * 4,
    height: player.size.height * 4
  };
});
```

## Controlling Animations

### Stop All Animations

```javascript
const elem = display.emoji("🤡");
const startBtn = ui.button("Start", display.width / 2 - 50, 100);
const stopBtn = ui.button("Stop", display.width / 2 + 50, 100);

startBtn.action(() => {
  elem.animate({
    duration: 1000,
    autoreverse: true,
    easing: Easing.easeInOutCubic
  }, (to) => {
    to.position = random.pos();
    to.angle = 720;
  });
});

stopBtn.action(() => {
  elem.stopAnimations();  // Stop all running animations
});
```

### Animation Complete Handling

```javascript
elem.animate(400, (to) => {
  to.position = random.pos();
  to.angle = random.num(0, 360);
  to.size = random.size();
}, (retval) => {
  print("completed!", retval);
  
  // Start next animation or action
  nextAction();
});
```

## Animation Patterns

### Color Animation

```javascript
timer.every(500, () => {
  display.each("rect", (rect) => {
    rect.animate(400, (to) => {
      to.color = color.hsb(random.num(0, 360), 75, 95);
      to.scale = random.num(1, 10) * 0.1;
    });
  });
});
```

### Scale Bounce

```javascript
elem.collision((event) => {
  if (event.began) {
    elem.animate(200, (to) => {
      to.scale = 1.5;
    }, () => {
      elem.animate(200, (to) => {
        to.scale = 1;
      });
    });
  }
});
```

### Border Animation

```javascript
timer.every(500, () => {
  display.all((elem) => {
    elem.animate(400, (to) => {
      to.borderWidth = random.num(1, 15);
      to.cornerRadius = random.num(0, 15);
    });
  });
});
```

### Radius Animation

```javascript
timer.every(250, () => {
  const cir = display.circle(random.pos(), 5);
  cir.color = color.clear;
  cir.borderWidth = 2;
  cir.borderColor = color.hsb(random.num(0, 360), 75, 92);
});

update(() => {
  display.each("circle", (elem) => {
    elem.radius += 2;
    if (elem.radius > 240) {
      elem.animate(100, (to) => {
        to.alpha = 0;  // fade out
      }, () => {
        elem.destroy();  // destroy after fade
      });
    }
  });
});
```

## Chain Animations

### Sequential Animations

```javascript
function animateSequence() {
  pl.animate(200, (to) => {
    to.scale = 2;
    to.angle += 360;
  }, () => {
    // Second animation starts after first
    pl.animate(200, (to) => {
      to.scale = 1;
      to.angle += 360;
    }, () => {
      // Third animation...
      animateSequence();  // Loop
    });
  });
}

animateSequence();
```

### Collision-Triggered Animation

```javascript
const player = display.emoji("🤪");

// Continuous movement
update(() => {
  player.pointTo(input);
  player.move(3);
});

// Collision triggers animation
player.collision((event) => {
  if (!event.began) return;
  
  player.animate(200, (to) => {
    to.position = event.other.position;
  }, () => {
    // After reaching target
    animate();  // Start animation sequence
    event.other.hide();
  });
});

// Spawn collectibles
repeat(3, () => {
  display.emoji("🍉", random.pos());
});
```

## Display Dimensions

### Screen Size

Access display dimensions for positioning:

```javascript
// Display dimensions
const w = display.width;   // 960 default
const h = display.height;  // 640 default

// Center point
const cx = display.cx;  // or display.center.x
const cy = display.cy;  // or display.center.y

// Usage
display.circle(display.center, 50);
display.rect(display.width / 2 - 50, display.height - 100, 100, 100);
```

### Responsive Grid

```javascript
const numX = 3;
const size = display.width / numX;
const numY = Math.ceil(display.height / size);

repeat(numY, (y) => {
  repeat(numX, (x) => {
    const r = display.rect(
      (x * size) + size / 2,
      (y * size) + size / 2,
      size,
      size
    );
    r.color = color.hsb(random.num(0, 360), 42, 92);
  });
});
```

## Iterating All Elements

### display.all()

Apply animations to all elements:

```javascript
// Animate all elements
timer.every(1000, () => {
  const newPos = random.pos();
  display.all((elem) => {
    elem.animate({
      duration: 400,
      delay: elem.delay || 0,
      easing: Easing.easeInOutSine
    }, (to) => {
      to.position = newPos;
    });
  });
});

// Style all elements
display.all((elem) => {
  const hue = random.num(0, 360);
  elem.color = color.hsb(hue, 75, 25);
  elem.borderColor = color.hsb(hue, 55, 95);
  elem.borderWidth = 5;
});
```

## Cloud Animation Example

```javascript
display.color = color.hsb(0, 0, 92);  // Light background

repeat(25, () => {
  display.cloud(random.pos(), 50);
});

timer.every(3000, () => {
  display.each("cloud", (cloud) => {
    cloud.animate({
      duration: random.num(400, 2000),
      easing: Easing.easeInOutCubic
    }, (to) => {
      to.angle += 360;
      to.color = color.hsb(random.num(0, 360), 42, 92);
      to.position = random.pos();
      to.alpha = random.num(0, 100);
    });
  });
});
```

## Best Practices

- Use `duration` in milliseconds (1000 = 1 second)
- Use `delay` to create staggered/wave effects
- Use `autoreverse` for pulsing effects that return to start
- Use `easing` to make animations feel more natural
- Use keyframes for complex multi-step animations
- Store delays in custom properties (`elem.delay`) for staggered effects
- Use callbacks to chain animations or trigger actions
- Use `stopAnimations()` to interrupt running animations
- Prefer `display.all()` over manual iteration when applying to all elements
