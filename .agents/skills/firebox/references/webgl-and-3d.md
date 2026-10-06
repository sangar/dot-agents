# WebGL and 3D

Firebox🔥 does **not** support WebGL or 3D rendering. It is a strictly 2D canvas-based creative coding platform focused on:

- 2D shapes and sprites
- Emoji-based graphics
- 2D physics simulation
- Simple 2D animations

## 2D-Only Architecture

Firebox uses a 2D canvas renderer with a built-in 2D physics engine (similar to Box2D). There is no:
- WebGL context
- 3D geometry support
- 3D camera or depth buffer
- 3D lighting or materials
- Texture mapping
- Custom shaders

## Simulating 3D Effects in 2D

While true 3D isn't possible, you can create pseudo-3D effects:

### Isometric Projection

Simulate 3D using isometric math:

```javascript
// Convert 3D coordinates to isometric 2D
function isoProject(x, y, z) {
  // Isometric projection formula
  const isoX = (x - z) * 0.866;  // cos(30°) ≈ 0.866
  const isoY = y + (x + z) * 0.5;
  return { 
    x: isoX + world.width / 2, 
    y: isoY + world.height / 2 
  };
}

// Create isometric "cube" (diamond shape)
function drawIsoCube(x, y, z, size) {
  // Calculate corners
  const top = isoProject(x, y - size, z);
  const right = isoProject(x + size, y, z);
  const bottom = isoProject(x, y, z + size);
  const left = isoProject(x - size, y, z);
  
  // Draw top face (diamond)
  // Using lines to connect points
  const topFace = display.line(top.x, top.y, right.x, right.y);
  topFace.style = "solid";
  
  display.line(right.x, right.y, bottom.x, bottom.y);
  display.line(bottom.x, bottom.y, left.x, left.y);
  display.line(left.x, left.y, top.x, top.y);
}

// Usage
drawIsoCube(0, 0, 0, 50);
```

### Fake Depth with Scale

Use size to simulate distance:

```javascript
// "3D" particles at different "depths"
const particles = [];

times(50, () => {
  // z is simulated depth (0 = far, 1 = near)
  const z = random.number(0, 1);
  
  const p = display.circle(
    random.number(0, world.width),
    random.number(0, world.height),
    5 + z * 20  // larger = closer
  );
  
  // Properties based on "depth"
  p.color = color.hsb(200, 60, 30 + z * 60);  // brighter = closer
  p.alpha = 30 + z * 70;  // more opaque = closer
  p.scale = 0.5 + z * 0.5;
  
  // Speed based on depth (parallax)
  const speed = 1 + z * 3;
  
  particles.push({ el: p, z: z, speed: speed });
});

// Parallax scrolling
update(() => {
  particles.forEach(p => {
    p.el.x -= p.speed;
    if (p.el.x < -50) {
      p.el.x = world.width + 50;
    }
  });
});
```

### Parallax Layers

Create depth with multiple layers moving at different speeds:

```javascript
// Background layers at different speeds
const layers = [
  { speed: 0.2, y: 400, scale: 0.3, color: color.hsb(220, 40, 60, 60) },   // Far
  { speed: 0.5, y: 350, scale: 0.5, color: color.hsb(200, 50, 70, 80) },   // Mid
  { speed: 1.0, y: 300, scale: 0.8, color: color.hsb(180, 60, 80, 100) }   // Near
];

// Fill layers with "trees"
const trees = [];

layers.forEach((layer, i) => {
  const layerTrees = [];
  times(10, (j) => {
    const tree = display.emoji("🌲", j * 150, layer.y);
    tree.scale = layer.scale;
    tree.color = layer.color;
    tree.alpha = layer.color.alpha || 100;
    layerTrees.push(tree);
  });
  trees.push({ elements: layerTrees, speed: layer.speed });
});

// Parallax scroll
update(() => {
  trees.forEach(layer => {
    layer.elements.forEach(tree => {
      tree.x -= layer.speed;
      if (tree.x < -50) {
        tree.x = world.width + 50;
      }
    });
  });
});
```

### Perspective Scaling

Simulate perspective by scaling based on "z" position:

```javascript
// "3D" world setup
const horizonY = world.height * 0.3;  // Horizon line

// Ground plane elements
const groundObjects = [];
times(20, () => {
  // z from 0 (far) to 1 (near)
  const z = random.number(0, 1);
  
  // Scale and position based on perspective
  const scale = 0.2 + z * 0.8;  // 0.2x to 1.0x
  const y = horizonY + z * (world.height - horizonY);
  
  const obj = display.rect(
    random.number(0, world.width),
    y,
    20 * scale,
    20 * scale
  );
  
  // Color based on distance (atmospheric perspective)
  const brightness = 40 + z * 50;
  obj.color = color.hsb(120, 40, brightness, 100);
  
  groundObjects.push({ el: obj, z: z, baseY: y });
});

// Move "forward" through world
update(() => {
  groundObjects.forEach(obj => {
    // Move "toward" camera (increase z)
    obj.z -= 0.01;
    
    if (obj.z < 0) {
      // Reset to far distance
      obj.z = 1;
      obj.el.x = random.number(0, world.width);
    }
    
    // Recalculate scale and position
    const scale = 0.2 + obj.z * 0.8;
    obj.el.y = obj.baseY;  // Or recalculate based on new z
    obj.el.width = 20 * scale;
    obj.el.height = 20 * scale;
    obj.el.scale = scale;
    
    // Update color
    const brightness = 40 + obj.z * 50;
    obj.el.color = color.hsb(120, 40, brightness, 100);
  });
});
```

### Shadow Effects

Simulate 3D with shadows:

```javascript
function addShadow(element, offsetX = 10, offsetY = 10) {
  // Create shadow below element
  const shadow = display.ellipse(
    element.x + offsetX,
    element.y + offsetY,
    element.width * 0.4 || 30
  );
  
  shadow.color = color.hsb(0, 0, 0, 30);  // Black, transparent
  shadow.borderWidth = 0;
  
  // Scale shadow with element
  shadow.update((event) => {
    shadow.x = element.x + offsetX;
    shadow.y = element.y + offsetY;
    shadow.scale = element.scale * 0.8;
    
    // Destroy shadow if element destroyed
    if (!element.active) {
      shadow.destroy();
    }
  });
  
  // Move shadow to back
  shadow.moveToBack();
  
  return shadow;
}

// Usage
const ball = display.circle(300, 300, 50);
ball.color = color.hsb(200, 80, 90, 100);
addShadow(ball, 15, 20);

// Animate "bounce"
let vy = 5;
ball.update((event) => {
  ball.y += vy;
  vy += 0.5;  // gravity
  
  if (ball.y > 500) {
    ball.y = 500;
    vy = -vy * 0.8;  // bounce with damping
  }
});
```

## Alternative: Use Three.js

For true 3D, use Three.js instead:

```javascript
// This is NOT Firebox code - it's Three.js
import * as THREE from 'three';

const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(75, width / height, 0.1, 1000);
const renderer = new THREE.WebGLRenderer();

const geometry = new THREE.BoxGeometry(1, 1, 1);
const material = new THREE.MeshBasicMaterial({ color: 0x00ff00 });
const cube = new THREE.Mesh(geometry, material);
scene.add(cube);

camera.position.z = 5;

function animate() {
  requestAnimationFrame(animate);
  cube.rotation.x += 0.01;
  cube.rotation.y += 0.01;
  renderer.render(scene, camera);
}
animate();
```

## When to Use Other Tools

Use other platforms when you need:

| Feature | Use Instead |
|---------|-------------|
| True 3D geometry | Three.js, Babylon.js, Unity, Godot |
| 3D physics | Matter.js 3D, Cannon.js, Unity |
| Custom shaders | Three.js with GLSL, Shadertoy |
| Texture mapping | Three.js, p5.js with WebGL |
| 3D model loading | Three.js, Babylon.js |
| Ray tracing | Specialized 3D engines |

## Firebox Strengths

Use Firebox when you need:
- Quick 2D game prototyping
- 2D physics simulations
- Emoji-based graphics
- Rapid iteration
- Browser-based editing
- Simple animations
- Teaching/learning game dev basics
- Quick shareable links

## Limitations Summary

Firebox🔥 strictly does not support:
- ❌ True 3D geometry
- ❌ WebGL shaders
- ❌ 3D lighting
- ❌ Texture mapping
- ❌ 3D camera/depth buffer
- ❌ Custom materials
- ❌ 3D model files (OBJ, GLTF, etc.)

Workarounds:
- ✓ 2D projection tricks (isometric)
- ✓ Scale-based depth simulation
- ✓ Parallax scrolling
- ✓ Shadow effects
- ✓ Particle systems

For full 3D capabilities, use dedicated 3D frameworks or game engines.
