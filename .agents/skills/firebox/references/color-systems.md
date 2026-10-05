# Color Systems

Firebox🔥 provides HSB and RGB color modes with optional alpha for creating visually cohesive palettes. Colors also have manipulation methods for creating variations.

## Color Functions

### HSB (Hue, Saturation, Brightness)

HSB is the recommended color mode for Firebox - it's intuitive for creating harmonious palettes.

```javascript
// Basic HSB color
color.hsb(hue, saturation, brightness)

// HSB with alpha (0-100)
color.hsb(hue, saturation, brightness, alpha)
```

**Parameters:**
- `hue`: 0-360 degrees on color wheel
- `saturation`: 0-100 (gray to fully saturated)
- `brightness`: 0-100 (black to full brightness)
- `alpha`: 0-100 (optional, 0=transparent, 100=opaque)

```javascript
const red = color.hsb(0, 80, 90, 100);      // fully opaque
const transparentRed = color.hsb(0, 80, 90, 50);  // 50% transparent
```

### RGB (Red, Green, Blue)

```javascript
// Basic RGB color
color.rgb(red, green, blue)

// RGB with alpha
color.rgb(red, green, blue, alpha)
```

**Parameters:**
- `red`: 0-255
- `green`: 0-255
- `blue`: 0-255
- `alpha`: 0-100 (optional)

```javascript
const red = color.rgb(255, 50, 50, 100);
const transparentBlue = color.rgb(50, 100, 255, 50);
```

## Predefined Colors

Firebox includes several predefined color constants:

```javascript
// Basic colors
color.black   // color.hsb(0, 0, 0) or color.rgb(0, 0, 0)
color.white   // color.hsb(0, 0, 100) or color.rgb(255, 255, 255)
color.clear   // Fully transparent (alpha = 0)
```

### Usage Examples

```javascript
// Set element color to black
element.color = color.black;

// Set element color to white
element.color = color.white;

// Make element invisible but keep it active
element.color = color.clear;

// For invisible backgrounds
const bg = display.rect(0, 0, world.width, world.height);
bg.color = color.clear;
```

## Color Manipulation Methods

Colors have methods to create variations:

### Darker

Create darker variations of a color:

```javascript
const baseColor = color.hsb(200, 80, 90, 100);

// Darker by 1 step
const darker1 = baseColor.darker();

// Darker by n steps
const darker3 = baseColor.darker(3);

// Example: Create gradient
const c = display.circle(100, 100, 50);
let currentColor = color.hsb(200, 75, 95, 100);

times(10, (i) => {
  const circle = display.circle(100 + i * 20, 100, 50 - i * 4);
  circle.color = currentColor.darker(i);
});
```

### Lighter

Create lighter variations of a color:

```javascript
const baseColor = color.hsb(200, 80, 50, 100);

// Lighter by 1 step
const lighter1 = baseColor.lighter();

// Lighter by n steps
const lighter5 = baseColor.lighter(5);

// Example: Concentric circles
const initColor = color.hsb(random.num(0, 360), 95, 55, 100);

times(10, (i) => {
  const c = display.circle(400, 300, 7.5 * ((i + 1) * 2));
  c.color = initColor.lighter(i);
});
```

### Clone

Create a copy of a color:

```javascript
const original = color.hsb(200, 80, 90, 100);
const copy = original.clone();

// Modify copy without affecting original
copy.darker(2);

// Useful for animation
const line = display.line(100, 100, 200, 200);
line.color = color.hsb(180, 75, 95, 100);
line.borderColor = color.hsb(270, 75, 95, 100);

input.point((event) => {
  if (event.began) {
    const newLine = display.line(event.position, event.position);
    newLine.color = line.color.clone();  // Copy the color
    newLine.borderColor = line.borderColor.clone();
  }
});
```

## Color Ranges

### Hue Spectrum

- **0-30**: Red to Orange
- **30-60**: Orange to Yellow
- **60-120**: Yellow to Green
- **120-180**: Green to Cyan
- **180-240**: Cyan to Blue
- **240-300**: Blue to Purple
- **300-360**: Purple to Red

