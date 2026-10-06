# Shapes and Geometry

## Display Elements Overview

Firebox provides several display primitives for creating visual compositions:

| Element | Function | Key Properties |
|---------|----------|----------------|
| Emoji | `display.emoji()` | emoji icon, tag name, position |
| Rectangle | `display.rect()` | width, height, corner radius |
| Circle | `display.circle()` | radius |
| Polygon | `display.polygon()` | radius, vertices (3+) |
| Ellipse | `display.ellipse()` | radiusX, radiusY |
| Line | `display.line()` | from, to positions, style |
| Star | `display.star()` | radius |
| Heart | `display.heart()` | radius |
| Cloud | `display.cloud()` | radius |
| Bubble | `display.bubble()` | text, position |
| Ghost | `display.ghost()` | radius |

All elements share common properties: position, size, scale, angle, color, borderColor, borderWidth, alpha, active, flip.

## Display Properties

### Screen Dimensions

```javascript
// Display size
const w = display.width;    // 960 default
const h = display.height;   // 640 default

// Center point
const cx = display.cx;      // or display.center.x
const cy = display.cy;      // or display.center.y
const center = display.center;  // { x, y } object

// Usage examples
display.circle(display.center, 50);
display.rect(display.width / 2 - 50, display.height - 100, 100, 100);
```

### Background Color

```javascript
// Set background color for entire display
display.color = color.hsb(200, 40, 30, 100);
display.color = color.hsb(0, 0, 92, 100);  // Light gray
```

### Iterating All Elements

```javascript
// Apply to all elements
display.all((elem) => {
  elem.color = color.hsb(random.num(0, 360), 75, 95);
});

// Animate all
timer.every(1000, () => {
  display.all((elem) => {
    elem.animate(500, (to) => {
      to.position = random.pos();
    });
  });
});

// Add all to physics
physics.add(display.drawElems);
```

### Iterating by Tag

```javascript
// Process all elements with given tag
display.each("enemy", (enemy) => {
  enemy.color = color.hsb(0, 80, 90, 100);
});

display.each("circle", (circle) => {
  circle.radius += 2;
});
```

## Common Element Properties

All display elements have these properties:

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
element.changeY(-3);  // subtract 3 from y
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

// Border/Stroke
element.borderColor = color.hsb(0, 0, 100, 100);
element.borderWidth = 2;

// Type and tag (read-only type, settable tag)
print(element.type);  // "circle", "emoji", etc.
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

## Common Element Methods

All elements have these methods:

```javascript
// Movement
element.goTo(x, y);  // instant
element.goTo({ x, y });  // with point
element.move(distance);  // move in direction of angle
element.moveTo(x, y);  // animated movement

// Rotation
element.rotate(degrees);  // relative rotation
element.turnRight(degrees);  // clockwise
element.turnLeft(degrees);  // counter-clockwise
element.pointInDirection(degrees);  // set absolute angle
element.pointTo(target);  // rotate to face target

// Following
element.follow(target, speed);  // follow another element or point

// Edge handling
element.ifOnEdgeBounce();  // bounce off world edges
element.ifOnEdgeContinue();  // wrap around world edges
element.bounceX();  // mirror x direction
element.bounceY();  // mirror y direction
element.onEdge();  // returns true if on any edge
element.onEdgeX();  // returns true if on x edges
element.onEdgeY();  // returns true if on y edges
element.inView();  // returns true if in camera view
element.notInView();  // returns true if not in camera view
element.inWorld();  // returns true if inside world

// Drawing order
element.moveToFront();  // draw on top
element.moveToBack();  // draw behind

// Distance
element.distanceTo(other);  // get distance to another element

// Collisions
element.collide(other);  // check if colliding (returns boolean)
element.collision((event) => { ... });  // handle collision events

// Input
element.point((event) => { ... });  // handle mouse/touch events on this element
element.clicked((event) => { ... });  // handle click on this element
element.click((event) => { ... });  // alias
element.tap((event) => { ... });  // alias

// Update loop
element.update((event) => { ... });  // called every frame for this element
```

## Emoji

