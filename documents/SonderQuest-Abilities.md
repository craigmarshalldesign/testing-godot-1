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
> **Note:** Numeric level scaling for Damage/Healing is handled automatically by the **Power Curve** on `EffectDef`. It is not defined here.
*   **Damage Scaling:** Primary Attribute + Optional Secondary Attribute (and weights). Used for calculating raw damage output numbers.
*   **Effect Scaling:** Primary Attribute + Optional Secondary Attribute. Used for calculating healing, StatusPower (vs StatusResist), and utility potency. Status duration does NOT scale with level.

---

## Scaling Conventions (v1)

This section is the **single source of truth** for how attribute scaling works across all abilities. All other docs should align with these rules.

### A. Definitions

**Scaling Profile:** A small block describing how attributes contribute to a numeric effect.
*   **Primary Attribute:** The main stat driving the output (e.g., STR, INT).
*   **Secondary Attribute (Optional):** A support stat providing a minor contribution.
*   **Weights:** Multipliers for each attribute's contribution (e.g., Primary 1.0, Secondary 0.3).
*   **Coefficient (Optional):** A multiplier applied to the final scaled value (default 1.0). Used for effects like "50% damage DoT ticks."

**Damage Scaling vs Effect Scaling:**
*   **Damage Scaling:** Used for numeric damage outputs (direct hits, DoT ticks, zone tick damage). Makes offensive stats (STR, INT, DEX) important for dealing damage.
*   **Effect Scaling:** Used for non-damage numeric outputs and potency checks (healing, barriers, buff magnitude, status application power). Makes support stats (WIL, CHA, INT) important for utility.

> Both are attribute-driven and exist to ensure attributes remain consistently important across all ability types.

### B. Default Inheritance Rule

Numeric effects **inherit** scaling from the ability's Scaling Blocks by default:
*   `DealDamage`, DoT ticks, and Zone tick damage inherit **Damage Scaling**.
*   `Heal`, Barrier, Buff magnitude, and Status application power inherit **Effect Scaling**.

**If an ability omits a required scaling block:**
*   If the ability has damage effects but no Damage Scaling, each damage effect **must** define its own `scaling_weights`.
*   If the ability has heal/status effects but no Effect Scaling, each such effect **must** define its own `scaling_weights`.
*   An effect that needs scaling but lacks both ability defaults and per-effect overrides is **invalid** and should be flagged for correction.

### C. Per-Effect Override Rule

Any numeric effect **may override** the inherited scaling profile by specifying its own:
*   `scaling_weights` (Dictionary of Attribute->Weight)
*   `scaling_coefficient` (Float, default 1.0)

**Override Examples:**
*   A DoT tick effect scales at 0.5x coefficient of the ability's Damage Scaling.
*   A barrier effect uses Effect Scaling but with a different secondary attribute than the ability default.
*   A status application uses Effect Scaling but with shifted weight distribution.

### D. WeaponStrike Scaling Rule (v1)

`WeaponStrike` is a special effect type that does **NOT** use the ability's Damage Scaling by default.

*   WeaponStrike uses the **weapon's own scaling profile** (defined in `WeaponFamilyDef` or `WeaponDef`).
*   The ability's Damage Scaling is ignored for WeaponStrike unless the effect explicitly declares an override.
*   WeaponStrike multipliers (e.g., "125% weapon damage") are applied **after** computing the weapon's scaled roll, before mitigation.

> **Design Note:** Ability Damage Scaling is primarily for `DealDamage` effects. If an ability contains both WeaponStrike and DealDamage effects, only the DealDamage uses ability scaling by default.

### E. Zone Snapshot Rule

Persistent zones (Fire Patch, Poison Cloud) **snapshot** the caster's scaling attributes at cast time.
*   Zone tick damage uses the snapshotted values, not the caster's current stats.
*   This prevents mid-combat buff-stacking exploits and simplifies zone logic.

### F. Status Potency Rule