```javascript
// Warm colors
const warm = [
  color.hsb(0, 80, 90, 100),    // Red
  color.hsb(15, 85, 90, 100),   // Orange-Red
  color.hsb(30, 80, 90, 100),   // Orange
  color.hsb(45, 75, 90, 100),   // Yellow-Orange
  color.hsb(60, 70, 90, 100)    // Yellow
];

// Cool colors
const cool = [
  color.hsb(120, 70, 80, 100),  // Green
  color.hsb(180, 60, 85, 100),  // Cyan
  color.hsb(210, 75, 85, 100),  // Sky Blue
  color.hsb(240, 70, 85, 100),  // Blue
  color.hsb(270, 65, 80, 100)   // Purple
];
```

## Color Palettes

### Monochromatic

Single hue with varying saturation, brightness, and alpha:

```javascript
const hue = 200;  // Blue
const monochromatic = [
  color.hsb(hue, 90, 95, 100),  // Light vivid
  color.hsb(hue, 80, 85, 100),  // Medium vivid
  color.hsb(hue, 60, 70, 100),  // Medium muted
  color.hsb(hue, 40, 50, 100),  // Dark muted
  color.hsb(hue, 20, 30, 100),  // Very dark
  color.hsb(hue, 40, 90, 50)    // Light with transparency
];
```

### Analogous

Adjacent hues on the color wheel:

```javascript
const baseHue = 200;
const analogous = [
  color.hsb(baseHue - 30, 80, 90, 100),  // Teal
  color.hsb(baseHue - 15, 80, 90, 100),  // Cyan-Blue
  color.hsb(baseHue, 80, 90, 100),       // Blue
  color.hsb(baseHue + 15, 80, 90, 100),  // Blue-Purple
  color.hsb(baseHue + 30, 80, 90, 100)   // Purple
];
```

### Complementary

Opposite hues on the color wheel:

```javascript
const hue1 = 30;   // Orange
const hue2 = 210;  // Blue (opposite)

const complementary = [
  color.hsb(hue1, 85, 90, 100),
  color.hsb(hue1, 70, 75, 100),
  color.hsb(hue2, 85, 90, 100),
  color.hsb(hue2, 70, 75, 100)
];
```

### Triadic

Three evenly spaced hues:

```javascript
const triadic = [
  color.hsb(0, 80, 90, 100),    // Red
  color.hsb(120, 80, 90, 100),  // Green
  color.hsb(240, 80, 90, 100)   // Blue
];
```

### Split Complementary

Base hue plus hues on either side of its complement:

```javascript
const baseHue = 30;  // Orange
const splitComp = [
  color.hsb(baseHue, 85, 90, 100),           // Orange
  color.hsb(baseHue + 150, 80, 85, 100),     // Blue-Green
  color.hsb(baseHue + 210, 80, 85, 100)      // Blue-Purple
];
```

### Tetradic (Double Split Complementary)

Four hues forming a rectangle on the color wheel:

```javascript
const hue1 = 0;    // Red
const hue2 = 90;   // Yellow-Green
const hue3 = 180;  // Cyan
const hue4 = 270;  // Purple

const tetradic = [
  color.hsb(hue1, 80, 90, 100),
  color.hsb(hue2, 80, 90, 100),
  color.hsb(hue3, 80, 90, 100),
  color.hsb(hue4, 80, 90, 100)
];
```

## Curated Palettes

### Sunset

```javascript
const sunset = [
  color.hsb(340, 85, 90, 100),  // Pink-Red
  color.hsb(15, 90, 95, 100),   // Orange
  color.hsb(35, 80, 90, 100),   // Yellow-Orange
  color.hsb(200, 60, 40, 100),  // Dark Blue
  color.hsb(240, 50, 30, 100),  // Deep Blue
  color.hsb(15, 90, 95, 70)     // Glow effect
];
```

### Ocean

```javascript
const ocean = [
  color.hsb(180, 50, 95, 100),  // Light Cyan
  color.hsb(190, 60, 85, 100),  // Cyan
  color.hsb(200, 70, 75, 100),  // Blue
  color.hsb(220, 80, 60, 100),  // Deep Blue
  color.hsb(240, 70, 40, 100),  // Navy
  color.hsb(200, 70, 75, 50)     // Water transparency
];
```