### Basic Usage

```javascript
// With string emoji
display.emoji("😊");
display.emoji("🚀", 100, 200);

// With emoji tag
display.emoji("starstruck");

// With emoji number
display.emoji(17);  // 🤩

// With position object
display.emoji("🎮", { x: 300, y: 400 });
display.emoji("🎮", random.pos());
```

### Emoji Properties

```javascript
const player = display.emoji("🤖", 100, 100);

// Access and modify position
player.x += 5;
player.position = { x: 200, y: 300 };

// Scale
player.scale = 2.0;

// Rotate
player.angle = 45;

// Emoji-specific properties
player.emoji.icon;  // "🤖"
player.emoji.tag;  // "robot"
player.emoji.id;  // internal id
player.emoji.code;  // "U+1F916"

// Offset angle (useful for adjusting emoji orientation)
player.angleOffset = 45;
```

### Emoji Collections

```javascript
// Create themed emoji scenes
const nature = ["🌲", "🌳", "🌴", "🌵", "🌿", "☘️", "🍀", "🍁", "🍂", "🍃"];
const animals = ["🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯"];
const food = ["🍏", "🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🫐"];

// Random emoji from collection
function randomEmoji(collection) {
  return collection[Math.floor(random.number(0, collection.length))];
}

// Create scattered scene
times(20, () => {
  display.emoji(randomEmoji(nature), random.pos());
});
```

## Rectangles

### Basic Usage

```javascript
// With coordinates
display.rect(100, 100, 50, 50);

// With position and size objects
display.rect({ x: 100, y: 100 }, { width: 50, height: 50 });

// With rect object
display.rect({ x: 100, y: 100, width: 50, height: 50 });

// Random position and size
display.rect(random.pos(), random.size(10, 100));
```

### Rectangle Properties

```javascript
const rect = display.rect(100, 100, 80, 60);

// Set corner radius
rect.cornerRadius = 10;

// Change size (rectangles are resizable)
rect.width = 100;
rect.height = 80;

// Styling
rect.color = color.hsb(200, 80, 90, 100);
rect.borderColor = color.hsb(0, 0, 100, 100);
rect.borderWidth = 2;

// Scale and rotate
rect.scale = 1.5;
rect.angle = 45;
```

### Rectangle Patterns

```javascript
// Grid of rectangles
times(10, (i) => {
  times(10, (j) => {
    const r = display.rect(i * 60 + 50, j * 60 + 50, 50, 50);
    r.color = color.hsb((i + j) * 18, 70, 80, 100);
    r.cornerRadius = (i + j) % 4;
  });
});

// Bar chart from data
const data = [30, 50, 80, 40, 90, 60];
data.forEach((value, i) => {
  const bar = display.rect(i * 80 + 100, 400 - value, 60, value);
  bar.color = color.hsb(200, 70, 50 + value / 2, 100);
});
```

## Circles

### Basic Usage

```javascript
// With position and radius
display.circle({ x: 100, y: 100 }, 50);

// With coordinates
display.circle(100, 100, 50);

// Random position
display.circle(random.pos(), 30);
display.circle(random.pos(), random.num(10, 50));

// At center
display.circle(display.center, 50);
```

### Circle Properties

```javascript
const circle = display.circle(100, 100, 50);

// Access and modify radius
circle.radius = 60;

// Styling
circle.color = color.hsb(0, 80, 90, 100);
circle.borderColor = color.hsb(0, 0, 0, 100);
circle.borderWidth = 3;
circle.alpha = 70;  // 70% opaque

// Clear fill with border
circle.color = color.clear;
circle.borderWidth = 2;
circle.borderColor = color.hsb(random.num(0, 360), 75, 95, 100);
```

### Circle Patterns

