# SonderQuest Classes Framework (v1)

This document defines the structural rules for creating, defining, and instancing player classes in v1. It serve as the implementation contract for the class system, strictly adhering to the `SonderQuest-Implementation-Architecture-Plan.md`.

---

## 1. Purpose and Design Goals (v1)

The Class Framework defines how player roles are constructed using the unified Stat Layer system.

*   **Goals:**
    *   Establish a validatable contract for Player Roles within the **Stat Resolution Pipeline**.
    *   Ensure all class data (Abilities, Stats, Equipment) is fully **Data-Driven**.
    *   Provide a stable structure for **Save/Load** operations regarding character identity.
    *   Support the **Layered Unit Composition** (Species -> Variant -> Class) defined in the architecture plan.
    *   Define the rigid **Equipment Slot** and **Armor Category** model for v1.
    *   Provide clear **Specialization Themes** to guide ability design and future expansion without locking mechanics prematurely.

*   **Non-Goals (v1):**
    *   No **Multiclassing**. Characters have exactly one class layer at a time.
    *   No complex **Prestige Classes** or dynamic job switching in combat.
    *   No hardcoded logical differences between classes (e.g., "Mages regenerate faster" is a Stat config, not a code rule).
    *   No **Off-Hand Weapons**. The v1 slot model supports only Main Weapon + Shield.
    *   **Enemy Exclusion:** Enemy units do not use Class specialization themes; enemy differentiation is handled via layers and ability kits.

---

## 2. Equipment & Armor Model (v1 Locked)

This model is strict. Classes cannot redefine slots or categories.

### A. Equipment Slots
Characters have exactly **5** slots.

1.  **Main Weapon:** Accepts any `WeaponFamily`.
2.  **Shield:**
    *   Accepts `Shield` items (Shields are NOT weapons).
    *   **Constraint:** Only usable if a **One-Handed** weapon is equipped in Main Weapon.
3.  **Head:** Accepts Armor (Light/Medium/Heavy).
4.  **Torso:** Accepts Armor (Light/Medium/Heavy).
5.  **Legs:** Accepts Armor (Light/Medium/Heavy).

### B. Armor Categories & Intent
Armor items belong to exactly one category. Classes select allowed categories based on their role intent.
*   **Light Armor:** Maximizes Mobility and Initiative. Best for Rogues/Mages.
*   **Medium Armor:** Balances defense with minor penalties. Best for Heroes/Druids.
*   **Heavy Armor:** Maximizes Mitigation at the cost of Initiative/Mobility. Best for Warriors.
*   *Note:* Penalties (speed, initiative) are handled via Stats and Effects on the armor items, not hardcoded class rules.

---

## 3. Supported Classes & Specializations (v1)

This section defines the 5 supported classes and their 3 Specialization themes.
*   **Specs are descriptive only** in v1. They do not grant abilities or mechanics automatically.
*   **Talent Tree Naming Rule:** Trees use role/archetype titles, not abstract nouns. They represent what the character is (e.g., "Berserker", not "Rage").

### 1. Hero
The adaptable protagonist archetype.
*   **Armor Proficiency:** Heavy,Medium, Light.
*   **Blademaster:** Master of weapons and direct combat.
    *   *Themes:* Precision, stamina-driven offense, multi-hit.
    *   *Example:* **Cleave** (Wide swing hitting multiple enemies).
*   **Lightbearer:** Hero touched by divine forces.
    *   *Themes:* Protection, radiant damage, defensive buffs.
    *   *Example:* **Radiant Guard** (Damage reduction + minor heal).
*   **Dreadbound:** Hero drawing power from forbidden forces.
    *   *Themes:* Risk vs reward, dark magic, self-sacrifice.
    *   *Example:* **Shadow Rend** (Bonus damage at health cost).

### 2. Warrior
The durable frontliner.
*   **Armor Proficiency:** Heavy, Medium, Light.
*   **Berserker:** Blood-fueled destroyer trading safety for power.
    *   *Themes:* Self-damage, burst melee, stamina-heavy.
    *   *Example:* **Rage Strike** (Double hit, self-damage).
