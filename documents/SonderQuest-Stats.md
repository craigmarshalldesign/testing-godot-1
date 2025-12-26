# SonderQuest Stats & Attributes (v1 Skeleton)

This document serves as the primary technical reference for the v1 stat system.

## High-Level Design
*   **Attributes** describe the character and drive combat math.
*   **Offense Scaling** is defined per weapon/ability, not by global stat buckets.
*   **Exploration interactions** are primarily handled by *abilities* (binary unlocks), not stats.
*   **Exploration skills** only exist if the world asks for a specific roll-based check.

---

## 1. Core Attributes

| Attribute | Combat Responsibility | Exploration Responsibility |
| :--- | :--- | :--- |
| **Strength (STR)** | Scaling source for Weapons/Abilities. Contributes to **Physical Defense**. | Contributes to **Might**. |
| **Dexterity (DEX)** | Scaling source for Weapons/Abilities. Increases **Accuracy**, **Evasion**, **Move Radius**, **Crit Chance**. | Contributes to **Lockpicking**. |
| **Intelligence (INT)** | Scaling source for Spells/Abilities. Increases **Max Mana**. | Contributes to **Analysis**. |
| **Willpower (WIL)** | Scaling source for Spells/Abilities. Increases **Magic Defense**, **Mana Regen**, **Status Resist**. | **None** (Intentional for v1). |
| **Vitality (VIT)** | Increases **Max HP**, **Stamina Regen**, and **Physical Defense**. | **None** (Intentional for v1). |
| **Charisma (CHA)** | Increases **Ultimate Charge Rate**. Scaling source for Presence abilities. | Contributes to **Fortune**. |

### Fortune (Party Rule)
Fortune is not an individual stat check; it applies to the **active party** layout.
*   **Formula:** `FortuneScore = Highest_Party_CHA + floor(Sum_Other_Members_CHA * 0.25)`
*   **Effect:** Additive bonus to rare drop chances or "upgrade" rolls on loot.
*   **Scope:** Evaluated once per loot event using the current active party and does not stack per character or per kill beyond the defined formula.
*   **Constraint:** Capped to prevent economy breaking.

---

## 2. Scaling Profiles (Weapons & Abilities)

Instead of a single "Melee Power" or "Ranged Power", every offensive action defines its own scaling profile.

### Damage Definition Rule
Weapons and damaging abilities define a **base damage range** (e.g., 7–10) which scales with **Character Level**.
*   **Growth Logic:** `CurrentBase = InitialBase + (Level * GrowthCoefficient)`.
*   *Purpose:* Ensures abilities remain viable from Level 1 to 40 even before Attribute scaling.
When an attack is executed, a value is rolled from this *Level-Scaled* range and **then** modified by attribute scaling, talents, and effects.
This rule applies uniformly to player characters, enemies, and summoned units.

### A. Weapon Scaling Profiles
Weapons define a primary attribute and an optional secondary attribute.
*   **Greatsword:** `STR (Primary) + DEX (Secondary)`
*   **Dagger:** `DEX (Primary) + STR (Secondary)`
*   **Spear:** `STR (0.7) + DEX (0.7)` (Hybrid)
*   **Bow:** `DEX (Primary) + STR (Minor)`
*   **Staff:** `INT (Primary) + WIL (Secondary)`

### B. Ability Scaling Blocks
Abilities have two independent scaling components.

**1. Damage/Healing Scaling**
Determines the raw output numbers.
*   *Mage Fireball:* `INT (Primary)`
*   *Warrior Cleave:* `STR (Primary) + DEX (Secondary)`
*   *Druid Heal:* `WIL (Primary) + INT (Secondary)`

**2. Effect Scaling**
Determines potency of non-damage effects (Fear duration, Stun chance, Debuff magnitude). This allows "Non-Magic" stats to scale utility.
*   *Warrior Fear Shout:* `CHA (Primary) + WIL (Secondary)` (Scales fear intensity).
*   *Rogue Blind:* `DEX (Primary) + INT (Secondary)` (Scales blind duration).
*   *Druid Roots:* `WIL (Primary)` (Scales root health/duration).

---

## 3. Derived Combat Substats

> **Crucial Note:** Derived values below originate from attributes but are not locked to them. All resources and regen values are first-class stats that can be modified directly by gear, talents, buffs, and zones.

### Resources & Regen
All characters share the same resource pools. Regeneration occurs at the **End of Turn**.
*   **Max HP** (from VIT): Health pool.
*   **Max Mana** (from INT): Resource for spells.
    *   **Mana Regen:** Derived primarily from **WIL**. Can be modified independently.