```javascript
// Concentric circles
const center = display.center;
times(10, (i) => {
  const c = display.circle(center, 30 + i * 20);
  c.color = color.hsb(i * 36, 70, 80, 50);  // with alpha
  c.borderWidth = 2;
});

// Bubble effect
times(50, () => {
  const bubble = display.circle(random.pos(), random.num(5, 20));
  bubble.color = color.hsb(190, 40, 90, 60);  // light blue, semi-transparent
  bubble.borderWidth = 0;
  bubble.tag = "bubble";
});

// Growing circles
timer.every(250, () => {
  const cir = display.circle(random.pos(), 5);
  cir.color = color.clear;
  cir.borderWidth = 2;
  cir.borderColor = color.hsb(random.num(0, 360), 75, 92, 100);
});

update(() => {
  display.each("circle", (elem) => {
    elem.radius += 2;
    if (elem.radius > 240) {
      elem.animate(100, (to) => {
        to.alpha = 0;
      }, () => {
        elem.destroy();
      });
    }
  });
});
```

## Polygons

### Basic Usage

```javascript
// Triangle
display.polygon(100, 100, 50, 3);

// Pentagon
display.polygon(200, 100, 50, 5);

// Hexagon
display.polygon(300, 100, 50, 6);

// Random vertices
display.polygon(random.pos(), 40, random.num(3, 9));

// At center
display.polygon(display.center, 50, 6);
```

### Polygon Properties

```javascript
const poly = display.polygon(100, 100, 50, 5);

// Modify vertices
poly.vertices = 6;  // becomes hexagon

// Randomize shape (0.0 to 1.0, adds randomness to vertices)
poly.randomize = 0.3;

// Rotate to point flat side up
poly.angle = 90 / 6;  // 15 degrees for hexagon
```

### Polygon Patterns

```javascript
// Geometric mandala
const cx = display.cx;
const cy = display.cy;

times(12, (i) => {
  const angle = (i / 12) * Math.PI * 2;
  const r = 150;
  const x = cx + Math.cos(angle) * r;
  const y = cy + Math.sin(angle) * r;

  const poly = display.polygon(x, y, 30, 6);
  poly.angle = (i / 12) * 360;
  poly.color = color.hsb(i * 30, 70, 80, 100);
});

// Random polygons field
times(30, () => {
  const poly = display.polygon(random.pos(), random.num(20, 60), random.num(3, 8));
  poly.color = color.hsb(random.number(0, 360), 60, 75, 100);
  poly.angle = random.number(0, 360);
  poly.randomize = 0.3;
});
```

## Ellipses

### Basic Usage

```javascript
// With position and two radii
display.ellipse({ x: 100, y: 100 }, 40, 60);

// With coordinates
display.ellipse(100, 100, 40, 60);

// Random ellipse
display.ellipse(random.pos(), random.num(10, 40), random.num(10, 60));
```

### Ellipse Properties

```javascript
const ellipse = display.ellipse(100, 100, 40, 60);

// Modify radii
ellipse.radiusX = 50;
ellipse.radiusY = 30;

// Rotate
ellipse.angle = 45;
```

### Ellipse Patterns

```javascript
// Leaf shapes
times(20, (i) => {
  const x = 100 + i * 40;
  const y = 200 + Math.sin(i * 0.3) * 50;
  const leaf = display.ellipse(x, y, 15, 40);
  leaf.angle = Math.sin(i * 0.3) * 30;
  leaf.color = color.hsb(120, 60, 50 + Math.sin(i * 0.5) * 20, 100);
});
```

## Lines

### Basic Usage

```javascript
// With two points
display.line({ x: 100, y: 100 }, { x: 200, y: 200 });

// With coordinates
display.line(100, 100, 200, 200);

// Dynamic endpoints
const start = { x: 100, y: 100 };
const end = random.pos();
display.line(start, end);
```

### Line Properties

```javascript
const line = display.line(100, 100, 200, 200);

// Line width
line.width = 3;

// Line cap style (for solid lines)
line.lineCap = LineCap.round;   // default
line.lineCap = LineCap.butt;    // square ends
line.lineCap = LineCap.square;  // square with extension

// Line style
line.style = LineStyle.solid;       // default
line.style = LineStyle.dots;        // line with circles
line.style = LineStyle.blocks;      // line with rectangles
line.style = LineStyle.polygons;    // line with polygons
line.style = LineStyle.clouds;      // line with clouds
line.style = LineStyle.stars;       // line with stars
line.style = LineStyle.hearts;      // line with hearts

// For decorative styles
line.elements = 10;         // number of decorations
line.vertices = 5;        // for polygon style

// Size is settable for lines
line.width = 200;  // length
line.height = 5;

// Update endpoints
line.from({ x: 100, y: 100 });  // set start point
line.to({ x: 200, y: 200 });    // set end point
line.from(p1.position);         // follow another element
line.to(p2.position);           // follow another element
```