### Forest

```javascript
const forest = [
  color.hsb(80, 40, 90, 100),   // Light Green
  color.hsb(100, 60, 80, 100),  // Green
  color.hsb(120, 70, 70, 100),  // Forest Green
  color.hsb(140, 60, 50, 100),  // Dark Green
  color.hsb(60, 80, 60, 100),   // Olive
  color.hsb(120, 40, 90, 60)    // Leaf transparency
];
```

### Neon

```javascript
const neon = [
  color.hsb(320, 100, 95, 100), // Hot Pink
  color.hsb(180, 100, 95, 100), // Cyan
  color.hsb(60, 100, 95, 100),  // Yellow
  color.hsb(280, 100, 95, 100), // Purple
  color.hsb(120, 100, 95, 100), // Green
  color.hsb(60, 100, 95, 70)    // Glow
];
```

### Earth Tones

```javascript
const earth = [
  color.hsb(25, 60, 75, 100),   // Tan
  color.hsb(35, 70, 65, 100),   // Brown
  color.hsb(15, 50, 55, 100),   // Rust
  color.hsb(100, 40, 45, 100),  // Olive Green
  color.hsb(30, 30, 85, 100),   // Cream
  color.hsb(25, 60, 75, 80)     // Shadow
];
```

### Pastel

```javascript
const pastel = [
  color.hsb(0, 30, 95, 100),    // Pastel Pink
  color.hsb(60, 25, 95, 100),   // Pastel Yellow
  color.hsb(120, 25, 90, 100),  // Pastel Green
  color.hsb(180, 30, 95, 100),  // Pastel Cyan
  color.hsb(240, 30, 95, 100),  // Pastel Blue
  color.hsb(300, 25, 95, 100),  // Pastel Purple
  color.hsb(0, 30, 95, 50)      // Soft overlay
];
```

## Color Manipulation

### Lighten/Darken

```javascript
// Create gradient from a base color
const base = color.hsb(200, 80, 80, 100);

times(10, (i) => {
  const c = display.circle(100 + i * 40, 300, 30);
  c.color = base.darker(i);  // progressively darker
});

// Or lighter
times(10, (i) => {
  const c = display.circle(100 + i * 40, 400, 30);
  c.color = base.lighter(i);  // progressively lighter
});
```

### Rotate Hue

```javascript
const baseHue = 200;
const rotated = color.hsb((baseHue + 30) % 360, 80, 90, 100);
```

### Complementary Color

```javascript
function complementary(hue) {
  return (hue + 180) % 360;
}

const baseHue = 30;
const compHue = complementary(baseHue);
const compColor = color.hsb(compHue, 80, 90, 100);
```

### Adjust Alpha

```javascript
const baseColor = color.hsb(200, 80, 90, 100);

// More transparent
const transparent = color.hsb(200, 80, 90, 50);

// Fully transparent
const invisible = color.clear;

// Fully opaque
const opaque = color.hsb(200, 80, 90, 100);
```

## Gradient Patterns

### Vertical Fade

```javascript
function createVerticalFade(hue, x, y, width, height, steps = 20) {
  const stripHeight = height / steps;
  
  times(steps, (i) => {
    const t = i / steps;
    const rect = display.rect(x, y + i * stripHeight, width, stripHeight + 1);
    rect.color = color.hsb(hue, 70, 90 - t * 60, 100);  // Fade to darker
    rect.borderWidth = 0;
  });
}

// Create sky gradient
createVerticalFade(200, 0, 0, display.width, display.height);
```

### Alpha Gradient

```javascript
// Fade out horizontally
const fadeSteps = 20;
const stepWidth = display.width / fadeSteps;

times(fadeSteps, (i) => {
  const alpha = 100 - (i / fadeSteps) * 100;
  const rect = display.rect(i * stepWidth, 0, stepWidth + 1, display.height);
  rect.color = color.hsb(0, 0, 0, alpha);  // Black fading out
  rect.borderWidth = 0;
});
```

### Gradient with Darker/Lighter