*   **Warden:** Armored enforcer controlling space.
    *   *Themes:* Damage reduction, knockdowns, grounding.
    *   *Example:* **Ground Stomp** (AoE damage + Grounded status).
*   **Commander:** Battlefield leader shaping the fight.
    *   *Themes:* Shouts, taunts, buffs/debuffs (CHA-driven).
    *   *Example:* **Taunting Shout** (Forces enemy focus).

### 3. Mage
The arcane glass cannon.
*   **Armor Proficiency:** Light only.
*   **Pyromancer:** Destructive fire mage thriving on chaos.
    *   *Themes:* Fire damage, burn stacking, crit synergy.
    *   *Example:* **Firebolt** (Damage + Burn tick).
*   **Cryomancer:** Cold sorcerer denying movement.
    *   *Themes:* Ice/Water, slows, freezes.
    *   *Example:* **Drench** (Water damage + Wet/Slow).
*   **Conjuror:** Arcane shaper of defenses.
    *   *Themes:* Magical shields, constructs, enchantments.
    *   *Example:* **Magic Shield** (Absorb barrier on ally).

### 4. Thief
The tactical infiltrator and striker.
*   **Armor Proficiency:** Medium, Light.
*   **Assassin:** Lethal close-range killer.
    *   *Themes:* Backstabs, burst damage, positioning.
    *   *Example:* **Backstab** (Teleport rear + bonus damage).
*   **Stalker:** Mobile skirmisher mastering thrown weapons.
    *   *Themes:* Thrown daggers, evasion, mid-range kiting.
    *   *Example:* **Shadow Throw** (Thrown dagger + Blind).
*   **Corruptor:** Poisoner and debuffer using dark alchemy.
    *   *Themes:* Poison, attrition, shadow magic.
    *   *Example:* **Toxic Blade** (Melee + Poison DoT).

### 5. Druid
The nature-based controller and shapeshifter.
*   **Armor Proficiency:** Medium, Light.
*   **Beastkin:** Primal shapeshifter and predator.
    *   *Themes:* Form-swapping, high mobility, melee.
    *   *Example:* **Wolfkin Form** (Leap + transform).
*   **Stormcaller:** Commander of terrifying nature forces.
    *   *Themes:* Storms, roots, long-range control.
    *   *Example:* **Entangling Roots** (AoE Root check).
*   **Lifewarden:** Druidic healer and protector.
    *   *Themes:* HoTs, sustain, defensive nature magic.
    *   *Example:* **Healing Wind** (Heal + HoT).

---

## 4. Class Definition Contract (Usage)

A "Class" in SonderQuest is primarily a **Stat Layer definition** wrapped with progression and proficiency metadata.

*   **Runtime Application:**
    *   When a player selects a class, the system fetches the corresponding Class definition resource via its **Stable ID**.
    *   The definition's internal Stat Layer is applied to the character's resolved stats.
    *   The character's available abilities are populated from the Class's ability list.

### A. Data Structure
A Class definition resource aggregates the following data. All references to other content must use **Stable String IDs**.

#### 1. Identity
*   **Stable ID:** Snake_case identifier matching the folder structure (e.g., `layers/classes/mage`).
*   **Display Name:** Visible name in UI.
*   **Description:** Flavor text.
*   **Icon:** UI sprite reference.

#### 2. Stat Layer Definition
The definition contains an embedded or referenced **Stat Layer definition** that provides:
*   **Attribute Growth:** The primary source of STR, DEX, INT, etc.
*   **Baseline Stats:** Base HP, Mana, and Stamina values. *These are additive overlays applied to the unit’s baseline stats and are not absolute replacements.*
*   **Resistances:** Base Physical/Magic defense and specific type resistances.
*   **Movement Tags:** Rarely used for classes (usually Species), but supported.

#### 3. Equipment & Proficiency
*   **Allowed Weapon Families:** A list of `WeaponFamily` IDs (e.g., `swords`, `staves`).
*   **Allowed Armor Categories:** A list of allowed categories (e.g., `[Light, Medium]`).
*   **Starting Equipment:**
    *   **Main Weapon:** Reference to a Weapon definition resource ID.
    *   **Shield:** Optional reference to a Shield item.
    *   **Armor (Head/Torso/Legs):** Optional references to Armor items.