### Line Patterns

```javascript
// Connected lines (path)
const points = [];
times(10, (i) => {
  points.push({
    x: 100 + i * 80,
    y: 300 + Math.sin(i * 0.8) * 100
  });
});

for (let i = 0; i < points.length - 1; i++) {
  display.line(points[i], points[i + 1]);
}

// Line styles
LineStyle.solid
LineStyle.dots
LineStyle.blocks
LineStyle.polygons
LineStyle.clouds
LineStyle.stars
LineStyle.hearts

// Decorative line
const decoLine = display.line(100, 500, 900, 500);
decoLine.style = LineStyle.stars;
decoLine.elements = 20;
decoLine.width = 2;
decoLine.color = color.hsb(45, 90, 90, 100);

// Dotted line
const dotLine = display.line(100, 600, 900, 600);
dotLine.style = LineStyle.dots;
dotLine.elements = 30;
dotLine.color = color.hsb(200, 50, 80, 100);

// Multiple decorative styles
display.line(100, 540, 860, 540).width = 20;
display.line(100, 540, 860, 540).style = LineStyle.stars;

display.line(175, 450, 780, 445).width = 16;
display.line(175, 450, 780, 445).style = LineStyle.clouds;

display.line(245, 360, 715, 355).width = 14;
display.line(245, 360, 715, 355).style = LineStyle.polygons;
display.line(245, 360, 715, 355).vertices = 7;

display.line(300, 275, 655, 275).width = 12;
display.line(300, 275, 655, 275).style = LineStyle.blocks;

display.line(350, 225, 615, 225).width = 10;
display.line(350, 225, 615, 225).style = LineStyle.dots;
```

### Dynamic Line

```javascript
// Create two moving endpoints
const p1 = display.circle(100, 100, 25);
p1.color = color.clear;
p1.angle = 135;

const p2 = display.circle(860, 540, 25);
p2.color = color.clear;
p2.angle = 315;

// Create line connecting them
const li = display.line(100, 100, 860, 540);
li.color = color.hsb(180, 75, 95, 100);
li.borderColor = color.hsb(270, 75, 95, 100);
li.lineCap = LineCap.round;
li.width = 50;
li.borderWidth = 10;

// Update line to follow moving points
update(() => {
  p1.move(5);
  p1.ifOnEdgeBounce();
  p2.move(5);
  p2.ifOnEdgeBounce();

  li.from(p1.position);
  li.to(p2.position);
});

// Draw line with mouse/touch
input.point((event) => {
  if (event.began) {
    line = display.line(event.position, event.position);
    line.moveToFront();
    line.color = li.color.clone();
    line.borderColor = li.borderColor.clone();
    line.lineCap = LineCap.square;
    line.width = 50;
    line.borderWidth = 5;
    line.elements = 5;
    line.vertices = 7;
    line.style = LineStyle.polygons;
  }

  if (event.updated) {
    line.to(event.position);
  }

  if (event.ended) {
    line.destroy();
  }
});
```

## Stars

### Basic Usage

```javascript
// With position and radius
display.star({ x: 100, y: 100 }, 50);

// With coordinates
display.star(100, 100, 50);

// Random
display.star(random.pos(), random.num(10, 50));
```

### Star Patterns

