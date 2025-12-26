# SonderQuest Game Planning Document

This document summarizes the core systems planned for the platforming RPG, **SonderQuest**, based on the design conversation.

> **Note:** For specific details on Attribute Scaling, Damage Formulas, and Skill Checks, please refer to range-bound `documents/SonderQuest-Stats.md` which is now the primary source of truth for those mechanics. This document focuses on the higher-level structural goals.

---

## 1. Core Design Philosophy

*   **Foundation:** A turn-based, party-system RPG drawing inspiration from *Aidyn Chronicles: The First Mage*, *Baldur's Gate*, and D&D.
*   **Unified Ability System:** **Everything is an Ability** (spells, warrior skills, enemy actions).
    *   *Execution:* Abilities are a list of sequentially fired **Effects** (e.g., DealDamage, ApplyStatus, SpawnSummon, ModifyStat).
*   **Initiative-Based Turns:** Combat uses a visible Initiative stat to determine individual turn order for all units (Party + Enemies).
*   **Level Cap:** **40**.
*   **Max Party Size:** **4 characters**.
*   **Hub/Roster:** A *Shining Force*-style hub where all recruited allies gather and can be swapped into the active party.
*   **Hero Character:** The leader of the party. If the Hero dies, it is **Game Over**. Other characters have permadeath.

---

## 2. Damage & Defensive Model

A layered system ensures that defense matters at all stages of the game without early-game invincibility or late-game irrelevance.

### A. Damage Categorization
Every damage instance carries a **Category** and a **Type**. 

| Damage Category | Primary Damage Types | Secondary Tags (Status Effects) |
| :--- | :--- | :--- |
| **Physical** | Melee, Ranged, Bleed, Crush | N/A |
| **Magical** | Fire, Ice, Shock, Poison, Arcane, Nature | Burning, Frozen, Shocked, Poisoned, Wet |
| **True** | N/A | Ignores most mitigation |

### B. Defensive Hierarchy
1.  **Hit/Crit Check:** Accuracy vs Evasion, then Crit Chance.
2.  **Category Mitigation:** (Physical/Magic Defense) reduces raw damage.
3.  **Type Resistance:** (Fire Resist, etc.) reduces remaining damage.
4.  **Final Status:** Buffs/Debuffs apply final multipliers.

---

## 3. Core Attributes and Derived Stats

*See `SonderQuest-Stats.md` for full breakdown derived formulas, party Fortune rules, and scaling profiles.*

### A. Core Attributes
*   **Strength (STR)** (Scaling + Phys Def + Might)
*   **Dexterity (DEX)** (Scaling + Accuracy/Evasion + Lockpicking + Initiative)
*   **Intelligence (INT)** (Scaling + Max Mana + Analysis)
*   **Willpower (WIL)** (Scaling + Magic Def + Mana Regen + Status Resist)
*   **Vitality (VIT)** (Max HP + Phys Def + Stamina Regen)
*   **Charisma (CHA)** (Ultimate Charge + Summon/Effect Scaling + Party Fortune)

### B. Scaling Philosophy
We avoided specific "Melee Power" derived stats in favor of **Per-Weapon / Per-Ability Scaling Profiles**.
*   *Example:* A Greatsword scales primarily with STR, while a Dagger scales primarily with DEX.
*   *Example:* A Fear ability might scale its duration based on CHA.

> **Visual Reference:** See `SonderQuest-Targeting-And-AOE.md` for rules on facing arcs (Front/Side/Back) and area shapes.

---

## 4. Stat Growth Model (The "Layer" System)

To support **Class Swapping** without losing base identity, final stats are calculated across three layers:

`FinalStats = (SpeciesBase + CharacterGrowth + ClassGrowth) * Multipliers + FlatBonuses`

*   **SpeciesBase (Level 1-40):** Basic human, wolf, or skeleton curve. 
*   **CharacterGrowth:** Small unique bonuses (e.g., "Ally A" gets +1 STR every 3 levels regardless of class).
*   **ClassGrowth:** The primary driver. If you switch from Warrior to Mage, this entire layer swaps, recalculating HP, MP, and Power.