#### 4. Ability Kit (Starting Loadout)
*   **Starting Abilities:** A list of **Ability IDs** granted at Level 1.
*   **Reference Rule:** These IDs must correspond to valid entries in the global Ability registry. Definitions for these abilities are authored separately.
*   **Validation:** The system must error if a Class references a non-existent Ability ID.

#### 5. Resource Bias Expectations
*   **Metadata Only:** Resource bias (Mana-focused vs Stamina-focused) is explicitly **descriptive metadata only**.
*   **No Mechanical Effect:** It has **no direct mechanical effect** in v1. It does not alter stat derivation, regeneration rates, or ability costs. Those are handled strictly by the Stat Layer attributes (INT/WIL/VIT) and the global rules in `SonderQuest-Stats.md`.

---

## 5. Per-Class Document Contract

To ensure consistency, every individual class design document (authored later) must follow this template.

### A. Required Structure for Class Docs
1.  **Class Fantasy & Role:**
    *   High-level description of themes (e.g., "Arcane scholar", "Brutal frontliner").
    *   Combat Role (Tank, DPS, Support, Control).
    *   **Spec Themes:** List the 3 Specializations with their Fantasy, Focus, and Key Elements.
2.  **Resource Pattern:**
    *   Intended resource focus (Mana, Stamina, or Mixed).
    *   *Note: This guides INT/VIT/WIL stat allocation.*
3.  **Growth Intent:**
    *   Descriptive summary of stat priorities.
4.  **Equipment Proficiencies:**
    *   **Weapons:** List of Allowed Families.
    *   **Armor:** List of Allowed Categories with rationale (e.g., "Light only for speed").
5.  **Starting Kit Summary:**
    *   **Weapon:** Default starter weapon.
    *   **Action Ability 1:** (e.g., Primary Damage).
    *   **Action Ability 2:** (e.g., Secondary Effect/AoE).
    *   **Utility Ability:** (e.g., Traversal/Interaction).
    *   **Ultimate Placeholder:** Name and High-level intent.
6.  **Identity Pillars:**
    *   **Utility Identity:** What non-combat problem does this class solve? (e.g., "Portal travel", "Lockpicking").
    *   **Ultimate Identity:** What is the "feel" of their big moment? (e.g., "Room clearing nuke", "Party-wide invulnerability").
7.  **Learn Rules:**
    *   Summary of how new abilities are acquired.
8.  **Talent Themes:**
    *   Descriptive list of planned upgrades mapped to the Spec themes defined in Section 3.

---

## 6. Class Validation Rules

The editor and build pipeline must verify these rules:

*   **Must Error:**
    *   Missing Stable ID.
    *   Reference to invalid Ability ID.
    *   Reference to invalid Weapon format.
    *   Missing internal Stat Layer definition.
    *   **Slot Violation:** Class starting gear includes Shield but no One-Handed Weapon.
    *   **Category Violation:** Class references undefined armor categories (e.g., "Plate" instead of "Heavy").
    *   **Slot Violation:** Class references undefined equipment slots (e.g., "Ring").
*   **May Warn:**
    *   Empty Proficiency list (Character can only use Unarmed).
    *   No starting abilities.

---

## 7. Directory Structure & ID Convention

Classes must reside in the `res://data/layers/classes/` directory to facilitate automatic discovery.

**Example Stable IDs:**
*   `layers/classes/warrior`
*   `layers/classes/mage`
*   `layers/classes/mage`
*   `layers/classes/thief`
*   `layers/classes/hero`
*   `layers/classes/hero`
*   `layers/classes/druid`

---

## 8. Talent Framework (Structure Only)

While full talent trees are a v2 feature, the v1 Class framework must reserve the structure to ensure save stability.

*   **Inert Data:** Talent nodes and definitions are generally **inert data** until implemented.
*   **No Logic:** Do not define talent points, UI trees, respec cost logic, or unlock requirements in this framework.
*   **Save Compatibility:** The Class definition may include a placeholder list for `talent_node_ids`, but the runtime should ignore them for v1. This ensures that when the system is expanded, the data structure on the resource doesn't require a breaking schema change.
