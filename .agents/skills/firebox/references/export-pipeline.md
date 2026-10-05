# Export Pipeline

Firebox🔥 runs entirely in the browser at https://firebox.no with no built-in export functionality. Projects are saved to your account and can be shared via links.

## Saving Projects

### Account Required

1. Sign up for a free account at https://firebox.no/signup
2. Your code is automatically saved to your account
3. Access your projects from any device by signing in

### Sharing

- Each project has a unique URL
- Share the URL with others to let them view/play your project
- Recipients don't need an account to view (but need one to edit)

## Manual Export Options

### Screen Capture

#### Browser Screenshot

**Chrome/Firefox/Edge:**
- Press `F12` to open DevTools
- Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
- Type "screenshot" and select "Capture screenshot"
- This captures the entire page or just the viewport

#### System Screenshot

**Windows:**
- `Win+Shift+S` for snipping tool (select area)
- `Win+PrtScn` for full screen (saved to Pictures)
- `PrtScn` copies to clipboard

**Mac:**
- `Cmd+Shift+4` for selection
- `Cmd+Shift+5` for options (screen, window, selection)
- `Cmd+Shift+3` for full screen

**Linux:**
- `PrtScn` for full screen
- `Alt+PrtScn` for current window
- `Shift+PrtScn` for selection
- Or use tools: Flameshot, GNOME Screenshot, Shutter

### Video Recording

#### Browser Tools

**Chrome DevTools:**
1. Open DevTools (`F12`)
2. More tools → Rendering
3. Enable "FPS meter" to verify performance

**Screen Recording Software:**
- **OBS Studio** (free, cross-platform)
- **QuickTime Player** (Mac, File → New Screen Recording)
- **Xbox Game Bar** (Windows, `Win+G`)
- **SimpleScreenRecorder** (Linux)

#### Recording Settings

For best quality:
- Resolution: Match your world size
- Frame rate: 60fps for smooth gameplay, 30fps acceptable
- Format: MP4 for editing, WebM for web

**OBS Settings:**
- Output → Recording → Format: MP4
- Video → Base Resolution: Match world size (e.g., 960x640)
- Video → FPS: 60

### GIF Creation

**Using OBS + FFmpeg:**
```bash
# Record with OBS first, then convert:
ffmpeg -i input.mp4 -vf "fps=30,scale=480:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=128[p];[s1][p]paletteuse=dither=bayer" output.gif
```

**Direct Tools:**
- **LICEcap** (Windows/Mac) - select area and record directly to GIF
- **Peek** (Linux) - simple GIF recorder
- **Giphy Capture** (Mac)

**Browser Extensions:**
- Chrome: ScreenToGif, Giphy Capture
- Firefox: Screen Recorder

## Code Export

### Copy-Paste Method

The simplest method:
1. Open your project at https://firebox.no
2. Select all code (`Ctrl+A` or `Cmd+A`)
3. Copy (`Ctrl+C` or `Cmd+C`)
4. Paste into a text file

### Saving Locally

```bash
# Create JavaScript file
cat > my-firebox-project.js << 'EOF'
// Paste your Firebox code here
world.set(960, 640);

const player = display.emoji("🚀", 100, 100);
// ... rest of code
EOF

# Or use editor
nano my-project.js
vim my-project.js
```

### Version Control

```bash
# Initialize git repo
git init
git add my-project.js
git commit -m "Initial Firebox project: [description]"

# Create backup branch
git checkout -b backup-2024-01-15

# Push to GitHub/GitLab for backup
git remote add origin https://github.com/username/firebox-projects.git
git push -u origin main
```

## Documentation Export

### README Template

```markdown
# Project Name

Created with Firebox🔥 (https://firebox.no)

## Description
[Describe what this project does - game, simulation, art piece]

## Controls
- Arrow keys / WASD: [Movement/Action]
- Space: [Jump/Fire/Action]
- Mouse/Touch: [Click interactions]

## How to Run
1. Visit https://firebox.no
2. Sign in to your account (free)
3. Create new project or open existing
4. Paste code from `my-project.js`
5. Click Run/Play

## Screenshots
[Add screenshots or GIFs here]

## Credits
Created by [Your Name]
Date: [Date]
Version: [Version number]
```

