# ⚡ Taskora

<p align="center">
  <strong>Master Your Time, Flow With Focus.</strong><br>
  <em>A modern, high-performance, responsive task management and productivity suite built with Flutter & Riverpod.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.5+-02569B?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/State-Riverpod_2.6-blueviolet" alt="Riverpod">
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License">
  <img src="https://img.shields.io/badge/Palettes-14_Themes-FF5E7E" alt="14 Palettes">
  <img src="https://img.shields.io/badge/Platform-iOS_|_Android_|_macOS_|_Web-lightgrey" alt="Platforms">
</p>

---

## 🌟 Overview

**Taskora** is an ultra-modern productivity companion engineered to combine clean architecture, fluid 60fps animations, intelligent natural language processing, and habit-forming gamification into a cohesive cross-platform experience.

Whether managing complex multi-stage work projects on tablet/desktop or capturing quick reminders on the go, Taskora adapts dynamically to your workflow, form factor, and personal aesthetic.

---

## ✨ Key Features

### 1. 🎮 Productivity Gamification & Daily Streak Engine
* **Daily Streaks (`🔥`)**: Tracks consecutive days of task execution with real-time status protection and risk indicators.
* **12-Tier Level Progression (`⚡`)**: Earn XP for your accomplishments (+25 base, +50 priority, +10 subtasks, +50 Pomodoro). Advance from *Apprentice Initiate* to *Productivity Overlord*.
* **12 Milestone Achievement Trophies (`🏅`)**: Unlock trophies in the **Hall of Fame** (First Spark, Boss Slayer, Early Bird, Night Owl, Deep Focus, Centurion).
* **Confetti Celebration Particles (`🎉`)**: Custom pure-canvas particle system showering colorful confetti ribbons and stars dynamically matched to your active theme palette upon completing tasks or leveling up.

### 2. 🧠 Natural Language Task Quick-Add Engine (NLP)
* **Intelligent Entity Extraction**: Type naturally (e.g., *"Team standup tomorrow at 9:30am high priority #work"*) to automatically extract titles, due dates, reminder timestamps, priority levels, and category workspaces.
* **Interactive Token Badges**: Real-time syntax highlighting showing detected date, time, and priority tags with one-tap removal.
* **In-Form Intelligence**: Seamlessly embedded in the quick-add bar on Dashboard and the Task Creation Modal.

### 3. 🎨 14 Dynamic High-Aesthetic Theme Palettes
Fully reactive Material 3 engine dynamically rendered in both **Light** and **Dark** modes across all screens:
1. **Neon Lime**: Acid Lime & Cyber Carbon
2. **Sunset Mirage**: Neon Peach & Aurora Violet
3. **Obsidian Gold**: Champagne Gold & Solar Amber
4. **Nordic Glacier**: Glacier Ice & Polar Mint
5. **Zen Matcha**: Matcha Teal & Warm Terracotta
6. **Electric Violet**: Electric Iris & Cyan
7. **Cyber Ocean**: Bioluminescent Cyan & Azure
8. **Stealth Titanium**: Titanium Slate & Crimson Laser
9. **Crimson Eclipse**: Tokyo Crimson & Neon Violet
10. **Desert Dune**: Mojave Amber & Terracotta
11. **Aurora Borealis**: Polar Emerald & Cosmic Indigo
12. **Bubblegum Cyber**: Vaporwave Pink & Cyan Spark
13. **Amethyst Haze**: Royal Amethyst & Mystic Orchid
14. **Matrix Emerald**: Phosphor Terminal & Cyber Jade

### 4. 📱 Circular Aura Modern Navigation Bar
* **Circular Glow Aura**: Active tab indicator with radial gradient glow.
* **Curved Edge-to-Edge Frame**: 26dp top border radius, flush zero-gap horizontal alignment, and smooth spring physics transitions.

### 5. ✨ Cinematic Splash Screen & 3D Interactive Emblem
* **Celestial Ambient Pulse**: Breathing multi-stage aurora gradient with floating stardust particles.
* **3D Parallax Emblem**: Floating zero-gravity icon with gyroscopic tilt, interactive touch deflection, and animated completion checkmark.

### 6. 💻 Responsive Master-Detail Workspace
* **Adaptive Form Factors**: Seamlessly transitions between single-column mobile view, split-pane tablet view, and expanded desktop layout.
* **Grouped Smart Lists & Kanban Board**: Switch between categorized task sections and a 3-column drag-and-drop Kanban workflow (*To Do*, *In Progress*, *Done*).

