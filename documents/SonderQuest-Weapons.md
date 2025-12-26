# SonderQuest Weapon Schema & Design

This document defines the conceptual data structure for **Weapons**. It aligns with the resistance taxonomy, scaling profiles, and turn-based initiative defined in `SonderQuest-Stats.md`.

---

## 1. Definition

Weapons are equipment items that define the baseline **Strike Parameters** for a character. They are used by the **Basic Attack** action and by any **Weapon-Based Ability**. A weapon provides the base damage range, the damage type, and the attribute scaling logic.

---

## 2. Weapon Hierarchy Convention

To keep data manageable, weapons follow a hierarchy:
1.  **Base Weapon Definition:** Abstract class handling common logic (equip slots, durability if applicable).
2.  **Weapon Family:** Broad categories like "Swords", "Daggers", "Bows". (Defines shared traits like "Melee", "Two-Handed", "Standard Range").
3.  **Concrete Weapon:** Specific items like "Bronze Sword", "Iron Greatsword", "Golden Bow". (Defines specific stats and scaling).

---

## 3. Weapon Data Schema

The following fields characterize a Weapon definition.

### A. Identity & UI
*   **Name:** Display name (e.g., "Rusty Iron Sword").
*   **Description:** Flavor text and tooltip info.
*   **Icon:** Inventory sprite.
*   **Model Reference:** 3D mesh or sprite to attach to the character's hand socket.
*   **Tier:** Progression label (`Bronze`, `Iron`, `Steel`, `Gold`, `Legendary`).

### B. Classification
*   **Weapon Family:** `Sword`, `Axe`, `Hammer`, `Dagger`, `Bow`, `Staff`.
*   **Handedness:** `One-Handed` (Allows shield/offhand) or `Two-Handed` (Blocks offhand).
*   **Resistance Tags:**
    *   **Category:** `Physical` or `Magical` (defines which defense layer applies).
    *   **Type:** `Melee`, `Ranged`, `Crush`, `Bleed`, `Fire`, etc. (defines which resistance applies).
*   **Tags:** `Finesse` (DEX), `Heavy` (STR), `Reach`, `Thrown`.

### C. Core Combat Numbers
*   **Base Damage Range:** **Min** and **Max** integers (e.g., 8–12). *This is the raw roll before scaling.*
*   **Attack Range:** Override for attack distance (e.g., Bow = 12m, Spear = 2m).
*   **Accuracy Mod:** Additive bonus/penalty to hit chance (e.g., Heavy Hammer -10%, Dagger +5%).
*   **Crit Chance Mod:** Additive bonus to crit chance.
*   **Initiative Mod:** Additive penalty/bonus to turn order speed (e.g., Heavy weapons might have -2 Initiative).
*   **On-Hit Effects:** Built-in side effects (e.g., "10% Chance to Bleed", "Poison on Hit").

### D. Scaling Profile
Defines how Attributes increase the damage of this specific weapon.
*   **Primary Attribute:** The main scaling stat (e.g., `STR`).
*   **Secondary Attribute:** Optional support stat (e.g., `DEX`).
*   **Weights:** How much each point of attribute adds to the damage. (e.g., 1.0 for Primary, 0.5 for Secondary).

### E. Requirements & Restrictions
*   **Level Requirement:** Minimum character level to equip (intended for future progression).
*   **Attribute Minimums:** `Requires STR 12`, `Requires DEX 10`.
*   **Restrictions:** Tags preventing usage (e.g., `Cannot use in Wolf Form`).

---

## 4. Examples

**1. Bronze Sword**
*   **Family:** Sword (One-Handed).
*   **Damage:** Physical / Melee.
*   **Base Range:** 6–9 Damage.
*   **Scaling:** STR (Primary), DEX (Secondary).
*   **Stats:** Accuracy +0%, Init +0.

**2. Iron Dagger**
*   **Family:** Dagger (One-Handed).
*   **Damage:** Physical / Melee.
*   **Base Range:** 4–7 Damage.
*   **Scaling:** DEX (Primary), STR (Secondary).
*   **Stats:** Accuracy +5%, Crit Chance +5%, Init +2 (Fast).
*   **On-Hit:** 10% Chance to apply Bleed.

**3. Simple Bow**
*   **Family:** Bow (Two-Handed).
*   **Damage:** Physical / Ranged.
*   **Range:** 12 meters.
*   **Base Range:** 8–11 Damage.
*   **Scaling:** DEX (Primary), STR (Minor).
*   **Stats:** Accuracy +0%, Init +0.

**4. Oak Staff**
*   **Family:** Staff (Two-Handed).
*   **Damage:** Physical / Melee (Strike) or Magical (Cast).
*   **Base Range:** 5–8 Damage (Melee strike).
*   **Scaling:** INT (Primary), WIL (Secondary).
*   **Stats:** Init -1.
