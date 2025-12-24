# New Game Project: 3D Tactical Party RPG

**Version:** 0.6 (Refactor Complete)
**Engine:** Godot 4.5+
**Architecture:** Scene-Modular (Local Scripts)

---

## 📖 Project Overview
This is a high-fidelity 3D Action-RPG prototype. It allows players to explore a world with a full party of characters and transition seamlessly into turn-based combat without loading screens.

**Key Technical Pillars:**
1.  **Scene-Locality**: Assets and scripts for an entity (e.g., `CharacterA`) live together in the same folder. No global `scripts/` folder bloat.
2.  **Inspector-Driven Design**: Designers can tweak combat stats (`HP`, `Speed`, `Range`) directly in the Inspector, even for complex inheritance chains.
3.  **Hybrid Input**: Exploration is real-time (WASD), while combat is turn-based (Mouse/Keyboard selection).

---

## 📂 File Structure & Architecture

We have migrated away from generic `scripts/` folders. The project is now organized by **Feature** and **Entity**.

### `res://scenes/`
This is the root of all gameplay content.

#### 1. `enteties/` (The Core)
Contains all playable characters and enemies.
*   **`player/`**
    *   `party_manager.gd`: The "Brain". Handles inputs to switch characters (`LB/RB`) and positions the party in a ring during combat.
    *   `player_base.tscn`: The architectural ancestor of all heroes.
    *   **`scripts-player_base/`**:
        *   `player_movement.gd`: Inherits `CharacterBody3D`. Handles Gravity, Jump (`Space`), and Movement (`WASD`).
        *   `player_combat.gd`: Handles Turn Logic, Stats, and Attack Sequences.
    *   **`characters/`**:
        *   `character-a/character_a.tscn`: The "Warrior" subclass.
        *   `character-b/character_b.tscn`: The "Mage" subclass.
        *   *(Each has its own script overriding `_configure_stats`)*

*   **`enemies/`**
    *   `enemy_base.gd`: Facade class. Disables Editor logic to prevent crashes.
    *   **`scripts-enemy_base/`**:
        *   `enemy_movement.gd`: Uses `NavigationAgent3D` for pathfinding. Includes "Stuck Detection" (auto-jump if blocked).
        *   `enemy_combat.gd`: Handles "Slot Detection" (finding a spot around the player) and executing Attacks.
    *   **`normal/`**:
        *   `SkeletonWarrior/`: Standard melee enemy.
    *   **`boss/`**:
        *   `Boss1/`: Larger scale, higher stats.

#### 2. `combat/`
*   `combat_manager.gd`: Singleton (Autoload). Tracks whose turn it is, sorts everyone by `Speed`, and detects Game Over.
*   `combat_ui.gd`: Floating numbers, Turn indicators, and Health bars.
*   `targeting_system.gd`: Math utility to find the "Best" target (closest visible enemy).

#### 3. `camera/`
*   `party_camera.gd`: A detached camera that lerps smoothly between party members when you switch control.

---

## ⚙️ Game Systems Detail

### ⚔️ The Combat Loop
Combat is **Turn-Based** but happens in **Real-Space**.
1.  **Trigger**: `enemy_combat.gd` checks `distance_to(player) < detection_range`.
2.  **Start**: `CombatManager` pauses exploration. The Camera focuses on the fight.
3.  **Turns**:
    *   **Priority System**: `CombatManager` sorts the `combatants` array by `stats.speed` (Descending).
    *   **Visuals**:
        *   **Orange Ring**: Movement limit (You can run freely inside this ring).
        *   **Red Ring**: Attack range (You must be this close to click "Attack").
4.  **Resolution**:
    *   **Victory**: Enemies ragdoll/crumple. Party returns to formation.
    *   **Defeat**: If all party members drop to 0 HP, the "GAME OVER" screen appears.

### 👥 The Party System
*   **Formation**: In exploration, followers snake behind the leader. In combat, they span out into a calculated circle `(radius = 2m + 0.5m * member_count)` to avoid friendly fire.
*   **Switching**: You can swap leaders instantly. The old leader stops moving, and the new leader accepts input immediately.
*   **State Management**: `PartyManager` ensures only the *active* character executes physics inputs to prevent "ghost walking".

### 📊 Stat System (The "Zero Bug" Fix)
We use a specific pattern to ensure stats work in the Editor:
*   **Base Class**: `player_combat.gd` defines variables (`max_health`, `attack`) but leaves them empty.
*   **Child Class**: `character_a.gd` overrides `_configure_stats()` to set `max_health = 120`.
*   **Editor Logic**: Because we use `@tool`, `_ready()` calls `_configure_stats()` even in the editor, ensuring the Inspector always shows true values.