```javascript
// Night sky
const bg = display.rect(0, 0, display.width, display.height);
bg.color = color.hsb(240, 60, 20, 100);

times(100, () => {
  const star = display.star(random.pos(), random.num(2, 8));
  star.color = color.hsb(60, 20, 100, 100);
  star.borderWidth = 0;

  // Twinkle
  star.update((event) => {
    star.alpha = 50 + Math.random() * 50;
  });
});

// Burst pattern
const cx = display.cx;
const cy = display.cy;

times(20, (i) => {
  const angle = (i / 20) * Math.PI * 2;
  const r = 200;
  const x = cx + Math.cos(angle) * r;
  const y = cy + Math.sin(angle) * r;

  const star = display.star(x, y, 20);
  star.angle = (i / 20) * 360 + 90;
  star.color = color.hsb(i * 18, 80, 90, 100);
});
```

## Hearts

### Basic Usage

```javascript
// With position and radius
display.heart({ x: 100, y: 100 }, 50);

// With coordinates
display.heart(100, 100, 50);

// Random
display.heart(random.pos(), random.num(10, 50));
```

### Heart Patterns

```javascript
// Floating hearts animation
const hearts = [];
times(20, () => {
  const heart = display.heart(random.pos(), random.num(10, 30));
  heart.color = color.hsb(340, 70, 90, 100);
  heart.tag = "heart";

  hearts.push({
    el: heart,
    speed: random.num(1, 3),
    baseX: heart.x
  });

  heart.update((event) => {
    heart.y -= heart.speed;
    heart.angle = Math.sin(heart.y * 0.05) * 10;

    if (heart.y < -50) {
      heart.y = display.height + 50;
      heart.x = random.number(0, display.width);
    }
  });
});
```

## Clouds

### Basic Usage

```javascript
// With position and radius
display.cloud({ x: 100, y: 100 }, 50);

// With coordinates
display.cloud(100, 100, 50);

// Random
display.cloud(random.pos(), random.num(30, 80));
```

### Cloud Patterns

```javascript
// Sky scene
const bg = display.rect(0, 0, display.width, display.height);
bg.color = color.hsb(200, 40, 90, 100);

// Clouds at different layers
times(5, (i) => {
  const cloud = display.cloud(random.pos(), 60 + i * 10);
  cloud.color = color.hsb(0, 0, 95 - i * 5, 100);
  cloud.y = 100 + i * 30;
});

// Animated clouds
display.color = color.hsb(0, 0, 92, 100);  // Light background

times(25, () => {
  display.cloud(random.pos(), 50);
});

timer.every(3000, () => {
  display.each("cloud", (cloud) => {
    cloud.animate({
      duration: random.num(400, 2000),
      easing: Easing.easeInOutCubic
    }, (to) => {
      to.angle += 360;
      to.color = color.hsb(random.num(0, 360), 42, 92, 100);
      to.position = random.pos();
      to.alpha = random.num(0, 100);
    });
  });
});
```

## Bubbles

### Basic Usage

```javascript
// Create a speech bubble with text
display.bubble("Hello World!", 400, 300);
display.bubble("700x100", 700, 100);  // Short text

// With position object
display.bubble("Click me!", { x: 300, y: 200 });
```

### Bubble Patterns

```javascript
// Label positions with bubbles
for (let a = 0; a < 360; a += 6) {
  const angle = 2 * Math.PI / 360 * a - Math.PI / 2;
  const size = 300;
  const pnt = Point(
    display.cx + Math.cos(angle) * (size - 10),
    display.cy + Math.sin(angle) * (size - 10)
  );

  display.circle(pnt, 10);

  let l = ui.label(Math.floor(i++ % 60), pnt);
  l.color = color.white;
  l.backgroundColor = color.clear;
  l.fontSize = 12;
}
```

## Ghosts

### Basic Usage

```javascript
// With position and radius
display.ghost(200, 200, 25);

// At center
display.ghost(display.center, 50);

// Random
display.ghost(random.pos(), random.num(20, 60));
```

### Ghost Properties

```javascript
const ghost = display.ghost(300, 300, 40);

// All standard element properties work
ghost.color = color.hsb(200, 60, 80, 100);
ghost.alpha = 50;  // semi-transparent ghost
ghost.scale = 1.5;
ghost.angle = 15;

// Animate
ghost.animate(1000, (to) => {
  to.position = random.pos();
  to.alpha = random.num(30, 80);
});
```

