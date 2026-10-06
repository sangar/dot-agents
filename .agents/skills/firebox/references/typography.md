# Typography

Firebox🔥 uses UI labels for text display rather than full typography features.

## UI Labels

### Basic Labels

```javascript
// Simple label
ui.label("Hello World");

// Label at position
ui.label("Score", 100, 50);

// Label with value
const scoreLabel = ui.label("Score", 100, 50);
scoreLabel.value = 100;
// Displays: "Score: 100"
```

### Label Properties

```javascript
const label = ui.label("Health", 50, 50);

// Set text
label.text = "HP";

// Set value (shown after colon)
label.value = 100;

// Combined display: "HP: 100"
```

### Dynamic Score Display

```javascript
const score = 0;
const scoreDisplay = ui.label("Score", 50, 50);
scoreDisplay.value = score;

// Update in game loop
update(() => {
  scoreDisplay.value = Math.floor(score);
});
```

### Multiple Stats

```javascript
// Create stat labels
const stats = {
  health: ui.label("❤️ Health", 50, 50),
  score: ui.label("⭐ Score", 50, 100),
  level: ui.label("📊 Level", 50, 150),
  time: ui.label("⏱️ Time", 50, 200)
};

stats.health.value = 100;
stats.score.value = 0;
stats.level.value = 1;
stats.time.value = "0:00";

// Update during gameplay
update(() => {
  stats.score.value = gameScore;
  stats.health.value = playerHealth;
});
```

### Emoji Labels

```javascript
// Using emoji as label prefix
ui.label("🎯 Target: 50");
ui.label("💰 Coins: 100");
ui.label("⚡ Power: 75%");
ui.label("🔥 Heat: High");
```

## Text as Visual Elements

### Letters as Emoji

```javascript
// Firebox doesn't have text rendering, use emoji or simple graphics
// For alphabet-style displays, use appropriate emojis:

const letters = {
  A: "🅰️",
  B: "🅱️",
  O: "🅾️",
  P: "🅿️",
  AB: "🆎",
  CL: "🆑",
  COOL: "🆒",
  FREE: "🆓",
  ID: "🆔",
  NEW: "🆕",
  NG: "🆖",
  OK: "🆗",
  SOS: "🆘",
  UP: "🆙",
  VS: "🆚"
};

// Display text with letter emojis
display.emoji(letters.A, 100, 100);
display.emoji(letters.B, 150, 100);
display.emoji(letters.OK, 200, 100);
```

### Numbers as Emoji

```javascript
const numbers = ["0️⃣", "1️⃣", "2️⃣", "3️⃣", "4️⃣", "5️⃣", "6️⃣", "7️⃣", "8️⃣", "9️⃣", "🔟"];

function displayNumber(num, x, y) {
  const digits = num.toString().split('');
  digits.forEach((digit, i) => {
    display.emoji(numbers[parseInt(digit)], x + i * 40, y);
  });
}

// Usage
displayNumber(42, 100, 200);
```

## Visual Text Effects

### Bouncing Letters

```javascript
const text = ["🅷", "🅴", "🅻", "🅻", "🅾"];
const letters = [];

// Create letter elements
text.forEach((char, i) => {
  const letter = display.emoji(char, 200 + i * 60, 300);
  letters.push({
    el: letter,
    baseY: 300,
    offset: i * 0.5,
    speed: 0.1
  });
});

let time = 0;
update(() => {
  time += 0.05;

  letters.forEach(l => {
    const bounce = Math.sin(time + l.offset) * 20;
    l.el.y = l.baseY + bounce;
  });
});
```

### Fading Label

```javascript
// Create temporary message
function showMessage(text, x, y, duration = 2000) {
  // Using emoji display since labels don't move
  const msg = display.emoji("💬", x, y);
  msg.say(text, duration);

  // Animate fade
  msg.alpha = 100;
  let age = 0;

  msg.update((event) => {
    age += 1;
    const life = 1 - (age / (duration / 16));  // approximate frames
    msg.alpha = Math.max(0, 100 * life);

    // Move up
    msg.y -= 1;

    if (msg.alpha <= 0) {
      msg.destroy();
    }
  });

  return msg;
}

// Usage on score
function showPoints(x, y, points) {
  showMessage("+" + points, x, y, 1500);
}
```

### Color-Changing Elements