---

## 5. Skills & Exploration Checks

We distinguish between **Attribute Modifiers** for interaction and **Utility Abilities** for traversal.

*   **Attribute Checks (Roll-Based):**
    *   **Might (STR):** Move objects, break weak walls.
    *   **Lockpicking (DEX):** Open chests/doors.
    *   **Analysis (INT):** Decipher runes, operate devices.
*   **Utility Abilities (Movement Phase):**
    *   **Dash / Teleport:** Position readjustment.
    *   **World Interaction:** Smash Wall, Freeze Water (handled as Utility Abilities).

---

## 6. Class System (Launch Roster)

Classes offer different **ClassGrowth** layers, talent trees, and unique exploration abilities.

### A. Ability Loadout Rules
*   **Active Slots:** Players can equip up to **8** active abilities for combat.
*   **Ultimate:** Has its own separate slot and is not counted in the 8.
*   **Basic Attack:** Always available, does not use a slot.
*   **Scrolls:** Grant ability unlocks with class/stat/talent-point requirements, acting as utility or side-grades.
*   **Resets:** Players can reset their talents whenever they please (available at Hub/Camp).

### B. Launch Classes

| Class | Role Focus | Resources | Key Exploration Abilities | Ultimate | Passives |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Mage** | Nuker, Control, Utility | Mana | Arcane Sight, Telekinesis, Elemental Interaction | **Arcane Tempest** (Large AOE) | Bonus elemental effect chance. |
| **Warrior** | Frontliner, Tank, Melee Damage | Stamina | Break Barriers, Lift Heavy Objects, Intimidate | **War Cry of the Fallen** (Party buff + Taunt) | Reduced damage from first hit each turn. |
| **Druid** | Traversal, Nature, Healer | Mana/Stamina | Bird Form (Flight), Wolf Form (Gaps), Root Growth | **Avatar of the Wild** (Empowered form + Aura) | Passive regen outdoors. |
| **Thief** | Exploration, Tactical Striker | Stamina | Lockpicking, Trap Disarm, Wall Climb, Shadow Step | **Perfect Silence** (Vanish + Massive backstab) | Increased loot quality and trap success. |
| **Hero** | Adaptable Fighter, Leader | Stamina | Rally (Movement Buff), Light/Shadow Path | **Fatebreaker** (Single-target hit with alignment bonus) | Party-wide minor stat bonus. |

---

## 7. Ultimate System

*   **Charge Mechanic:** `UltimateCharge 0-100`.
*   **Charge Gain:** +10 charge at the start of the character's turn (baseline).
*   **Usage:** Ultimate consumes 100 Charge.

---

## 8. Permadeath and Exploration Gating

*   **Rule:** Allies die permanently; Hero death is Game Over.
*   **Hub:** Physically populated by all recruited allies. Includes memorials for the fallen.

---

## 9. Experience and Level Control

*   **Grinding Control:** Enemies below a certain level difference grant reduced or zero XP.
*   **Enemy Scaling:** Enemies use the same stat, ability, and cooldown systems as players.

---

## 10. Combat Math Examples (Updated)

*See `SonderQuest-Stats.md` for the exact breakdown of how resistance affects duration logic.*

**Scenario: A Mage casts "Fireball" (Base Range 40-50) at a Shielded Warrior.**
1.  **Damage Roll:** Rolls a 45.
2.  **Scaling:** Mage has high INT. Scaling adds +30 Damage. Total = 75.
3.  **Mitigation:** Warrior has Magic Defense. Reduces damage to 50.
4.  **Resistance:** Warrior has Fire Resist. Reduces damage to 40.
5.  **Status:** Mage's Effect Strength checks against Warrior's Status Resistance (WIL).
    *   *If Pass:* Burn applies. Initial duration set based on strength margin.
    *   *Each Turn:* Warrior rolls Break Check to end burn early.