*   **Max Stamina** (from Physical Stats): Resource for physical abilities.
    *   **Stamina Regen:** Derived primarily from **VIT**. Can be modified independently.

### Defense & Mitigation
*   **Physical Defense** (VIT Primary, STR Secondary): Mitigation for physical damage categories.
*   **Magic Defense** (WIL): Mitigation for magical damage categories.

### Hit & Avoidance
*   **Accuracy** (from DEX): Hit chance modifier.
*   **Evasion** (from DEX): Avoidance chance modifier.

### Critical
*   **Crit Chance** (DEX Primary): Chance to deal bonus damage.
*   **Crit Damage** (Base + Talents/Gear): Multiplier on successful crits.

### Turn & Movement
*   **Initiative** (from DEX, Gear, Talents): Determines turn order. Higher acts earlier. Modifiable by effects (e.g., Haste, Slow).
*   **Move Radius** (from DEX): The size of the allowable movement ring in combat.

### Ultimate
*   **Ultimate Charge Rate** (from CHA): Speed at which the ultimate bar fills per turn/action.

---

## 4. Status Effects & Duration Model (Turn-Based)

All durations are measures in **Turns**. Effects use a "Strength vs. Resistance" model instead of fixed timers.

### Core Concepts
1.  **Status Strength:** The potency of the effect application (derived from Source Ability's Effect Scaling).
2.  **Status Resistance:** The target's ability to resist or shake off the effect (derived primarily from WIL).

### Application Logic
1.  **Hit & Apply:** Formula compares `Status Strength` vs `Status Resistance`. If failed, status is not applied.
2.  **Initial Duration:** Formula clamps duration between a **Minimum** (e.g., 1 Turn) and **Maximum** (e.g., 3 Turns) based on how much the Strength exceeded the Resistance.

### Break Checks (Per Turn)
At the start of each affected turn, the target rolls a **Break Check**.
*   **Formula:** Compare remaining `Status Strength` vs `Status Resistance`.
*   **Success:** Status ends early.
*   **Fail:** Status continues, duration ticks down by 1.

*Example:* A weak 'Burn' might be extinguished by a high-WIL character after 1 turn, while a robust 'Root' might persist for the full maximum duration against a low-WIL target.

---

## 5. Damage and Resistance Taxonomy

Damage calculation follows a layered "Category -> Type" system.

### Taxonomy
*   **Damage Category** (Broad defense layers)
    *   **Physical**
    *   **Magical**
    *   **True** (Ignores mitigation)
*   **Damage Type** (Specific resistance modifiers)
    *   *Physical Types:* Melee, Ranged, Crush, Bleed.
    *   *Magical Types:* Fire, Ice, Shock, Poison, Arcane, Nature.

### Weakness & Resistance Logic
*   **Percentage Modifiers:** Type Resistances can be positive (Resistance) or negative (Weakness).
*   **Weakness:** A negative value increases damage taken. *Example: A Fire Resist of -25% indicates a weakness and causes the target to take 25% more Fire damage.*
*   **Clamping:** Resistance values are clamped to a sensible range to prevent absorb/infinite damage scenarios.
*   **True Damage:** Ignores both Category Defense and Type Resistance entirely.

### Calculation Order (Conceptual)
1.  **Hit Check:** (Accuracy vs Evasion)
2.  **Crit Check:** (Crit Chance)
3.  **Category Defense:** (`Physical Defense` or `Magic Defense` reduces raw damage)
4.  **Type Resistance:** (Specific resistance % reduces remaining damage)
5.  **Status/Buffs:** (Final multipliers)

---

## 6. Exploration: Skills vs. Abilities

In v1, we distinguish strictly between **Checks** (Stats) and **Capabilities** (Abilities).

### A. Exploration Skills (Roll/Check Based)
These exist *only* for specific environmental interactions that require a success/fail roll. If the world doesn't ask for it, the skill doesn't exist.

1.  **Might (STR):** Pushing/pulling heavy objects, forcing stuck mechanisms, breaking weakened barriers.
2.  **Lockpicking (DEX):** Opening locked chests and doors.
3.  **Analysis (INT):** Deciphering puzzles, runes, and ancient devices.

### B. Exploration Abilities (Binary Capabilities)
Traversal and unique interactions are driven by **Abilities**, not Stats. These are binary (you have it or you don't) or tiered by talent level.

*   *Examples:*
    *   **Bird Form:** Fly forward X meters (Not driven by STR/DEX).
    *   **Blink:** Teleport X meters.
    *   **Shadow Step:** Passthrough bars/grates.
    *   **Smash Wall:** Break specific tagged walls.

*Note: Attributes do NOT modify the distance or effectiveness of these abilities unless explicitly defined in the ability's description.*
