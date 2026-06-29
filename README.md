# Luau Gameplay Systems Showcase

A collection of optimized game mechanics and modular systems built for Roblox Studio. This repository showcases custom physics handling, server-authoritative state management, and lightweight, responsive UI layout.

---

## 🛠️ System Breakdowns

### 1. Custom Ice Boat Physics (Client Simulation)
A vehicle controller engineered to emulate grid-based, low-friction momentum mechanics (inspired by Minecraft ice-boating).

* **Physics Implementation:** Utilizes modern `LinearVelocity` and `AngularVelocity` constraints rather than deprecated body movers, ensuring reliable network ownership and smooth replication.
* **Friction & Drift:** Implements custom sliding deceleration math inside a `Heartbeat` loop, allowing cars/boats to hold structural drifts without losing all directional force instantly.
* **Responsive Input:** Uses exponential decay (`math.exp`) for steering interpolations so turning snaps fluidly based on current frame rates instead of feel-clunky linear steps.

### 2. Server-Authoritative Progression & Leveling
A secure backend script handling player runtime statistics, level scaling, and character capability updates.

* **Anti-Cheat Minded:** Experience points are validated on the server. The script checks a player's `Humanoid.MoveDirection.Magnitude` directly to ensure points are only granted during active, intentional movement.
* **Automated Scaling:** Features dynamic level-up thresholds using flat math formulas (`100 + (level - 1) * 50`) rather than massive, hardcoded memory tables.
* **Lifecycle Management:** Cleanly handles the standard player/character lifecycle (`PlayerAdded` -> `CharacterAdded`) to guarantee statutory attributes (like WalkSpeed updates) load reliably every spawn.

### 3. Dynamic 3D Pop-ups & Fluid Progress Bars
A client-side visual feedback system that scales smoothly with server state changes.

* **Optimal Tweens:** Uses highly optimized, inlined `TweenService` calls to execute snappy UI transitions (Back/Linear easing) without clogging memory with unused variable handles.
* **Anti-Stacking Logic:** Calculates small, randomized X-axis offsets (`math.random`) for 3D BillboardGui indicators so rapid point gains remain cleanly visible instead of overlapping into an unreadable block.
* **Memory Cleanup:** Leverages the `Debris` service alongside timed delays to handle automatic garbage collection, preventing visual element leaks over extended gaming sessions.

---

## 📁 Repository Structure

```text
├── 📁 Ice-Boat-System/
│   └── 📄 ClientBoatController.lua  # Input capture and custom drift physics
├── 📁 Progression-Server/
│   └── 📄 LevelingServer.lua       # Stat creation, validation, and level calculations
└── 📁 Progression-UI/
    ├── 📄 ProgressBarClient.lua    # Real-time tweening for the HUD layout
    └── 📄 PopUpClient.lua          # 3D floating experience indicators