Status application uses:
*   **StatusPower** (derived from the ability's Effect Scaling) vs the target's **StatusResist** (derived from WIL or specific resistance).

Avoid wording that implies a specific attribute (like STR) is always used. The correct phrasing is:
*   "Effect Scaling derived power vs target resist."
*   NOT "Strength vs Resistance."

### G. Effects List
Abilities execute a sequence of **Effects**. If one fails (e.g., missed hit), subsequent effects may be cancelled based on configuration.
*   **Weapon Strike:** Roll weapon damage, apply weapon scaling, hit check.
*   **Deal Damage:** Roll baseline damage range (L1 * Curve), inherit Damage Scaling, hit check.
*   **Heal:** Restore HP to target.
*   **Apply Status:** Attempt to apply a condition.
    *   *Parameters:* Status ID, Duration (Min/Max Turns).
    *   *Logic:* Uses "StatusPower (from Effect Scaling) vs target's StatusResist" check.
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
*   **ID:** `abilities/action/magic/fireball`
*   **Category:** Action Ability (Spell)
*   **Target:** Enemy, Range 8, Single Target.
*   **Cost:** 15 **Mana**.
*   **Scaling:** Damage (INT Primary), Effect (INT Primary).
*   **Effects:**
    1.  Deal Damage (Base_L1: 8-10, scales w/ Curve, Type: Fire).
    2.  Apply Status (Burn, Min 1 Turn, Max 3 Turns).
*   **AI Hint:** Damage, Clustered Enemies.

**2. Charged Strike**
*   **ID:** `abilities/action/melee/charged_strike`
*   **Category:** Action Ability (Weapon-Based)
*   **Requirement:** Melee Weapon.
*   **Target:** Enemy, Range: Weapon Range.
*   **Cost:** 20 **Stamina**.
*   **Scaling:** Damage (Inherits Weapon Scaling), Effect (DEX Primary).
*   **Effects:**
    1.  Weapon Strike (100% Weapon Damage).
    2.  Deal Damage (Base_L1: 4-6, scales w/ Curve, Type: Lightning, separate roll).
    3.  Apply Status (Shock, Min 1 Turn, Max 2 Turns).
*   **AI Hint:** Damage, Opener.

**3. Smash Wall (Utility Ability)**
*   **ID:** `abilities/utility/interaction/smash_wall`
*   **Category:** Utility / Interaction
*   **Phase:** Movement Phase.
*   **Target:** World Object (Tag: Breakable), Cone shape (short range).
*   **Scaling:** Effect (STR Primary) -> determines Rank/Success.
*   **Effects:**
    1.  Environment Interaction (Tag: Smash, Force: High).
*   **Note:** Opens paths, breaks crates. Does NOT damage enemies.

**4. Bird Form (Utility Ability)**
*   **ID:** `abilities/utility/mobility/bird_form`
*   **Category:** Utility / Movement
*   **Phase:** Movement Phase.
*   **Target:** Ground Point or Direction.
*   **Range:** 6m.
*   **Effects:**
    1.  Movement (Fly/Dash to point).
*   **Preview:** Shows ghost of character at destination.

---

## Scaling Consistency Checklist (v1)

Use this checklist to validate ability definitions:

- [ ] Every numeric effect has a `Base_L1` value or uses `WeaponStrike` (which references weapon base).
- [ ] Every ability with damage effects includes `Damage Scaling` (unless each effect defines its own override).
- [ ] Every ability with heals, barriers, buffs, or status application includes `Effect Scaling` (unless each effect defines its own override).
- [ ] `WeaponStrike` effects use weapon scaling by default (ability `Damage Scaling` does NOT apply unless explicitly overridden).
- [ ] Persistent zones specify whether they snapshot caster scaling at cast time.
- [ ] Status application uses `StatusPower (from Effect Scaling) vs target's StatusResist` terminology.

> **Flagging Rule:** Any ability that violates these rules should be flagged for correction during review.
