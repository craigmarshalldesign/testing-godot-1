# SonderQuest Ability Schema & Design

This document defines the conceptual data structure for **Abilities**. It aligns with the turn-based logic, scaling profiles, and effect systems defined in `SonderQuest-Stats.md`.

---

## 1. Definition & Philosophy

*   **Universal Definition:** An "Ability" is the single atomic unit of action in SonderQuest. Spells, warrior techniques, enemy attacks, summon behaviors, and even specific exploration interactions are all defined as Abilities.
*   **Data-Driven:** Abilities are defined by data (targeting rules, costs, effect lists), not hard-coded scripts per spell.

## 2. Ability vs. Basic Attack

*   **Basic Attack:** This is a special, always-available interaction. It essentially "casts" a generic ability that uses the parameters of the currently equipped character weapon. It typically utilizes the "Weapon Strike" effect type.
*   **Weapon-Based Abilities:** Some abilities (like *Charged Strike*) are wrappers around a weapon attack. They trigger a Weapon Strike (using the equipped weapon's damage and scaling) and then append additional effects (bonus lightning damage, status application).

---

## 3. Turn Structure
Each character's turn is divided into two distinct phases:
1.  **Movement Phase:** The character can reposition and use **Utility Abilities** (like `Dash`, `Teleport`, `Smash Wall`). It ends when movement is exhausted or the player confirms end of movement.
2.  **Action Phase:** The character chooses **exactly one** action: either a Basic Attack or an **Action Ability**. This consumes the turn.

---

## 4. Ability Categories
Abilities fall into one of two strict execution categories:

### A. Action Abilities
*   **Phase:** Usable only in the **Action Phase**.
*   **Cost:** Consumes the character's Action. Ends the turn after execution (unless specific multi-action rules apply later).
*   **Role:** Damage, Healing, Combat Control, Summoning.

### B. Utility Abilities
*   **Phase:** Usable during the **Movement Phase**.
*   **Cost:** Does **not** consume the Action. Can be used before or after moving, or interspersed with movement steps.
*   **Role:** Positioning (Dash, Blink), World Interaction (Smash Wall, Unlock Door).
*   **Combat Limitation:** In v1, Utility Abilities are **not** intended to deal direct combat damage to enemies. Their purpose is tactical setup and traversal.

### C. Utility Ranks
Utility Abilities act as exploration progression and have **Ranks** (Rank 1..N).
*   **Progression:** Higher ranks improve parameters (e.g., Dash Distance, Jump Height, Smash Strength level).
*   **Acquisition:** Unlocked via Talent Nodes, Class Milestones, Story Events, or Items.

---

## 5. Ability Data Schema

The following fields characterize an Ability definition.

### A. Identity & UI
*   **Display Name:** The visible name of the ability.
*   **Description:** Tooltip text.
*   **Icon:** Reference to the UI sprite.
*   **Category:** `Action` (Spell, Technique) or `Utility` (Movement, Interaction).
*   **Tags:** Keywords used for filtering (e.g., `Fire`, `Melee`, `Stealth`, `Exploration`).

### B. Availability & Learning
*   **Learn Rule:** How the character acquires this ability (e.g., Level Up, Scroll Item, Talent Node unlock, Enemy Only).
*   **Learner Allow-List:** Which classes or character IDs can learn this ability (e.g., "Mage Only", "Hero Only", "Wolf Enemy Only").

### C. Usage Requirements
*   **Resource Cost:** Amount of **Mana** or **Stamina** consumed on use. (Some abilities may generate resources instead).
*   **Weapon Requirement:** Must have specific weapon type equipped (e.g., `Requires: Dagger` or `Requires: Staff`).
*   **Form/Stance Requirement:** Must be in a specific transformation state (e.g., `Requires: Bear Form`).
*   **Context:** Where can this be used? (`Combat Only`, `Exploration Only`, or `Both`).

> **Design Intent:** Attributes influence resource pools and regeneration by default, but resource values (Max/Regen) are intentionally exposed as independent stats to be modified by gear, buffs, debuffs, and environmental effects.

### D. Targeting & Pathing
*   **Target Type:** Who can be targeted? (`Self`, `Ally`, `Enemy`, `Ground Point`, `Direction`).
*   **Range Rule:** Does it use the Weapon's range or a specific ability override range?
*   **Area Shape:** The hit area configuration (`Single Target`, `Radius/Circle`, `Cone`, `Line`).
*   **Line of Sight:** Is LOS required to cast? (True/False).
*   **Movement Component:** Does the capability involve actor movement? (`None`, `Dash to Target`, `Teleport to Point`).

### E. Costs, Cooldowns, & Charges
*   **Resource Cost:** Amount consumed on use.
*   **Ultimate Cost:** If `True`, consumes 100 Ultimate Charge.
*   **Cooldown:** Time before reuse, measured in **Turns**.
*   **Charges:** Optional max charges and recharge rate (per turn).

### F. Scaling Blocks
Matching the `SonderQuest-Stats.md` definitions:
*   **Level Scaling:** Coefficient that increases Base Damage/Healing per character level (e.g., `+1.5 per Level`).
*   **Damage/Healing Scaling:** Primary Attribute + Optional Secondary Attribute (and weights). Used for calculating raw output numbers.
*   **Effect Scaling:** Primary Attribute + Optional Secondary Attribute. Used for calculating Status Strength (vs Resistance), duration, and utility potency.

### G. Effects List
Abilities execute a sequence of **Effects**. If one fails (e.g., missed hit), subsequent effects may be cancelled based on configuration.
*   **Weapon Strike:** Roll weapon damage, apply weapon scaling, hit check.
*   **Deal Damage:** Roll ability base damage range (scaled by Level), apply Ability Scaling, hit check.
*   **Heal:** Restore HP to target.
*   **Apply Status:** Attempt to apply a condition.
    *   *Parameters:* Status ID, Duration (Min/Max Turns).
    *   *Logic:* Uses "Strength (from Effect Scaling) vs Resistance (Target)" check.
*   **Modify Stat:** Buff/Debuff a specific stat (Accuracy, Speed, etc.) for X turns.
*   **Movement:** Displace the caster or target (Push/Pull, Dash).
*   **Spawn Summon:** Create a unit at the target location.
*   **Environmental Interaction:** Trigger a world object tag (e.g., `Smash Wall`, `Freeze Water`).

### H. AI Usage Hints
To allow enemies to use abilities intelligently:
*   **Role:** `Damage`, `Heal`, `Control`, `Buff`, `Utility`.
*   **Preferred Range:** Ideal distance to use this.
*   **Target Priority:** Hints like `Lowest HP`, `Clustered`, `Player Hero`, `Self`.
*   **Condition:** `On Cooldown`, `Health < 30%`, `Target is Burning`.

### I. Presentation Hooks
*   **Animation:** Name of the character animation to play (e.g., `Cast_Overhead`, `Slash_Heavy`).
*   **VFX:** Particle systems to instantiate (Start, Projectile, Impact).
*   **SFX:** Audio cues.
*   **UI Feedback:** Floating text style (Critical, Heal, Status Name).

---

## 6. Examples
 
**1. Fireball**
*   **Category:** Action Ability (Spell)
*   **Target:** Enemy, Range 8, Single Target.
*   **Cost:** 15 **Mana**.
*   **Level Growth:** +2 Damage/Lvl.
*   **Scaling:** Damage (INT Primary), Effect (INT Primary).
*   **Effects:**
    1.  Deal Damage (Base 8-12 + LvlGrowth, Type: Fire).
    2.  Apply Status (Burn, Min 1 Turn, Max 3 Turns).
*   **AI Hint:** Damage, Clustered Enemies.

**2. Charged Strike**
*   **Category:** Action Ability (Weapon-Based)
*   **Requirement:** Melee Weapon.
*   **Target:** Enemy, Range: Weapon Range.
*   **Cost:** 20 **Stamina**.
*   **Scaling:** Damage (Inherits Weapon Scaling), Effect (DEX Primary).
*   **Effects:**
    1.  Weapon Strike (100% Weapon Damage).
    2.  Deal Damage (Bonus 10-15 Lightning, separate roll).
    3.  Apply Status (Shock, Min 1 Turn, Max 2 Turns).
*   **AI Hint:** Damage, Opener.

**3. Smash Wall (Utility Ability)**
*   **Category:** Utility / Interaction
*   **Phase:** Movement Phase.
*   **Target:** World Object (Tag: Breakable), Cone shape (short range).
*   **Scaling:** Effect (STR Primary) -> determines Rank/Success.
*   **Effects:**
    1.  Environment Interaction (Tag: Smash, Force: High).
*   **Note:** Opens paths, breaks crates. Does NOT damage enemies.

**4. Bird Burst (Utility Ability)**
*   **Category:** Utility / Movement
*   **Phase:** Movement Phase.
*   **Target:** Ground Point or Direction.
*   **Range:** 6m.
*   **Effects:**
    1.  Movement (Fly/Dash to point).
*   **Preview:** Shows ghost of character at destination.
