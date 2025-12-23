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
1. **Trigger**: Proximity check in `enemy.gd` detects the player within 10m.
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

## 📂 Project Structure

### Core Systems
- `res://scripts/combat/combat_manager.gd`: **The Central Hub**. Manages turn order, participant tracking, and the Game Over sequence.
- `res://scripts/combat/combat_ui.gd`: Manages the HUD and the animated Game Over screen.
- `res://scripts/enemy/enemy.gd`: Advanced AI controller handling exploration, combat movement, and logic aborts if combat ends mid-action.
- `res://scripts/player/player.gd`: Handles player states, inputs, and death-specific visual/physics transitions.

---

## 📝 Current Development State

### Implemented Improvements
- **Game Over Refinement**: High-polish UI with back-easing scale animations and pulsing prompts.
- **Camera Decoupling**: Fixed the issue where the camera would spin 90 degrees into the floor when the player died.
- **AI Robustness**: Added checks after every `await` in enemy combat coroutines to ensure they don't continue attacking or dealing damage after combat has ended.
- **Visual Darkening**: Implemented a universal material override that darkens any mesh (regardless of original material type) upon death.

### Suggested Next Steps
1. **Special Abilities**: Expand the combat menu to support skills, magical attacks, or bracing for defense.
2. **Level Transitions**: Implement a system to move between different dungeon floors/rooms.
3. **Experience & Leveling**: Implement an XP system awarded upon victory.
4. **Audio Integration**: Add impact sounds, death groans, and dramatic game over music.

---

*Last Updated: December 23, 2025*