## Complex Compositions

### Combining Elements

```javascript
// Robot character
function createRobot(x, y, scale = 1) {
  const parts = [];

  // Body
  const body = display.rect(x, y, 60 * scale, 80 * scale);
  body.color = color.hsb(200, 30, 70, 100);
  parts.push(body);

  // Head
  const head = display.circle(x, y - 50 * scale, 35 * scale);
  head.color = color.hsb(200, 20, 85, 100);
  parts.push(head);

  // Eyes
  const leftEye = display.circle(x - 12 * scale, y - 55 * scale, 8 * scale);
  leftEye.color = color.hsb(0, 0, 100, 100);
  parts.push(leftEye);

  const rightEye = display.circle(x + 12 * scale, y - 55 * scale, 8 * scale);
  rightEye.color = color.hsb(0, 0, 100, 100);
  parts.push(rightEye);

  // Antenna
  const antenna = display.line(x, y - 85 * scale, x, y - 110 * scale);
  antenna.width = 3 * scale;
  parts.push(antenna);

  const antennaBall = display.circle(x, y - 115 * scale, 6 * scale);
  antennaBall.color = color.hsb(0, 80, 90, 100);
  parts.push(antennaBall);

  return parts;
}

// Create multiple robots
times(5, (i) => {
  createRobot(100 + i * 150, 300, 0.8 + Math.random() * 0.4);
});
```

### Animated Composition

```javascript
// Orbiting planets
const sun = display.circle(display.center, 60);
sun.color = color.hsb(45, 90, 95, 100);

const planets = [
  { dist: 100, size: 15, speed: 2, color: color.hsb(200, 70, 80, 100), angle: 0 },
  { dist: 150, size: 20, speed: 1.5, color: color.hsb(30, 80, 80, 100), angle: 120 },
  { dist: 200, size: 25, speed: 1, color: color.hsb(150, 60, 70, 100), angle: 240 }
].map(p => {
  const planet = display.circle(0, 0, p.size);
  planet.color = p.color;
  p.planet = planet;
  return p;
});

update(() => {
  const cx = display.cx;
  const cy = display.cy;

  planets.forEach(p => {
    p.angle += p.speed * 0.02;
    p.planet.x = cx + Math.cos(p.angle) * p.dist;
    p.planet.y = cy + Math.sin(p.angle) * p.dist;
  });
});
```

## Fill and Stroke Defaults

### Setting Defaults

```javascript
// Set default fill color for new elements
fill(color.hsb(200, 80, 90, 100));

// Set default stroke/border for new elements
stroke(color.hsb(0, 0, 0, 100), 2);  // color and width

// Now new elements use these defaults
times(10, () => {
  display.circle(random.pos(), 30);  // uses fill/stroke above
});

// Override per element
const special = display.circle(400, 300, 50);
special.color = color.hsb(0, 80, 90, 100);  // override fill
special.borderColor = color.hsb(60, 90, 90, 100);  // override stroke
special.borderWidth = 5;
```

### Creating Style Themes

```javascript
// Neon theme
fill(color.hsb(0, 0, 100, 10));  // Very transparent white
stroke(color.white, 2);

times(100, () => {
  const r = display.rect(random.pos(), random.size(2, 4));
  r.color = color.white;  // Will use fill/stroke defaults
});

// Clear theme
stroke(color.black, 0);  // No border
fill(color.hsb(0, 0, 92, 100));
```

## Best Practices

- Use `display.center`, `display.cx`, `display.cy` for center positioning
- Use `display.width`, `display.height` for responsive layouts
- Use `display.color` to set background color
- Use `display.all()` to apply operations to all elements
- Use `display.each()` to process elements by tag
- Use `color.clear` for invisible elements with borders
- Use `fill()` and `stroke()` to set defaults for new elements
- Store custom data in element properties (e.g., `element.delay`)
- Use `clone()` when copying colors from other elements
- Use `randomize` on polygons for organic shapes
- Use `angleOffset` on emojis to adjust their natural orientation
- Animate properties smoothly for polished effects
