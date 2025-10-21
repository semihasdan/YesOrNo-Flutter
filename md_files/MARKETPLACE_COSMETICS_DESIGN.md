# Marketplace Cosmetics Design Specification

## 📐 Visual Asset Guidelines

This document provides detailed design specifications for implementing the Marketplace cosmetics across different screens in the Yes or No Word Duel app.

---

## 🖼️ Avatar Frames

### Purpose
Avatar frames are decorative borders that surround the user's profile picture, emphasizing their style and achievements. They are visible in multiple locations to maximize their value.

### Display Locations
1. **Home Screen Header** (Top-left corner)
2. **Matchup Screen** (Pre-game user vs user display)
3. **In-Game Duel Screen** (During active gameplay)
4. **Profile Screen** (User's profile page)
5. **Marketplace Preview** (When browsing/purchasing)

### Frame Styles & Implementation

#### 1. Basic Frame (Free)
**Visual Properties:**
- Border width: 3px
- Color: Cyan (#00FFFF)
- Glow: Subtle cyan blur (8px radius, 50% opacity)
- Animation: None
- Material: Solid color

**Usage:**
```dart
AvatarFrameWidget(
  imageUrl: userAvatar,
  size: 60.0,
  frameStyle: AvatarFrameStyle.basic,
)
```

#### 2. Raptor Rank Frame (500 coins)
**Visual Properties:**
- Border width: 4px
- Gradient: Gold (#FFD700) to Amber (#FFB74D)
- Glow: Golden blur (12px radius, 60% opacity)
- Animation: None
- Material: Metallic gradient

**Design Notes:**
- Top-to-bottom gradient (lighter gold at top)
- Associated with achievement/rank
- Prestige indicator

#### 3. Neon Glitch Aura (750 coins)
**Visual Properties:**
- Border width: 4px
- Gradient: Cyan (#00FFFF) to Magenta (#FF00FF)
- Glow: Alternating cyan/magenta (15px radius, 70% opacity)
- Animation: Gradient rotation (2s loop)
- Material: Animated gradient

**Design Notes:**
- Diagonal gradient (top-left cyan, bottom-right magenta)
- Subtle rotation animation creates "glitch" effect
- Futuristic, cyberpunk aesthetic

**Animation Specification:**
```
0s:   Cyan (TL) → Magenta (BR)
1s:   Magenta (TL) → Cyan (BR)
2s:   Cyan (TL) → Magenta (BR) [loop]
```

#### 4. Holographic (1,000 coins)
**Visual Properties:**
- Border width: 4px
- Gradient: Rainbow (Cyan → Magenta → Gold → Green)
- Glow: Multi-color blur (18px radius, 70% opacity)
- Animation: Rainbow shimmer (3s loop)
- Material: Holographic iridescent

**Design Notes:**
- 4-color gradient rotates continuously
- Creates iridescent "holographic" effect
- Premium feel, high-tier cosmetic

**Color Sequence:**
```
Position 0%:   Cyan (#00FFFF)
Position 33%:  Magenta (#FF00FF)
Position 66%:  Gold (#FFD700)
Position 100%: Spring Green (#00FF7F)
```

#### 5. Legendary Aura (2,000 coins)
**Visual Properties:**
- Border width: 5px
- Gradient: Gold (#FFD700) → Amber (#FFB74D) → Gold
- Glow: Intense golden blur (20px radius, 80% opacity)
- Animation: Pulsing glow + floating particles
- Material: Radiant metal with particle effects

**Particle Specification:**
- Count: 8 particles
- Size: 4px circles
- Color: Gold with 80% opacity glow
- Position: Distributed evenly around circle (45° intervals)
- Animation: Gentle float (±10px vertical, 2s loop, staggered)

**Design Notes:**
- Most premium frame available
- Particles create "aura" effect
- Conveys ultimate prestige and achievement

**Particle Positions (360° around avatar):**
```
0°   (Top)
45°  (Top-right)
90°  (Right)
135° (Bottom-right)
180° (Bottom)
225° (Bottom-left)
270° (Left)
315° (Top-left)
```

---

## 💬 Question Bubble Skins

### Purpose
Bubble skins modify the appearance of question and answer bubbles during the In-Game Duel Screen, allowing users to personalize the game interface.

### Display Location
- **In-Game Duel Screen** (Question text containers)

### Elements Affected
1. Question text bubble (main question)
2. "YES" answer bubble
3. "NO" answer bubble

### Skin Styles

#### 1. Default (Free)
**Visual Properties:**
- Background: Semi-transparent dark (#141E1EB3 - 70% opacity)
- Border: 1px solid cyan/magenta (depending on YES/NO)
- Corner Radius: 16px
- Glow: Minimal (matching border color, 8px)
- Pattern: None

#### 2. Holographic (400 coins)
**Visual Properties:**
- Background: Semi-transparent with iridescent overlay
- Pattern: Diagonal shimmer lines
- Border: 2px rainbow gradient
- Corner Radius: 20px
- Glow: Multi-color (15px, rotating)
- Texture: Holographic foil effect

**Implementation Notes:**
- Add diagonal gradient overlay (45° angle)
- Shimmer moves from top-left to bottom-right (2s loop)
- Creates "holographic trading card" appearance

#### 3. Neon Pulse (600 coins)
**Visual Properties:**
- Background: Dark with neon inner glow
- Border: 3px thick, pulsing neon
- Corner Radius: 16px
- Glow: Intense, pulsing (20px → 30px, 1.5s loop)
- Animation: Breathing glow effect

**Implementation Notes:**
- Border and glow pulse in sync
- YES = Cyan pulse, NO = Magenta pulse
- Creates "breathing" neon sign effect

---

## 🎭 Victory Taunts / Emotes

### Purpose
Victory taunts are short text/emoji messages displayed on the Post-Game Victory Screen and sent to the opponent, adding personality and social interaction.

### Display Locations
1. **Post-Game Victory Screen** (Winner's screen)
2. **Post-Game Defeat Screen** (Opponent sees winner's taunt)

### UI Placement
- **Position**: Center of victory screen, below score
- **Size**: Large text (24-28px)
- **Animation**: Slide-in from bottom with bounce
- **Background**: Glassmorphic bubble with glow
- **Duration**: Displayed for 3 seconds

### Taunt Styles

#### 1. GG (100 coins)
**Message**: "Good Game! 🎮"
**Theme**: Sportsmanship
**Color**: Spring Green (#00FF7F)
**Icon**: Game controller emoji
**Tone**: Friendly, respectful

#### 2. On Fire (150 coins)
**Message**: "🔥 Too Hot! 🔥"
**Theme**: Confidence
**Color**: Amber/Orange (#FFB74D)
**Icon**: Fire emojis
**Tone**: Playful boasting

#### 3. Genius (200 coins)
**Message**: "Big Brain Time! 🧠"
**Theme**: Intelligence
**Color**: Cyan (#00FFFF)
**Icon**: Brain emoji
**Tone**: Witty, clever

### Visual Design

```
┌─────────────────────────────────┐
│                                 │
│         🎯 VICTORY! 🎯         │
│                                 │
│         Score: 5 - 3            │
│                                 │
│    ┌─────────────────────┐     │
│    │   🔥 Too Hot! 🔥   │     │ ← Taunt Display
│    └─────────────────────┘     │
│                                 │
│    [Continue] [Rematch]         │
│                                 │
└─────────────────────────────────┘
```

**Container Properties:**
- Background: Glassmorphic (#141E1EB3)
- Border: 2px matching taunt color
- Corner Radius: 24px
- Padding: 16px horizontal, 12px vertical
- Glow: Matching color, 15px blur

---

## 💡 Hint Refills (Consumables)

### Purpose
Consumable items that provide assistance during gameplay. Unlike cosmetics, these are used up and must be repurchased.

### Display Locations
1. **Marketplace** (Purchase interface)
2. **In-Game UI** (Usage interface)
3. **Inventory** (Profile screen, shows count)

### Visual Design

#### Marketplace Display

**Single Hint Icon:**
```
┌───────────────┐
│               │
│      ⚡       │  ← Lightning bolt (48px)
│               │
│  Hint Refill  │  ← Item name
│               │
│  Get 1 hint   │  ← Description
│  to use in    │
│    duels      │
│               │
│  ┌─────────┐  │
│  │ 💰 50  │  │  ← Price button
│  └─────────┘  │
└───────────────┘
```

**Icon Properties:**
- Symbol: Lightning bolt (⚡) or light bulb (💡)
- Color: Gold (#FFD700)
- Size: 48px
- Glow: Golden, 12px blur
- Background: Transparent or subtle gold tint

#### In-Game Usage Interface

**Hint Button (when available):**
```
┌──────────────────────┐
│                      │
│     Question...      │
│                      │
│   [YES]    [NO]     │
│                      │
│   ⚡ Hint (2)       │ ← Shows remaining count
│                      │
└──────────────────────┘
```

**Properties:**
- Position: Below YES/NO buttons
- Background: Gold tint (#FFD70033)
- Border: 2px gold
- Text: "Hint" + remaining count
- Icon: Lightning bolt
- Disabled state: Greyed out when count = 0

#### Pack Sizes

**5x Pack:**
- Icon: Gift box (🎁) with "5x" badge
- Value indicator: "20% savings!" ribbon
- Background: Enhanced gold gradient

**10x Pack:**
- Icon: Treasure chest (📦) with "10x" badge
- Value indicator: "Best Value! 30% savings!" ribbon
- Background: Premium gold gradient with sparkles

---

## 🎨 Color Palette Reference

### Primary Colors
```
Cyan:          #00FFFF  (Primary actions, basic frames)
Magenta:       #FF00FF  (Secondary actions)
Gold:          #FFD700  (Rewards, premium items)
Spring Green:  #00FF7F  (Success, positive feedback)
Crimson:       #FF4136  (Danger, negative feedback)
```

### Gradient Colors
```
Amber:         #FFB74D  (Warmth, accent)
Cerulean:      #4FC3F7  (Cool accent)
```

### Background Colors
```
Dark Navy:     #0A192F  (Primary background)
Dark Blue:     #0D1B2A  (Secondary background)
Dark Purple:   #0D0B1A  (Tertiary background)
```

### UI Colors
```
Text Primary:    #FFFFFF  (Main text)
Text Secondary:  #9BBBBB  (Subtitles, descriptions)
Border Glass:    #FFFFFF1A (10% white, glassmorphism)
Glass Panel:     #14141EB3 (70% opacity dark panel)
```

---

## 📏 Sizing Guidelines

### Avatar Sizes by Context

| Context | Avatar Size | Frame Width | Glow Radius |
|---------|-------------|-------------|-------------|
| Home Header | 50px | 3-5px | 8-20px |
| Matchup Screen | 100px | 4-6px | 12-25px |
| In-Game (Small) | 60px | 3-5px | 8-20px |
| Profile Screen | 128px | 4-6px | 15-30px |
| Marketplace Preview | 80px | 4-5px | 12-22px |

### Bubble Sizes

| Element | Min Width | Max Width | Height | Corner Radius |
|---------|-----------|-----------|--------|---------------|
| Question Bubble | 280px | 90% screen | Auto | 16-20px |
| Answer Bubble | 120px | 160px | 60px | 12-16px |

### Button Sizes

| Button Type | Width | Height | Font Size |
|-------------|-------|--------|-----------|
| Primary Action | 100% | 132px | 24px |
| Secondary Action | 100% | 132px | 24px |
| Marketplace Buy | 100% | 40px | 14px |
| Hint Usage | Auto | 44px | 16px |

---

## 🎬 Animation Specifications

### Avatar Frame Animations

**Neon Glitch (2s loop):**
```
Keyframes:
0%:   gradient(45deg, cyan, magenta)
50%:  gradient(45deg, magenta, cyan)
100%: gradient(45deg, cyan, magenta)
```

**Holographic (3s loop):**
```
Keyframes:
0%:   gradient rotation 0deg
25%:  gradient rotation 90deg
50%:  gradient rotation 180deg
75%:  gradient rotation 270deg
100%: gradient rotation 360deg
```

**Legendary Particles (2s loop, staggered):**
```
Each particle:
0%:   y offset 0px, opacity 0.8
50%:  y offset -10px, opacity 1.0
100%: y offset 0px, opacity 0.8

Stagger delay: index * 0.25s
```

### Bubble Skin Animations

**Neon Pulse (1.5s loop):**
```
Keyframes:
0%:   glow radius 20px, opacity 0.6
50%:  glow radius 30px, opacity 0.9
100%: glow radius 20px, opacity 0.6
```

### Victory Taunt Animation

**Entrance (0.5s):**
```
0%:   translateY(50px), opacity 0, scale 0.8
100%: translateY(0), opacity 1, scale 1.0
Easing: cubic-bezier(0.34, 1.56, 0.64, 1) [bounce]
```

---

## 🔧 Implementation Notes

### Performance Considerations
1. **Animated frames**: Use `AnimationController` with limited fps (30fps sufficient)
2. **Particle effects**: Limit to legendary frame only
3. **Glow effects**: Use `BoxShadow` with blur radius (hardware accelerated)
4. **Gradients**: Use `LinearGradient` or `RadialGradient` (hardware accelerated)

### Accessibility
1. **Frame borders**: Maintain minimum 3px width for visibility
2. **Color contrast**: All text must have 4.5:1 contrast ratio
3. **Animations**: Respect system "reduce motion" settings
4. **Touch targets**: Minimum 44x44px for interactive elements

### Platform Considerations
- **iOS**: BoxShadow performs well on Metal
- **Android**: Limit simultaneous animations
- **Web**: Use CSS transforms when possible
- **Desktop**: Can handle more complex animations

---

## 🎯 Cosmetic Value Proposition

### Avatar Frames
**Why users buy:**
- Self-expression and personalization
- Show off achievements/status
- Stand out in matchups
- Visible to opponents (social proof)

**Price justification:**
- Basic (Free): Default experience
- Raptor (500): Mid-tier, achievement-based
- Neon (750): Animated, premium feel
- Holographic (1000): Rare, high visual appeal
- Legendary (2000): Ultimate prestige item

### Bubble Skins
**Why users buy:**
- Personalize gameplay experience
- Reduce visual fatigue with variety
- Match aesthetic preferences

### Victory Taunts
**Why users buy:**
- Express personality
- Add fun/humor to wins
- Social interaction with opponents
- Low commitment purchase (100-200 coins)

### Hint Refills
**Why users buy:**
- Convenience (skip grinding)
- "Pay-to-progress" faster
- Emergency assistance in tough matches
- Best value packs encourage bulk purchase

---

## 📱 Cross-Screen Consistency

### Frames Must Appear On:
1. ✅ Home Screen header
2. ✅ Profile Screen
3. ⚠️ Matchup Screen (needs implementation)
4. ⚠️ In-Game Duel Screen (needs implementation)
5. ⚠️ Post-Game Screen (needs implementation)

### Bubble Skins Applied To:
1. ⚠️ Question display bubble (needs implementation)
2. ⚠️ YES answer bubble (needs implementation)
3. ⚠️ NO answer bubble (needs implementation)

### Taunts Displayed On:
1. ⚠️ Post-Game Victory Screen (needs implementation)
2. ⚠️ Post-Game Defeat Screen (opponent view) (needs implementation)

### Hints Available In:
1. ✅ Marketplace (purchase interface complete)
2. ⚠️ In-Game UI (usage button needs implementation)
3. ⚠️ Profile/Inventory (count display needs implementation)

**Legend:**
- ✅ Implemented
- ⚠️ Requires implementation

---

## 🎨 Asset Requirements

### For Future Design Team

If creating custom assets (vs. programmatic rendering):

**Avatar Frames:**
- Format: PNG with transparency
- Size: 256x256px (scales down)
- Layers: Frame border only (no background)
- Export: @1x, @2x, @3x for multi-DPI

**Bubble Skins:**
- Format: 9-patch PNG or SVG
- Stretchable areas for variable text length
- Include glow/shadow in asset

**Taunt Backgrounds:**
- Format: PNG or SVG
- Size: Responsive width, 60px height
- Include glow effect in asset

**Hint Icons:**
- Format: PNG or vector
- Size: 48x48px minimum
- Export: @1x, @2x, @3x

---

## ✨ Future Enhancement Ideas

### Seasonal Frames
- Halloween: Spooky purple glow
- Christmas: Red/green festive
- New Year: Fireworks effect

### Animated Bubble Skins
- Matrix: Falling code background
- Particle: Floating particles inside bubble
- Liquid: Water ripple effect

### Advanced Taunts
- GIF support: Animated emoji
- Sound effects: Brief audio clip
- Custom text: User-written messages (moderated)

### Premium Hints
- Super Hint: Eliminates wrong answer (100 coins)
- Time Freeze: +5 seconds (75 coins)
- Double Points: 2x score for question (150 coins)

---

This specification provides all the visual and technical details needed to implement marketplace cosmetics consistently across the entire application.