## Performance Considerations

### Before Recording

- Close unnecessary browser tabs
- Disable background apps
- Set world size to final output resolution
- Test at target frame rate

### Optimization for Recording

```javascript
// Reduce element count during recording if needed
const RECORDING = false;
const config = {
  particles: RECORDING ? 50 : 200,
  enemies: RECORDING ? 10 : 30
};

// Create elements based on config
times(config.particles, () => {
  spawnParticle();
});

// Disable debug physics during recording
// physics.debug();  // Comment out for final recording
```

### Frame Rate Monitoring

```javascript
// Simple FPS display (approximate)
let lastTime = Date.now();
let frames = 0;
const fpsLabel = ui.label("FPS", world.width - 100, 30);

update(() => {
  frames++;
  const now = Date.now();
  
  if (now - lastTime >= 1000) {
    fpsLabel.value = frames;
    frames = 0;
    lastTime = now;
  }
});
```

## Platform Differences

### Browser Compatibility

Firebox works best in:
- **Chrome/Edge** (Chromium-based) - best performance
- **Firefox** - good compatibility
- **Safari** - may have minor differences

Always test in your target browser before final export.

### Mobile Recording

For mobile demos:
- Record on desktop at mobile resolution (scale world)
- Or use device screen recording:
  - **iOS**: Control Center → Screen Recording
  - **Android**: Varies (often Power+Volume Up, or use AZ Screen Recorder)

## Asset Management

### External Assets

Firebox supports:
- **Emoji** - native support via `display.emoji()`
- **Images** - Not directly supported (use emoji instead)
- **Fonts** - System defaults only via UI labels
- **Audio** - Not supported

### Self-Contained Projects

Keep everything in code:
- Generate graphics procedurally using shapes
- Use emoji library for characters/objects
- Create particle effects with display elements

## Sharing Work

### Social Media

Optimal formats:
- **Twitter/X**: 1200x675, MP4 or GIF, under 5MB
- **Instagram**: 1080x1080 (square) or 1080x1350 (portrait)
- **TikTok**: 1080x1920, vertical, 9:16 ratio
- **Reddit r/firebox**: Direct link or MP4
- **Discord**: MP4 or GIF, under 8MB

### Code Sharing

Platforms for sharing code:
- **GitHub Gist** - easy to share snippets
- **Pastebin** - quick sharing
- **GitHub Repo** - for larger projects
- **CodePen** - requires adapting to their framework (not direct Firebox)
- **JSFiddle** - same limitation

Note: Firebox code is specific to the Firebox runtime and won't run directly in other environments without modification.

## Backup Strategy

### Regular Backups

1. Export code to local files weekly
2. Push to git repository
3. Screenshot key milestones

### Project Archiving

```bash
# Organize by date
mkdir -p firebox-projects/2024/01
cp *.js firebox-projects/2024/01/

# Add README
cat > firebox-projects/README.md << 'EOF'
# Firebox Project Archive

Projects created with https://firebox.no

## 2024-01
- `platformer-demo.js` - Jump and run game
- `particle-system.js` - Physics simulation
- `emoji-art.js` - Generative emoji composition

## 2024-02
- [Add new projects]
EOF

# Commit archive
git add firebox-projects/
git commit -m "Add January 2024 projects"
```

### Multiple Versions

```javascript
// Version comment at top of file
// Version: 1.2.0
// Date: 2024-01-15
// Changes: Added particle effects, fixed collision bug

world.set(960, 640);
// ... rest of code
```

## Limitations

Firebox🔥 does not support:
- Direct MP4/PNG/GIF export from editor
- Headless/batch rendering
- External file loading (images, fonts, audio)
- Custom asset embedding
- Offline execution (requires browser)

Workarounds:
- Use screen recording software for video
- Use browser screenshot tools for images
- Use emoji for all graphics
- Save code manually for backup

For production pipelines with export requirements, consider:
- **p5.js** with saveCanvas(), saveGif()
- **Three.js** with render targets
- **Godot** or **Unity** for full game development