---

## 📊 Mechanics Deep Dive

### 1. Stats & Calculations
All entities (Players & Enemies) share the same `CombatStats` structure.

| Stat | Variable | Effect |
| :--- | :--- | :--- |
| **HP** | `base_health` | Current Health. Death occurs at `<= 0`. |
| **Attack** | `base_attack` | Base damage dealt. Formula: `Damage = Attacker.Atk - Defender.Def`. (Min 1 dmg). |
| **Defense** | `base_defense` | Direct damage reduction. |
| **Speed** | `base_speed` | Determines **Turn Order** (Highest acts first) and **Movement Radius** (`Speed * 0.5` meters). |

### 2. Targeting & Hitboxes
Combat uses a "Physical Size" system to make targeting intuitive, especially against large bosses.

*   **Hit Radius (`hit_radius`)**: Every unit has a physical size (Player: 0.5m, Boss: 1.5m).
*   **Attack Range (`attack_range`)**: How far your weapon reaches (e.g., 2.0m for Swords).
*   **The Formula**:
    > You can hit if: `Distance(You, Target) - Target.HitRadius <= Your.AttackRange`
    
    *Example*: To hit a **Boss** (Radius 1.5m) with a **Sword** (Range 2.0m), you only need to be within **3.5m** of its center.

### 3. Controller-Friendly Targeting (New!)
The game now features a polished hybrid targeting system:
*   **Walk-to-Target**: Simply walking towards an enemy (in a 60° cone) will automatically "soft-lock" onto them if they are within 12m.
*   **D-Pad Cycling**: Use D-Pad Left/Right to cycle through available targets, sorted visually from left to right on screen.
*   **Auto-Assist**: If you press Attack with no target, the game will instantly pick the closest valid enemy.
*   **Range Break**: Moving > 12m away automatically clears your target to keep the UI clean.

### 4. Player Death & Revival
*   **Death**: When HP hits 0, the character:
    1.  Plays a falling animation and physics disable (Collision OFF).
    2.  Visuals darken to indicate "Out of Commission".
    3.  A 30-second timer starts. If not revived or combat doesn't end, the body despawns.
*   **Revival**: 
    *   Currently, **Victory** automatically revives all fallen party members.
    *   Revived characters regain full HP, restore their original visuals, and stand back up.

### 5. Combat Resolution
*   **Victory**: Triggered when all Enemies are defeated.
    *   Combat ends.
    *   **All Party Members** (even dead ones) are **Revived and Fully Healed**.
    *   The party returns to Exploration Mode.
*   **Game Over**: Triggered when **All Party Members** are defeated (0 HP).
    *   A "Game Over" signal is emitted (currently prints to console).

### 6. Movement
*   **Exploration**: Standard `CharacterBody3D` physics with gravity and slide.
*   **Combat**:
    *   **Movement Ring**: Visualized as an Orange Circle.
    *   **Calculation**: `Radius = Speed * 0.5`. 
    *   *Example*: Speed 10 = 5 meters of movement per turn.

---

## � Developer Workflows

### How to Add a New Hero
1.  **Duplicate** `scenes/enteties/player/characters/character-a`.
2.  **Rename** folder and file to `character-c`.
3.  **Edit Script**:
    ```gdscript
    @tool
    extends "res://scenes/enteties/player/scripts-player_base/player_combat.gd"
    
    func _configure_stats() -> void:
        max_health = 150
        attack = 45
        defense = 12
        speed = 11 # Higher speed = acted sooner
    ```
4.  **Drag & Drop** the scene into the `PartyManager` node in your level.

### How to Add a New Enemy
1.  Inherit from `enemy_base.tscn`.
2.  Assign your Mesh to the `Skeleton3D/Mesh` slot.
3.  Create a script extending `EnemyBase` and override:
    *   `_get_attack_animation()`: Name of animation in your AnimationTree.
    *   `_configure_stats()`: Set HP/Damage.
4.  Place in the world. It will automatically detect players.

---

## 🗺️ Roadmap & Future Plans

### Phase 1: Polish (Current)
*   **Audio**: Add footstep sounds and swing SFX.
*   **VFX**: Add hit sparks and death particles.
*   **UI**: specific icons for each character class.

### Phase 2: Content Expansion
*   **Inventory System**: Equipment slots (Weapon, Armor) that modify stats.
*   **Skill Trees**: Unlockable abilities (e.g., "Whirlwind" for Warrior).
*   **Level Design**: Multi-room dungeons with doors and keys.

### Phase 3: Save/Load System
*   Serialize the `PartyManager` state and `CombatStats` to a save file.

---

*Project Cleaned & Verified - Dec 24, 2025*