```javascript
const base = color.hsb(220, 60, 70, 100);

times(20, (i) => {
  const c = display.circle(50 + i * 45, 300, 40);
  c.color = base.darker(i * 0.5);
  c.borderWidth = 0;
});
```

## Usage Examples

### Applying Palettes

```javascript
const palette = [
  color.hsb(0, 80, 90, 100),
  color.hsb(60, 80, 90, 100),
  color.hsb(120, 80, 90, 100),
  color.hsb(180, 80, 90, 100),
  color.hsb(240, 80, 90, 100)
];

// Create colored circles
palette.forEach((col, i) => {
  const circle = display.circle(100 + i * 100, 300, 40);
  circle.color = col;
});
```

### Color Cycling

```javascript
const element = display.circle(400, 300, 50);
let hue = 0;

element.update((event) => {
  hue = (hue + 1) % 360;
  element.color = color.hsb(hue, 80, 90, 100);
});
```

### Random from Palette

```javascript
const palette = [/* ... */];

function randomColor() {
  return palette[Math.floor(random.number(0, palette.length))];
}

// Usage
times(50, () => {
  const circle = display.circle(random.pos(), random.num(10, 30));
  circle.color = randomColor();
});
```

### Themed Game Elements

```javascript
const themes = {
  fire: {
    primary: color.hsb(15, 90, 95, 100),
    secondary: color.hsb(30, 85, 90, 100),
    accent: color.hsb(0, 80, 85, 100),
    background: color.hsb(0, 60, 20, 100),
    glow: color.hsb(15, 90, 95, 50)
  },
  ice: {
    primary: color.hsb(190, 70, 95, 100),
    secondary: color.hsb(200, 60, 90, 100),
    accent: color.hsb(180, 80, 85, 100),
    background: color.hsb(210, 50, 30, 100),
    glow: color.hsb(190, 70, 95, 50)
  },
  nature: {
    primary: color.hsb(120, 70, 80, 100),
    secondary: color.hsb(90, 65, 85, 100),
    accent: color.hsb(60, 80, 90, 100),
    background: color.hsb(100, 40, 25, 100),
    glow: color.hsb(120, 70, 80, 50)
  }
};

// Apply theme
const currentTheme = themes.nature;
const bg = display.rect(0, 0, display.width, display.height);
bg.color = currentTheme.background;
bg.borderWidth = 0;

const player = display.emoji("🦊", 100, 100);
player.color = currentTheme.primary;
```

### Fade Effects

```javascript
const element = display.circle(400, 300, 50);
element.color = color.hsb(200, 80, 90, 100);

// Fade out and destroy
let alpha = 100;
element.update((event) => {
  alpha -= 2;
  element.color = color.hsb(200, 80, 90, Math.max(0, alpha));
  
  if (alpha <= 0) {
    element.destroy();
  }
});

// Or use animation
elem.animate(500, (to) => {
  to.alpha = 0;  // Fade to transparent
}, () => {
  elem.destroy();  // Destroy after fade
});
```

### Cloning Colors

```javascript
const templateColor = color.hsb(200, 80, 90, 100);

// Create multiple elements with same base color
const elements = [];
times(10, (i) => {
  const el = display.circle(100 + i * 80, 300, 30);
  el.color = templateColor.clone();  // Each has independent copy
  
  // Can modify individually
  if (i % 2 === 0) {
    el.color = el.color.darker(2);
  }
  
  elements.push(el);
});
```

## Best Practices

- Use HSB for easier color manipulation and harmony
- Use `color.black`, `color.white`, `color.clear` for common colors
- Use `darker()` and `lighter()` to create gradients and shadows
- Use `clone()` when you need independent color copies
- Limit palettes to 3-5 colors for cohesion
- Use consistent saturation levels within a piece
- Vary brightness more than hue for depth
- Test palettes on both light and dark backgrounds
- Consider color blindness - avoid red/green only distinctions
- Use alpha for transparency effects (0-100)
- Use borders with contrasting colors for visibility
- Keep alpha at 100 for solid objects, reduce for effects
- Use `color.clear` for invisible elements that still receive input