```javascript
// For colored text effect, use colored shapes behind emojis
function createColoredText(text, x, y, colors) {
  const chars = text.split('');

  chars.forEach((char, i) => {
    // Create colored rectangle behind
    const bg = display.rect(x + i * 35, y, 30, 40);
    bg.color = colors[i % colors.length];
    bg.cornerRadius = 5;
    bg.borderWidth = 0;

    // Add emoji on top
    if (char === "A") display.emoji("🅰️", x + i * 35, y);
    if (char === "B") display.emoji("🅱️", x + i * 35, y);
    // etc...
  });
}

// Create rainbow text effect
const rainbow = [
  color.hsb(0, 90, 90, 100),    // Red
  color.hsb(30, 90, 90, 100),   // Orange
  color.hsb(60, 90, 90, 100),   // Yellow
  color.hsb(120, 90, 90, 100),  // Green
  color.hsb(180, 90, 90, 100),  // Cyan
  color.hsb(240, 90, 90, 100),  // Blue
  color.hsb(280, 90, 90, 100)   // Purple
];

createColoredText("HELLO", 100, 100, rainbow);
```

## Score and HUD

### Game HUD Layout

```javascript
// Create game HUD
const hud = {
  // Top left - Health
  healthLabel: ui.label("❤️", 30, 30),

  // Top center - Score
  scoreLabel: ui.label("Score", world.width/2 - 50, 30),

  // Top right - Timer
  timeLabel: ui.label("⏱️", world.width - 150, 30),

  // Bottom left - Level
  levelLabel: ui.label("Level", 30, world.height - 50)
};

// Style with values
hud.healthLabel.value = "100%";
hud.scoreLabel.value = 0;
hud.timeLabel.value = "60s";
hud.levelLabel.value = 1;

// Update during game
let gameScore = 0;
let gameTime = 60;

update(() => {
  hud.scoreLabel.value = Math.floor(gameScore);
  hud.timeLabel.value = Math.ceil(gameTime) + "s";

  // Flash when low time
  if (gameTime < 10) {
    hud.timeLabel.x = world.width - 150 + Math.sin(Date.now() / 100) * 5;
  }
});
```

### Message Display

```javascript
function showMessage(text, duration = 2000) {
  const msg = display.emoji("📢", world.width/2, world.height/2);
  msg.say(text, duration);
  msg.scale = 2;

  timeout(duration, () => {
    msg.destroy();
  });

  return msg;
}

// Usage
showMessage("🎉 Level Complete!");
showMessage("⚠️ Warning!", 1500);
```

## Using Labels with Buttons

```javascript
// Button with label
const startBtn = ui.button("Start Game", 400, 400);

startBtn.action(() => {
  startGame();
});

// Dynamic button text
const toggleBtn = ui.button("Sound: ON", 400, 500);
let soundOn = true;

toggleBtn.action(() => {
  soundOn = !soundOn;
  toggleBtn.text = "Sound: " + (soundOn ? "ON" : "OFF");
});
```

## Progress Bars

```javascript
const healthBar = ui.progress(100, 50, 200, 25);
healthBar.progressColor = color.hsb(0, 80, 80, 100);  // Red
healthBar.trackColor = color.hsb(0, 0, 30, 100);      // Dark gray

// Update value (0.0 to 1.0)
healthBar.value = 0.75;  // 75%

// Update during game
let playerHealth = 100;
const maxHealth = 100;

update(() => {
  healthBar.value = playerHealth / maxHealth;

  // Change color based on health
  if (playerHealth > 60) {
    healthBar.progressColor = color.hsb(120, 80, 80, 100);  // Green
  } else if (playerHealth > 30) {
    healthBar.progressColor = color.hsb(60, 80, 80, 100);   // Yellow
  } else {
    healthBar.progressColor = color.hsb(0, 80, 80, 100);    // Red
  }
});
```

## Best Practices

- Use UI labels for simple stats and scores
- Use emoji for expressive text
- Position labels consistently in HUD areas
- Update values rather than recreating labels
- Use emoji prefixes to add visual meaning
- Consider color-coded shapes behind labels for emphasis
- Use `element.say()` for temporary messages on elements
- Use buttons with action callbacks for interactive text

## Limitations

Firebox🔥 typography is limited compared to full creative coding platforms:
- No custom font loading
- No text size control (use `element.scale`)
- No text alignment options
- No multi-line text
- Limited to the UI label component
- Labels are fixed in position (can't move easily)

For complex typography, use:
- Emoji characters for icons and symbols
- Colored shapes arranged as visual text
- Multiple single-character emoji labels for words
- Scale elements for larger text effects
