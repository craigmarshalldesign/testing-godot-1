# New Game Project - 3D Turn-Based Combat RPG

This project is a high-polish 3D Action/RPG prototype built in **Godot 4.x**. It features a seamless transition between free exploration and tactical turn-based combat, with high-quality visual feedback, smart AI, and a robust Game Over system.

---

## 🎮 Game Overview

The game follows a "hybrid" approach where the player explores a 3D environment and enters turn-based combat when approaching enemies. Combat happens in the same world space without scene transitions, keeping the action fluid.

### Key Features
- **Dynamic Transition**: Walking near an enemy triggers combat. Nearby enemies within range automatically join the fray.
- **Game Over System**: A high-polish defeat screen with animated "GAME OVER" text, a full-screen dark overlay, and a pulsing restart prompt.
- **Smart Grouping AI**: Enemies use slot-based targeting to surround the player instead of lining up. They have subtle repulsion logic to stay close together without overlapping perfectly.
- **Advanced Pathfinding**: AI uses `NavigationAgent3D` with progress-based stuck detection. They will perform "panic jumps" if blocked by geography or other enemies.
- **Dynamic Targeting HUD**: A mirrored HUD system displays detailed stats for your currently selected target on the right side of the screen.
- **In-World Feedback**: 3D Floating health bars and damage numbers provide immediate visual impact during combat.
- **Visual Death States**: Defeated combatants (including the player) perform a physics-based "crumple" fall, darken to a gray/black hue, and lose collision.

---

## 🛠 Mechanics Detail

### Combat Flow
1. **Trigger**: Proximity check in `enemy_combat.gd` detects the player within range (`detection_range`).
2. **Setup**: `CombatManager` gathers nearby combatants and sorts them by `Speed` to determine turn order.
3. **Turn Actions**: 
    - **Movement Radius**: During your turn, you can move freely within a radius (derived from your `Speed` stat).
    - **Targeting**: The closest enemy within 6m is automatically targeted with a 3D indicator.
    - **Mid-Air Safety**: Actions like attacking or ending a turn are locked until the combatant is grounded, preventing "floating" combat.
4. **Game Over**: If the player's HP reaches 0:
    - Player character falls on their back and darkens.
    - Camera decouples from player rotation to remain upright and navigable.
    - Enemies ignore the corpse and return to their idle wandering state.
    - An animated Game Over overlay appears with a "Press A / Space to Restart" prompt.

### Navigation & AI
- **Slot Positioning**: Enemies calculate unique positions around the player based on their index in the turn order (circular slotting).
- **Stuck Detection**: If an AI fails to make 5cm of progress toward its target for 0.4s, it attempts a jump. If stuck for 1.5s, it ends its turn gracefully.
- **Repulsion Logic**: Enemies maintain a minimum 0.8m distance from each other, allowing them to crowd onto small platforms or through tight corridors effectively.

### Stat Management
- **Inspector-Driven**: All stats (Max HP, Attack, Defense, Speed) are directly editable in the Godot Inspector.
- **Random Variance**: Enemies spawn with a +/- 3 randomization on their base stats to make every encounter feel unique.

---

---

## 📂 Project Structure

### Enemy System Architecture (Gold Standard)

The enemy system uses a **modular inheritance chain** for maximum reusability, with scripts nested directly inside their respective scene folders.

```
scenes/enteties/enemies/
├── enemy_base.tscn
├── enemy_base.gd
├── scripts-enemy_base/        # Shared base logic
│   ├── enemy_movement.gd
│   └── enemy_combat.gd
├── normal/
│   └── SkeletonWarrior/
│       ├── skeleton_warrior.tscn
│       └── scripts-skeletonwarrior/
└── boss/
    └── boss1/
        ├── boss1.tscn
        └── scripts-boss1/
```

### Combat System (Refactor Planned)
We are moving combat scripts from `scripts/combat/` to a centralized scene-based folder:
- **Location**: `scenes/combat/scripts-combat/`
- **Files**: `combat_manager.gd`, `combat_ui.gd`, `combat_stats.gd`, `floating_info.gd`

---

## 🚀 Next Major Refactor: Player Party System

### Goal
Refactor the player system to mirror the enemy architecture, enabling a 4-character party with character switching. We will use a standalone camera and a shared entity base.

### Proposed Architecture

#### 1. Camera System
- **Folder**: `scenes/camera/`
- **Files**: 
    - `party_camera.tscn`: Standalone SpringArm3D/Camera3D.
    - `scripts-camera/party_camera.gd`: Logic to follow the "active" entity.

#### 2. Player Entity System
- **Folder**: `scenes/enteties/player/`
- **Files**:
    - `player_base.tscn`: Base CharacterBody3D and components.
    - `player_base.gd`: Facade script.
    - `scripts-player_base/`:
        - `player_movement.gd`: Physics and input handling.
        - `player_combat.gd`: Player-specific combat turn logic.
    - `characters/`: Specific class definitions (Warrior, Mage, etc.) following the same sub-folder pattern as enemies.

#### 3. Party Manager
- **Location**: `scenes/enteties/player/party_manager.gd`
- **Role**: Tracks the group, handles character swapping, and communicates turn order to the CombatManager.

### Implementation Steps

#### Phase 1: Infrastructure & Camera
1. Create `scenes/camera/` and implement the `PartyCamera`.
2. Move Combat scripts to `scenes/combat/scripts-combat/`.
3. Test camera following the *existing* player.

#### Phase 2: Player Base & First Character
4. Create the `player_base` structure under `scenes/enteties/player/`.
5. Implement the first character (e.g., Warrior) inheriting from `player_base`.
6. Implement the `PartyManager` to spawn/set the active character.

#### Phase 3: Transition
7. Create a new test scene using the new system.
8. Validate turn-based flow with the new character system.
9. Final migration of existing maps to the new party system.

---

## 📝 Current Development State

### Recently Completed
- **Enemy Inheritance Chain**: Modular scripts (enemy_movement → enemy_combat → enemy_base)
- **SkeletonWarrior**: New enemy type using the refactored system
- **Facing Direction Fix**: Enemies face movement direction during walking AND jumping
- **Player Attack Fix**: Player can now deal damage to enemies correctly

### Suggested Immediate Tasks
1. **Move Combat Scripts**: Relocate to `scenes/combat/scripts-combat/` to match the new standard.
2. **Implement PartyCamera**: Separate the camera from the player node.
3. **SkeletonWarrior Polish**: Add varied colors/sizes as needed.

---

*Last Updated: December 23, 2025*
