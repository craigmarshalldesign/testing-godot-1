# SonderQuest Enemies Framework (v1)

This document defines the structural rules for creating, defining, and instancing enemies in v1. It serves as the implementation contract for the enemy system, strictly adhering to the `SonderQuest-Implementation-Architecture-Plan.md`.

---

## 1. Enemy Design Goals (v1)

The v1 enemy framework is designed to validate the core combat loop and data-driven architecture.

*   **Goals:**
    *   Test the full flow of the **Combat Loop** (Initiative -> Movement -> Action -> End Turn).
    *   Validate the **Ability Execution** pipeline for non-player units.
    *   Ensure **AI Readability** via clear visual feedback of intent and action.
    *   Prove the **Data Validation** rules prevent broken states (e.g., missing weapons, invalid targeting).
    *   Allow **Encounter Tuning** via overrides without duplicating assets.

*   **Non-Goals (v1):**
    *   No complex Boss Scripting systems or phases.
    *   No dynamic Faction or Diplomacy systems.
    *   No advanced AI Planners (GOAP/HTN); use Weighted Reactive AI.
    *   No procedural generation of units.
    *   No "Loot Table" framework (drops are currently out of scope).
    *   No Armor equipment requirements for v1 (stats are handled via layers).

---

## 2. Enemy Data Model

Enemies are defined using the existing Resource-based framework. We avoid hard-coding scripts per unit; instead, we compose units from data.

### A. Core Definitions
*   **Enemy Archetype definition:** The blueprint for a specific unit type (`res://data/units/...`).
    *   **Stable ID:** A unique String ID matching the folder path.
    *   **Layer Stack:** An ordered list of Stat Layer definitions (Species -> Subspecies -> Variant).
    *   **Base Level:** The default level for this unit if no override is provided.
    *   **Default Weapon:** Optional reference to a Weapon definition resource. If missing, falls back to "Unarmed".
    *   **Ability Kit:** A list of specific Ability definitions this unit knows.
    *   **AI Profile:** Reference to an AI Profile definition (behavior weights).

*   **Stat Layer definition:** A composable block of stats (`res://data/layers/...`).
    *   **Add Attributes:** Base STR, DEX, INT, etc. that this layer contributes.
    *   **Add Baseline Stats:** Flat HP, Mana, Stamina bonuses.
    *   **Add Resistances:** Elemental or physical resistances/weaknesses. Weakness is represented by negative type resistance values.
    *   **Movement Tags:** Capabilities like `Fly`, `Swim`, `Walk`.
    *   **Innate Traits:** Passive abilities or racial skills granted automatically.

*   **Encounter Override definition:** Scene-specific adjustments (`res://data/overrides/...` or embedded).
    *   **Level Override:** Forces the unit to a specific level.
    *   **Bonus Stats:** Additive modifiers to attributes or stats (e.g., +50 HP for a "Tough" variant).
    *   **Add Abilities:** Grants extra moves (e.g., a generic "Boss Stomp").
    *   **Remove Abilities:** Removes specific interaction options by ID.

### B. Structural Rules
*   **Order Matters:** Layers are summed sequentially. A "Variant" layer acts as a specialized modifier on top of a generic "Species" layer.
*   **Scaling:** Final stats resolve from the sum of all Layers plus level scaling rules defined in the leveling/scaling document.
*   **References:**
    *   **Editor:** Uses direct Resource file references for safety and drag-and-drop.
    *   **Runtime/Save:** Converts all references to stable **String IDs** (snake_case paths) to ensure save file compatibility and easy debugging.

---

## 3. Species and Variant Layer Philosophy

To maximize reuse, we define units from general to specific hierarchical layers.

1.  **Species Layer:** Broad biological category. Defines baseline size, fundamental attributes, and movement type.
2.  **Subspecies/Type Layer:** Specific creature definition. Defines distinct visual identity and specialized stats.
3.  **Variant/Class Layer:** Rank or Role. Defines the "job" (Warrior vs Shaman) or rank (Minion vs Elite).

### Concrete Layer Stack Examples

*   **Cave Bat** (Basic wildlife)
    *   `layers/species/beast`
    *   `layers/species/beast/bat`
    *   `layers/species/beast/bat/cave`