### 7. ⏱️ Focus Mode & Pomodoro Timer
* **Deep Work Tracking**: Built-in 25-minute Pomodoro timer with circular countdown painter.
* **Task-Linked Focus Sessions**: Link sessions to specific tasks to automatically log focused minutes, calculate stats, and award bonus XP.

### 8. 📳 Tactile Haptic Micro-Interactions
* **System-Wide Tactile Feedback**: Subtle clicks on chips, checkboxes, and buttons with custom celebration pulses on completions.
* **In-App Controls & Live Tester**: Dedicated toggle with persistent memory and interactive test buttons (**Light Impact**, **Medium Impact**, **Task Pulse**) adapting to Light and Dark theme contrast.

### 9. 💾 Offline-First Atomic Storage & Data Freedom
* **100% Offline-Ready**: Fast atomic JSON persistence using `SharedPreferences`.
* **Data Control**: One-tap full JSON backup export to clipboard and instant restore capabilities.

---

## 🏗️ Architecture & Project Structure

Taskora follows **Feature-First Clean Architecture** principles powered by **Riverpod**:

```
lib/
├── core/
│   ├── constants/        # App constants, animation timings, layout defaults, persistence keys
│   ├── responsive/       # Breakpoint helpers (mobile, tablet, desktop)
│   ├── router/           # GoRouter declarative routing configurations
│   ├── services/         # Atomic LocalStorageService, NotificationService
│   ├── theme/            # Material 3 AppTheme, 14-palette engine, ThemeProvider
│   └── utils/            # DateFormatUtil, HapticFeedbackUtil
├── features/
│   ├── analytics/        # Category breakdown & weekly productivity bar charts
│   ├── dashboard/        # StreakLevelCard, ProgressRingCard, NlpQuickAddBar, Smart Task List
│   ├── focus_timer/      # Pomodoro timer, CircularTimerPainter, Task linking
│   ├── gamification/     # XP leveling curve, 12 Badges, Streak engine, Confetti canvas
│   ├── onboarding/       # Interactive welcome walkthrough
│   ├── settings/         # Appearance, Theme Palettes, Haptics, Data backup/restore
│   ├── splash/           # Ambient celestial background, 3D animated emblem
│   └── tasks/            # CRUD, TaskRepository, NLP Parser, Kanban board, Master-Detail
└── main.dart             # Root ProviderScope, accessible text scaling bounds
```

---

## 🚀 Tech Stack

| Domain | Technology / Package | Purpose |
|---|---|---|
| **Framework** | Flutter 3.5+ / Dart 3.5+ | High-performance multiplatform UI |
| **State Management** | `flutter_riverpod: ^2.6.1` | Predictable, immutable, compile-safe state |
| **Routing** | `go_router: ^14.8.1` | Deep-linking, declarative nested routes |
| **Local Persistence** | `shared_preferences: ^2.5.2` | Fast atomic offline-first JSON cache |
| **Notifications** | `flutter_local_notifications: ^18.0.1` | Scheduled reminders and task alert triggers |
| **Visuals & Canvas** | Flutter CustomPainter | Circular aura, confetti physics, 3D emblem |

---

## 🛠️ Getting Started

### Prerequisites
* [Flutter SDK](https://flutter.dev/docs/get-started/install) (`>= 3.5.0`)
* Dart SDK (`>= 3.5.0`)
* Android Studio / Xcode / VS Code with Flutter extension

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/taskora.git
   cd taskora
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run static analysis:**
   ```bash
   flutter analyze
   ```

4. **Execute unit & widget tests:**
   ```bash
   flutter test
   ```

5. **Launch the application:**
   ```bash
   # For Android or iOS Simulator
   flutter run

   # For macOS Desktop
   flutter run -d macos

   # For Web
   flutter run -d chrome
   ```

---

## 🧪 Testing

Taskora includes extensive unit and integration tests covering:
* **NLP Task Parsing**: Tokenization, relative date resolution, priority extraction.
* **Gamification & Streaks**: XP math, level curves, daily streak state transitions, badge unlocks.
* **Theme Engine**: Palette deserialization, contrast consistency, Light/Dark theme generation.
* **Haptics Persistence**: Toggle state synchronization and global mute verification.

Run all tests via:
```bash
flutter test
```

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

<p align="center">
  Crafted with focus and precision for modern productivity.
</p>