*   **Vampire Bat** (Elite threat)
    *   `layers/species/beast`
    *   `layers/species/beast/bat`
    *   `layers/species/beast/bat/vampire`

*   **Goblin Scout** (Light infantry)
    *   `layers/species/humanoid`
    *   `layers/species/humanoid/goblin`
    *   `layers/species/humanoid/goblin/scout`

---

## 4. Enemy Ability Kits

Enemies use the exact same Ability definitions as players.

*   **Kit Size:** Typically 2 to 4 abilities per enemy to ensure predictable behavior.
*   **Default Attack:**
    *   Every enemy **must** have a way to deal damage.
    *   This is handled by the **Basic Attack** action, which uses the equipped Weapon or the default **Unarmed Weapon** asset.
    *   We do not hardcode "Punch" logic; "Unarmed" is simply a Weapon definition (e.g., `weapons/natural/unarmed`).

*   **Damage Types:**
    *   **Weapon-Based:** Use for physical strikes (Bite, Claw, Sword Slash). Scales with Unit Attributes + Weapon Stats.
    *   **Numeric (Spell-like):** Use for magical attacks or special moves (Fireball, Sonic Screech). Scales via level rules + Unit Attributes.

*   **Utility & Control Rules:**
    *   **Constraint (v1):** For v1 enemies, do not include Utility abilities in enemy kits yet. Enemy kits should be Action-only. This is a temporary content constraint, not a system restriction.
    *   Control effects (Stun, Root) should be used sparingly to avoid frustrating lock-loops.

*   **Status Duration Logic:**
    *   Enemy-applied statuses use the exact same logic as players: **Min/Max Turns** based on strength vs resistance, subject to per-turn **Break Checks**. No artificial "Boss Immunity" mechanics in v1.

---

## 5. Enemy AI Rules (v1)

The v1 AI is **Weighted Reactive**, designed to be simple, testable, and readable. It does not use complex planning.

### A. Turn Structure
*   Enemies use the same **Movement Phase** then **Action Phase** structure as player units.

### B. Decision Process
1.  **Filter:** Identify all abilities in the kit that are currently **Valid**.
    *   Resources available.
    *   Cooldown ready.
    *   Target exists and in range.
    *   **Physics Validation:** AI uses the same target preview validation rules as players (Range, Line of Sight, valid destination for teleport behind target, etc).
    *   Reject abilities that are not legal for the current phase.
2.  **Score:** Check valid abilities against the **AI Profile**.
    *   **Inputs:** AI primarily reads **Ability Tags** and **AI Hints** defined on the Ability resource itself.
    *   Apply Bias Weights (e.g., "Aggressive" profile favors Damage tags).
    *   Apply Conditional Hints (e.g., "Use Heal if Health < 30%").
3.  **Select:** Choose an action via **Weighted Random** selection from the top scoring options.

### C. Fallback Behavior
If no specific Ability is valid:
1.  **Basic Attack:** Check if a Basic Attack is valid (in range).
2.  **Move:** If no action is possible, the unit enters the **Movement Phase** logic to find a **reachable position within movement radius** that enables a future action.
    *   *Retreat:* If the profile dictates passivity or health is low, move to a reachable position that maximizes distance or breaks **line of sight** if possible.

### D. Facing and Positioning
*   Enemies are affected by facing and back arcs the same as players.
*   If an enemy has any back-arc relevant bonuses or effects, AI may prefer to reposition into a target’s back arc during Movement Phase when feasible.

---

## 6. Enemy Equipment Rules

*   **Weapons:**
    *   Enemies use `Weapon` definition resources just like players.
    *   **Default Weapon:** Optional field in the Archetype.
    *   **Unarmed Fallback:** If no weapon is defined, the validation system **must** inject the standard `weapons/natural/unarmed` asset. This ensures Basic Attack always functions.
*   **Armor:**
    *   There is no armor item slot for enemies in v1.
    *   Defensive stats (Phys Def, Magic Def) come entirely from **Stat Layers** and Attributes (VIT/WIL).

---

## 7. Starter Enemy Roster (Small)

A concise list of v1 validation enemies using stable IDs.

**1. Cave Bat**
*   **Layer Stack:**
    *   `layers/species/beast`
    *   `layers/species/beast/bat`
    *   `layers/species/beast/bat/cave`
*   **Default Level:** 3
*   **Weapon:** `weapons/natural/fangs`
*   **Ability Kit:** `abilities/action/melee/bite`
*   **AI Profile:** `ai/behaviors/simple_aggressive`
*   **Role:** Weak flyer, harasses backline.

**2. Vampire Bat**
*   **Layer Stack:**
    *   `layers/species/beast`
    *   `layers/species/beast/bat`
    *   `layers/species/beast/bat/vampire`
*   **Default Level:** 5
*   **Weapon:** `weapons/natural/fangs_sharp`
*   **Ability Kit:** `abilities/action/melee/bite`, `abilities/action/magic/life_leech`
*   **AI Profile:** `ai/behaviors/flanker`
*   **Role:** Durable drain-tank, prioritizes healers.

**3. Goblin Scout**
*   **Layer Stack:**
    *   `layers/species/humanoid`
    *   `layers/species/humanoid/goblin`
    *   `layers/species/humanoid/goblin/scout`
*   **Default Level:** 2
*   **Weapon:** `weapons/daggers/rusty_shiv`
*   **Ability Kit:** `abilities/action/melee/dirty_stab`
*   **AI Profile:** `ai/behaviors/hit_and_run`
*   **Role:** High evasion striking.

**4. Goblin Shaman**
*   **Layer Stack:**
    *   `layers/species/humanoid`
    *   `layers/species/humanoid/goblin`
    *   `layers/species/humanoid/goblin/shaman`
*   **Default Level:** 4
*   **Weapon:** `weapons/staves/gnarled_staff`
*   **Ability Kit:** `abilities/action/magic/firebolt`, `abilities/action/magic/minor_heal`, `abilities/action/zone/fire_patch`
*   **AI Profile:** `ai/behaviors/caster_support`
*   **Role:** Ranged damage, healer support, zone control.

**5. Skeleton Warrior**
*   **Layer Stack:**
    *   `layers/species/undead`
    *   `layers/species/undead/skeleton`
    *   `layers/species/undead/skeleton/warrior`
*   **Default Level:** 4
*   **Weapon:** `weapons/swords/ancient_blade`
*   **Ability Kit:** `abilities/action/melee/heavy_swing`
*   **AI Profile:** `ai/behaviors/tank`
*   **Role:** Durable frontliner, high physical defense.

---

## 8. Encounter Tuning via Overrides

Override definitions allow Level Designers to tune encounters without changing the base assets.

*   **Allowed Modifications:**
    *   **Level Override:** Explicitly set unit to Level 10 for a hard encounter.
    *   **Additive Stats:** `+50 HP` or `+2 STR` to create unique "named" variants.
    *   **Add Abilities:** Give a specific goblin a "Bomb Throw" ability for one scene.
    *   **Remove Abilities:** Remove "Heal" from a Shaman to make an easier tutorial fight.
    *   **Clarification:** Overrides may modify any exposed stat key or resistance key that exists in the stat system’s maps, provided the mechanism supports additive values.

*   **Forbidden Modifications (v1):**
    *   **Changing Layer Stack:** Do not swap Species at runtime.
    *   **Movement Tags:** Movement capabilities must remain constant per layer definition.
    *   **Scripting:** Do not add per-instance bespoke scripts.

*   **Creating Elites:** To make an "Elite" enemy, simply apply an Override:
    *   Level +2.
    *   Add `abilities/action/buff/rage` to ability kit.
    *   Add `+MaxHP` (Additive).

---

## 9. Validation Rules

The build pipeline and editor tools must enforce these rules for Enemies.

### Must Error (Hard Fail)
*   **Missing ID:** Any enemy definition without a snake_case String ID.
*   **Empty Layer Stack:** A unit with 0 layers defined.
*   **Missing AI Profile:** No behavior definition linked.
*   **Invalid Abilities:** Referencing Ability IDs that do not exist.
*   **Forbidden Override:** An Override attempting to modify the Layer Stack.

### May Warn (Soft Fail)
*   **No Default Weapon:** Warning logged. System **must** inject `weapons/natural/unarmed` automatically.
*   **Empty Ability Kit:** Warning logged. Unit will only be able to use Basic Attack.
*   **Utility Present:** Warning logged. V1 enemies should only have Action abilities.
*   **Missing Presentation:** Missing icons or description text (acceptable for prototype/grey-box).
