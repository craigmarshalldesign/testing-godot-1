# SonderQuest Starter Abilities & Statuses (v1)

This document defines the content for the Starter Ability Set and the underlying Status/Reaction rules for v1. It serves as the data reference for implementing `AbilityDef` and `StatusDef` resources.

---

## 1. Status and Reactions Reference (v1)

These rules define the timing, stacking, and interactions for all status effects in the starter set.

### A. Core Rules

#### 1. Timing and Resolution Order
*   **On Hit:** When an ability hits a target:
    1.  Resolve immediate effects (Damage, Heal, Movement, etc).
    2.  Apply status effects listed on the ability.
    3.  Resolve any **Reactions** triggered by the target’s new state (e.g., Jolt).
*   **Start of Turn:**
    *   All **DoT** (Damage over Time) and **HoT** (Heal over Time) ticks trigger at the **Start of Turn**.
    *   Ticks use the attributes/stats of the **Source** that applied them at the moment of application (snapshot) or dynamic reference depending on implementation (v1 simplifies to snapshot usually, but "using the source" implies attribution).

#### 2. Stacking Models
Statuses must use one of these three distinct behaviors:

*   **Instance-Stacking (DoTs/HoTs):**
    *   **Behavior:** Each application creates a separate instance with its own duration and tick value.
    *   **Result:** Instances tick additively and expire independently.
    *   **Used For:** `Burning`, `Poisoned`, `Regeneration`.

*   **Stack-Counter:**
    *   **Behavior:** A single status instance with an integer stack count.
    *   **Result:** Stacks share a single duration. Reapplying adds stacks (up to a cap) and refreshes duration.
    *   **Used For:** `Chill` (Cap: 4).

*   **Non-Stacking (Unique):**
    *   **Behavior:** Only one instance exists at a time.
    *   **Result:** Reapplying refreshes duration to the *newest* application's duration. It keeps the *higher* of current strength vs new strength (if applicable).
    *   **Used For:** `Rooted` (Critical), `Grounded`, `Taunted`, `Barrier`, `Rage`, `Wet`.

---

### B. Elemental State Rules

These rules are authoritative for v1. If an interaction is not listed here, it does not exist.

#### 1. Wet
*   **Effect:** Move Radius -20%.
*   **Purpose:** Short-lived state to setup Chill and Lightning reactions.

#### 2. Chill
*   **Effect:** Move Radius -10% per stack.
*   **Cap:** 4 Stacks (Max -40%).
*   **Coexistence:** Can exist alongside `Burning` and `Poisoned`.

#### 3. Burning
*   **Effect:** Fire damage per turn.
*   **Model:** Instance-Stacking. Stacks additively.

#### 4. Interaction Chart

| Current State | Inc. Hit Type | Resulting Interaction | Notes |
| :--- | :--- | :--- | :--- |
| **Wet** | **Ice** (applies Chill) | **Remove Wet**<br>**Apply +2 Chill Stacks** | Preserves movement penalty (-20% -> 2 stacks). |
| **Chill** | **Water** (applies Wet) | **No Change** | Target does *not* become Wet. Chill prevents Wet application. |
| **Wet** | **Fire** (no Burn) | **No Effect** | Wet remains unless spell explicitly removes it. |
| **Wet** | **Fire** (applies Burn) | **Remove Wet**<br>**Apply Burning** | Standard conversion. |
| **Wet** | **Lightning** | **Trigger Jolt** | See Jolt Specification below. |
| **Chill** | **Fire** (applies Burn) | **Remove 1 Chill Stack**<br>**Apply Burning** | Fire melts ice slightly, but both coexist. |
| **Chill** | **Fire** (no Burn) | **No Effect** | No automatic interaction. |

#### 5. Jolt Specification (Reaction)
*   **Trigger:** Lightning hit on a **Wet** target.
*   **Effect:** Immediate Bonus Damage.
*   **Source:** The caster of the lightning ability (Credit/Agro goes to caster).
*   **Damage:** Calculated as a % of the lightning ability's spell damage.
*   **Shape:** Small AoE around the wet target (v1 Rec: Radius 1m).
*   **Note:** Start separation: Jolt is a separate damage event, specifically for feedback clarity.

---

### C. Control Statuses (Non-Elemental)

These statuses do not participate in elemental interactions.

*   **Grounded**
    *   **Effect:** Cannot Move, Cannot Jump/Fly.
    *   **Stacking:** Non-stacking. Refresh duration.

*   **Rooted**
    *   **Effect:** Cannot Move. Takes Nature damage each turn.
    *   **Stacking:** Non-stacking. Does *not* stack damage instances.
    *   **Refresh:** Updates to new duration; updates damage only if new value is higher.

*   **Taunted**
    *   **Effect:** AI prioritizes attacking the source of the Taunt.
    *   **Stacking:** Non-stacking. Refresh duration.

*   **Barrier**
    *   **Effect:** Absorbs incoming damage up to a value.
    *   **Stacking:** Non-stacking. Replaces logic (keep higher value).

*   **Poisoned**
    *   **Effect:** Nature damage per turn.
    *   **Stacking:** Instance-Stacking.

*   **Regeneration**
    *   **Effect:** Healing per turn.
    *   **Stacking:** Instance-Stacking.

*   **Rage**
    *   **Effect:** Stat buff (+Dmg/Str etc).
    *   **Stacking:** Non-stacking. Refresh duration.

*   **Blind**
    *   **ID:** `statuses/conditions/blind`
    *   **Type:** Debuff
    *   **Effect:** Accuracy -50% (Weapon accuracy only for v1).
    *   **Stacking:** Non-stacking. Refresh duration.
    *   **Duration:** 1-2 turns.
    *   **Note:** No elemental interactions.

*   **Bleeding**
    *   **ID:** `statuses/conditions/bleeding`
    *   **Type:** DoT (Chemical/Physical)
    *   **Effect:** Physical damage per turn.
    *   **Stacking:** Non-stacking (Reapply refreshes duration).
    *   **Duration:** 3 turns.

*   **Wolfkin Form**
    *   **ID:** `statuses/forms/wolfkin_form`
    *   **Type:** Form
    *   **Effect:** Enables Beast ability list. Basic Attack uses Natural profile.
    *   **Stacking:** Non-stacking.
    *   **Duration:** 3 turns.
    *   **Notes:** Casting non-Beast ability ends form.

*   **Howl**
    *   **ID:** `statuses/buffs/howl`
    *   **Type:** Buff
    *   **Effect:** +2 Stamina Regen (Flat bonus for v1).
    *   **Stacking:** Non-stacking. Refresh duration.
    *   **Duration:** 2 turns.

---

### D. Authoring Guidelines for Abilities

When authoring `AbilityDef` resources in the sections below, every entry MUST specify:
1.  **Status Applied:** ID reference (e.g., `statuses/conditions/wet`).
2.  **Parameters:** Duration (min/max), Tick Value (if fixed), or Stacks applied.
3.  **Reaction Data:** For Lightning, specify Jolt % damage.

---

## 2. Universal Baseline Ability (v1)

### 0. Basic Attack
*   **ID:** `abilities/action/attack/basic_attack`
*   **Category:** Action Ability (Weapon Strike)
*   **Context:** Combat Only
*   **Phase:** Action Phase
*   **Tags:** Basic, Attack, WeaponStrike
*   **Learn Rules:**
    *   **Default Learners (Starter):** All units (players and enemies)
    *   **Other Player Learners:** Always available
    *   **Enemy Use:** Always available
*   **Requirements:** Must have a valid strike source
    *   Uses equipped Main Weapon if present.
    *   If no Main Weapon, uses Unarmed strike profile.
    *   If unit has a Natural Weapon (fangs/claws) assigned, use that as strike source instead of Unarmed.
*   **Hit Check:** Accuracy vs Evasion (Weapon)
*   **Targeting:** Enemy Unit, Single Target, LOS: Yes
*   **Range:** From strike source (Melee 2.0m, Ranged varies)
*   **AoE Shape:** Single
*   **Cost:** None
*   **Cooldown:** 0 turns
*   **Scaling Blocks:**
    *   **Damage Scaling:** From equipped weapon profile (Melee: STR/DEX, Ranged: DEX/STR, Staff: INT/WIL)
    *   **Effect Scaling:** None
*   **Effects:**
    1.  **Weapon Strike:** 100% weapon damage to the target
*   **Damage Category and Type:**
    *   Determined by strike source (Physical/Magical, Melee/Ranged, Crush/Bleed).
*   **AI Hints:** Damage
*   **Notes:**
    *   Default fallback action. On-hit statuses from weapons are ignored in v1.

Basic Attack always uses the unit’s current strike source. If a Main Weapon is equipped, Basic Attack uses that weapon’s damage range, range (melee reach in meters or ranged max distance), and damage tags. If no Main Weapon is equipped, Basic Attack uses the Unarmed strike profile, unless the unit has a Natural Weapon assigned (fangs/claws) in which case the Natural Weapon becomes the strike source. The strike source defines the damage category and type tags used for combat rules: most weapons are Physical with tags like Melee or Ranged; a staff can be treated as a weapon strike source that is still Physical by default unless the weapon explicitly marks itself as Magical-strike. Scaling for Basic Attack is driven by the strike source’s scaling profile: melee weapons typically weight STR primary with DEX secondary, ranged weapons typically weight DEX primary with STR secondary, and staves typically weight INT primary with WIL secondary. Initiative modifiers, accuracy modifiers, and any other weapon-defined modifiers apply to Basic Attack exactly as listed on the weapon.

---

## 3. Class Utility Abilities (Mobility & Interaction)

### 1. Charge (Wallbreaker)
*   **ID:** `abilities/utility/warrior/charge`
*   **Category:** Utility Ability (Mobility + Interaction)
*   **Context:** Exploration + Combat
*   **Phase:** Movement Phase (Combat)
*   **Tags:** Mobility, Interaction, Warrior, Wallbreaker
*   **Learn Rules:**
    *   **Default Learners (Starter):** Warrior
    *   **Other Player Learners:** Not learnable in v1
    *   **Enemy Use:** Not used by enemies in v1
*   **Hit Check:** Auto-Hit (Movement/Interaction)
*   **Targeting:** Directional (player aims a direction)
*   **Range:** Dash forward 8.0m (v1)
*   **Cooldown:** 2 turns (Combat) / 2s (Exploration)
*   **Cost:** 6 Stamina
*   **Effects:**
    1.  **Reposition Self:** Rapidly move forward up to 8.0m, stopping early if blocked.
    2.  **Interaction:** If movement collides with breakable object (Wall/Boulder), destroy it.
*   **Notes:**
    *   Primarily an exploration gate tool that doubles as combat reposition.
    *   No enemy collision damage in v1.

### 2. Teleport (Blink)
*   **ID:** `abilities/utility/mage/teleport`
*   **Category:** Utility Ability (Mobility)
*   **Context:** Exploration + Combat
*   **Phase:** Movement Phase (Combat)
*   **Tags:** Mobility, Arcane, Mage
*   **Learn Rules:**
    *   **Default Learners (Starter):** Mage
    *   **Other Player Learners:** Not learnable in v1
    *   **Enemy Use:** Not used by enemies in v1
*   **Hit Check:** Auto-Hit (Movement)
*   **Targeting:** Directional (forward relative to facing)
*   **Range:** Teleport forward 6.0m (v1)
*   **Cooldown:** 2 turns (Combat) / 2s (Exploration)
*   **Cost:** 6 Mana
*   **Effects:**
    1.  **Reposition Self:** Teleport forward up to 6.0m, snapping to nearest valid position if blocked.
*   **Notes:**
    *   Exploration gap-crossing tool.
    *   No damage, no enemy targeting.

### 3. Dash
*   **ID:** `abilities/utility/hero/dash`
*   **Category:** Utility Ability (Mobility)
*   **Context:** Exploration + Combat
*   **Phase:** Movement Phase (Combat)
*   **Tags:** Mobility, Hero
*   **Learn Rules:**
    *   **Default Learners (Starter):** Hero
    *   **Other Player Learners:** Not learnable in v1
    *   **Enemy Use:** Not used by enemies in v1
*   **Hit Check:** Auto-Hit (Movement)
*   **Targeting:** Directional (aim any direction)
*   **Range:** Dash 5.0m (v1)
*   **Cooldown:** 1 turn (Combat) / 1s (Exploration)
*   **Cost:** 5 Stamina
*   **Effects:**
    1.  **Reposition Self:** Quick dash up to 5.0m in aimed direction, stopping early if blocked.
*   **Notes:**
    *   Small, frequent reposition option.

### 4. Bird Form (Hop-Fly)
*   **ID:** `abilities/utility/druid/bird_form`
*   **Category:** Utility Ability (Form + Vertical Mobility)
*   **Context:** Exploration + Combat
*   **Phase:** Movement Phase (Combat)
*   **Tags:** Mobility, Form, Druid
*   **Learn Rules:**
    *   **Default Learners (Starter):** Druid
    *   **Other Player Learners:** Not learnable in v1
    *   **Enemy Use:** Not used by enemies in v1
*   **Hit Check:** Auto-Hit (Movement/Form)
*   **Targeting:** Self
*   **Range:** Vertical lift up to 4.0m, with a small forward glide up to 2.0m (v1)
*   **Cooldown:** 3 turns (Combat) / 3s (Exploration)
*   **Cost:** 7 Mana
*   **Effects:**
    1.  **Reposition Self:** Transform briefly and gain controlled upward lift (jump) with minor glide.
*   **Notes:**
    *   Exploration traversal tool (verticality). Limited combat use.

### 5. Shadow Slide
*   **ID:** `abilities/utility/thief/shadow_slide`
*   **Category:** Utility Ability (Mobility)
*   **Context:** Exploration + Combat
*   **Phase:** Movement Phase (Combat)
*   **Tags:** Mobility, Shadow, Thief
*   **Learn Rules:**
    *   **Default Learners (Starter):** Thief
    *   **Other Player Learners:** Not learnable in v1
    *   **Enemy Use:** Not used by enemies in v1
*   **Hit Check:** Auto-Hit (Movement)
*   **Targeting:** Ground Point (within radius)
*   **Range:** Choose destination point within 7.0m (v1), LOS not required (must be navigable).
*   **Cooldown:** 2 turns (Combat) / 2s (Exploration)
*   **Cost:** 6 Stamina
*   **Effects:**
    1.  **Reposition Self:** Slide through shadow to selected point.
*   **Notes:**
    *   Point targeting differentiates it from Dash/Teleport.

---

## 4. Warrior Starter Abilities (v1)

### 6. Rage Strike
*   **ID:** `abilities/action/melee/rage_strike`
*   **Category:** Action Ability (Weapon-Based)
*   **Context:** Combat Only
*   **Phase:** Action Phase
*   **Tags:** Melee, Physical, Technique, Berserker
*   **Learn Rules:**
    *   **Default Learners (Starter):** Warrior
    *   **Other Player Learners:** Scroll Learnable (Trainer or Scroll)
    *   **Enemy Use:** Allowed
*   **Requirements:** Main Weapon must be Melee (not Staff, not Bow)
*   **Hit Check:** Accuracy vs Evasion (Weapon)
*   **Targeting:** Enemy Unit, Range: Weapon Range, Single Target, LOS: Yes
*   **Cost:** 10 Stamina
*   **Cooldown:** 1 turn
*   **Scaling Blocks:**
    *   **Damage Scaling:** STR (Primary), VIT (Secondary minor)
    *   **Effect Scaling:** STR (Primary)
*   **Effects:**
    1.  **Weapon Strike** (100% weapon damage)
    2.  **Weapon Strike** (60% weapon damage)
    3.  **Deal Damage (Self)** (Base_L1: 2–3, Type: True, cannot crit)
*   **AI Hints:** Damage, Finisher
*   **Notes:**
    *   The self-damage is a direct effect, not a status.
    *   Multi-hit exists to validate sequencing, hit rolls, and future on-hit hooks.
    *   **Scaling Notes:** WeaponStrike effects use weapon scaling. Damage Scaling (STR) applies only to the self-damage DealDamage effect.

### 7. Ground Stomp
*   **ID:** `abilities/action/melee/ground_stomp`
*   **Category:** Action Ability (Technique)
*   **Context:** Combat Only
*   **Phase:** Action Phase
*   **Tags:** Melee, Physical, Control, Warden
*   **Learn Rules:**
    *   **Default Learners (Starter):** Warrior
    *   **Other Player Learners:** Scroll Learnable (Trainer or Scroll)
    *   **Enemy Use:** Allowed
*   **Targeting:** Self, **Available Targets:** Radius AoE, LOS: No
*   **AoE Shape:** Radius/Circle (Centered on caster)
*   **AoE Size (v1):** Radius 1
*   **Cost:** 12 Stamina
*   **Cooldown:** 2 turns
*   **Scaling Blocks:**
    *   **Damage Scaling:** STR (Primary), VIT (Secondary minor)
    *   **Effect Scaling:** STR (Primary)
*   **Effects:**
    1.  **Deal Damage** (Base_L1: 5–7, Type: Physical)
    2.  **Apply Status** (`statuses/conditions/grounded`, Min 1 Turn, Max 1 Turn)
*   **AI Hints:** Control
*   **Status Notes:**
    *   Grounded: cannot move, cannot jump (duration controls the lock)

### 8. Taunting Shout
*   **ID:** `abilities/action/buff/taunting_shout`
*   **Category:** Action Ability (Technique)
*   **Context:** Combat Only
*   **Phase:** Action Phase
*   **Tags:** Shout, Control, Presence, Commander
*   **Learn Rules:**
    *   **Default Learners (Starter):** Warrior
    *   **Other Player Learners:** Scroll Learnable (Trainer or Scroll)
    *   **Enemy Use:** Allowed
*   **Hit Check:** Auto-Hit (Buff/Debuff)
*   **Targeting:** Self, **Available Targets:** Radius AoE, LOS: No
*   **AoE Shape:** Radius/Circle (Centered on caster)
*   **AoE Size (v1):** Radius 2
*   **Cost:** 8 Stamina
*   **Cooldown:** 3 turns
*   **Scaling Blocks:**
    *   **Damage Scaling:** None
    *   **Effect Scaling:** CHA (Primary), WIL (Secondary minor)
*   **Effects:**
    1.  **Apply Status** (`statuses/conditions/taunted`, Min 2 Turns, Max 2 Turns)
*   **AI Hints:** Control
*   **Status Notes:**
    *   Taunted: AI prioritizes the shout source when possible.

---

## 5. Mage Starter Abilities (v1)

### 9. Firebolt
*   **ID:** `abilities/action/magic/firebolt`
*   **Category:** Action Ability (Spell)
*   **Context:** Combat Only
*   **Phase:** Action Phase
*   **Tags:** Magic, Fire, Projectile, Damage, Pyromancer
*   **Learn Rules:**
    *   **Default Learners (Starter):** Mage
    *   **Other Player Learners:** Scroll Learnable (Trainer or Scroll)
    *   **Enemy Use:** Allowed
*   **Hit Check:** Auto-Hit (Magic Defense applies mitigation)
*   **Targeting:** Enemy Unit, Range 8, Single Target, LOS: Yes
*   **Cost:** 6 Mana
*   **Cooldown:** 0 turns
*   **Scaling Blocks:**
    *   **Damage Scaling:** INT (Primary), WIL (Secondary minor)
    *   **Effect Scaling:** INT (Primary)
*   **Effects:**
    1.  **Deal Damage** (Base_L1: 6–8, Type: Fire)
    2.  **Apply Status** (`statuses/conditions/burning`, Min 3 Turns, Max 3 Turns)
    3.  **Burning Tick (per instance):** Base_L1: 4 per turn (Fire), scales with Damage Scaling
*   **AI Hints:** Damage
*   **Status Interaction Reminders:**
    *   Burning is instance-stacking.
    *   If Wet is present, Wet is removed only if Burning is applied (this ability does apply Burning).

### 10. Drench
*   **ID:** `abilities/action/magic/drench`
*   **Category:** Action Ability (Spell)
*   **Context:** Combat Only
*   **Phase:** Action Phase
*   **Tags:** Magic, Water, Control, Cryomancer
*   **Learn Rules:**
    *   **Default Learners (Starter):** Mage
    *   **Other Player Learners:** Scroll Learnable (Trainer or Scroll)
    *   **Enemy Use:** Allowed
*   **Hit Check:** Auto-Hit (Magic Defense applies mitigation)
*   **Targeting:** Enemy Unit, Range 7, Single Target, LOS: Yes
*   **Cost:** 7 Mana
*   **Cooldown:** 1 turn
*   **Scaling Blocks:**
    *   **Damage Scaling:** INT (Primary), WIL (Secondary minor)
    *   **Effect Scaling:** INT (Primary)
*   **Effects:**
    1.  **Deal Damage** (Base_L1: 5–7, Type: Water)
    2.  **Apply Status** (`statuses/conditions/wet`, Min 2 Turns, Max 2 Turns)
*   **AI Hints:** Opener, Debuff
*   **Status Interaction Reminders (from your chart):**
    *   If the target already has Chill, Wet does not apply and no Chill is added.
    *   Wet is primarily a setup state for Ice conversion and Lightning Jolt.

### 11. Magic Shield
*   **ID:** `abilities/action/magic/magic_shield`
*   **Category:** Action Ability (Spell)
*   **Context:** Combat Only
*   **Phase:** Action Phase
*   **Tags:** Magic, Support, Barrier, Conjuror
*   **Learn Rules:**
    *   **Default Learners (Starter):** Mage
    *   **Other Player Learners:** Scroll Learnable (Trainer or Scroll)
    *   **Enemy Use:** Allowed
*   **Hit Check:** Auto-Hit (Buff)
*   **Targeting:** Ally Unit (or Self), Range 8, Single Target, LOS: Yes
*   **Cost:** 10 Mana
*   **Cooldown:** 2 turns
*   **Scaling Blocks:**
    *   **Damage Scaling:** None
    *   **Effect Scaling:** INT (Primary), WIL (Secondary minor)
*   **Effects:**
    1.  **Apply Status** (`statuses/buffs/magic_barrier`, Min 2 Turns, Max 2 Turns)
*   **Barrier Value:** Base_L1: 10–14 shield, scales with Effect Scaling
*   **Barrier Filter:** absorbs Magical category damage only (does not absorb Physical)
*   **AI Hints:** Buff

---

## 6. Thief Starter Abilities (v1)

### 12. Backstab
*   **ID:** `abilities/action/melee/backstab`
*   **Category:** Action Ability (Technique)
*   **Context:** Combat Only
*   **Phase:** Action Phase
*   **Tags:** Melee, Physical, Movement, Finisher, Assassin
*   **Learn Rules:**
    *   **Default Learners (Starter):** Thief
    *   **Other Player Learners:** Scroll Learnable (Trainer or Scroll)
    *   **Enemy Use:** Allowed
*   **Requirements:** Main Weapon must be a Dagger
*   **Hit Check:** Accuracy vs Evasion (Weapon)
*   **Targeting:** Enemy Unit, Range 4, Single Target, LOS: Yes
*   **Movement Component:** Teleport to rear of target if valid rear position exists. If not valid, teleport to nearest adjacent position.
*   **AoE Shape:** Single
*   **Cost:** 12 Stamina
*   **Cooldown:** 2 turns
*   **Scaling Blocks:**
    *   **Damage Scaling:** DEX (Primary), STR (Secondary minor)
    *   **Effect Scaling:** DEX (Primary)
*   **Effects:**
    1.  **Reposition Self:** Teleport behind target (or nearest adjacent)
    2.  **Deal Damage:** Base_L1 9–12, Type: Physical (Melee)
    3.  **Conditional Bonus Damage:** if successfully positioned behind target, deal additional Base_L1 4–6, Type: Physical
*   **AI Hints:** Damage, Finisher
*   **Notes:**
    *   This is the core “positioning payoff” test case.
    *   Bonus damage is conditional, not a separate status.

### 13. Shadow Throw
*   **ID:** `abilities/action/ranged/shadow_throw`
*   **Category:** Action Ability (Technique)
*   **Context:** Combat Only
*   **Phase:** Action Phase
*   **Tags:** Ranged, Physical, Thrown, Debuff, Stalker
*   **Learn Rules:**
    *   **Default Learners (Starter):** Thief
    *   **Other Player Learners:** Scroll Learnable (Trainer or Scroll)
    *   **Enemy Use:** Allowed
*   **Requirements:** Main Weapon must be a Dagger
*   **Hit Check:** Accuracy vs Evasion (Weapon)
*   **Targeting:** Enemy Unit, Range 8, Single Target, LOS: Yes
*   **AoE Shape:** Single
*   **Cost:** 8 Stamina
*   **Cooldown:** 1 turn
*   **Scaling Blocks:**
    *   **Damage Scaling:** DEX (Primary), WIL (Secondary minor)
    *   **Effect Scaling:** DEX (Primary)
*   **Effects:**
    1.  **Weapon Throw:** 90% weapon damage (converted to Ranged)
    2.  **Apply Status:** `statuses/conditions/blind`, Duration 2 turns
*   **AI Hints:** Debuff
*   **Notes:**
    *   Allows Thief to function at mid-range using Daggers.
    *   Blind is non-stacking, refresh duration on reapply.

### 14. Toxic Blade
*   **ID:** `abilities/action/melee/toxic_blade`
*   **Category:** Action Ability (Technique)
*   **Context:** Combat Only
*   **Phase:** Action Phase
*   **Tags:** Melee, Physical, Poison, DamageOverTime, Corruptor
*   **Learn Rules:**
    *   **Default Learners (Starter):** Thief
    *   **Other Player Learners:** Scroll Learnable (Trainer or Scroll)
    *   **Enemy Use:** Allowed
*   **Requirements:** Main Weapon must be a Dagger
*   **Hit Check:** Accuracy vs Evasion (Weapon)
*   **Targeting:** Enemy Unit, Range: Weapon Range, Single Target, LOS: Yes
*   **AoE Shape:** Single
*   **Cost:** 9 Stamina
*   **Cooldown:** 0 turns
*   **Scaling Blocks:**
    *   **Damage Scaling:** DEX (Primary), WIL (Secondary minor)
    *   **Effect Scaling:** DEX (Primary)
*   **Effects:**
    1.  **Deal Damage:** Base_L1 4–6, Type: Physical (Melee)
    2.  **Deal Damage:** Base_L1 2–3, Type: Poison (instant)
    3.  **Apply Status:** `statuses/conditions/poisoned`, Duration 3 turns
    4.  **Poison Tick (per instance):** Base_L1 4 per turn, Type: Poison, scales with Damage Scaling
*   **AI Hints:** Damage
*   **Notes:**
    *   Initial hit is intentionally lower than Backstab.
    *   Total damage is higher over time if the target survives.

---

## 7. Hero Starter Abilities (v1)

### 15. Cleave
*   **ID:** `abilities/action/melee/cleave`
*   **Category:** Action Ability (Weapon-Based)
*   **Context:** Combat Only
*   **Phase:** Action Phase
*   **Tags:** Melee, Physical, Area, Blademaster
*   **Learn Rules:**
    *   **Default Learners (Starter):** Hero
    *   **Other Player Learners:** Scroll Learnable (Trainer or Scroll)
    *   **Enemy Use:** Allowed
*   **Requirements:** Main Weapon must be melee
*   **Hit Check:** Accuracy vs Evasion (Weapon)
*   **Targeting:** Enemy Unit, Range: Weapon Range, LOS: Yes
*   **AoE Shape:** Cone (origin at caster, facing the targeted enemy)
*   **AoE Size (v1):** Cone 90 degrees, Length 2
*   **Cost:** 10 Stamina
*   **Cooldown:** 1 turn
*   **Scaling Blocks:**
    *   **Damage Scaling:** STR (Primary), DEX (Secondary minor)
    *   **Effect Scaling:** STR (Primary)
*   **Effects:**
    1.  **Weapon Strike:** 85% weapon damage to all enemies in cone
*   **AI Hints:** Damage
*   **Notes:**
    *   Target is used to set facing and cone direction.
    *   This is your primary “weapon AoE” validation ability.

### 16. Radiant Guard
*   **ID:** `abilities/action/support/radiant_guard`
*   **Category:** Action Ability (Spell)
*   **Context:** Combat Only
*   **Phase:** Action Phase
*   **Tags:** Support, Barrier, Heal, Lightbearer
*   **Learn Rules:**
    *   **Default Learners (Starter):** Hero
    *   **Other Player Learners:** Scroll Learnable (Trainer or Scroll)
    *   **Enemy Use:** Allowed
*   **Hit Check:** Auto-Hit (Buff)
*   **Targeting:** Ally Unit (or Self), Range 6, Single Target, LOS: Yes
*   **AoE Shape:** Single
*   **Cost:** 8 Mana
*   **Cooldown:** 3 turns
*   **Scaling Blocks:**
    *   **Damage Scaling:** WIL (Primary), CHA (Secondary minor)
    *   **Effect Scaling:** WIL (Primary)
*   **Effects:**
    1.  **Apply Status:** `statuses/buffs/physical_barrier`, Duration 3 turns
    2.  **Barrier Value:** Base_L1 8–12, absorbs Physical category damage only
    3.  **Heal:** Base_L1 4–6 (instant), Type: Healing
*   **AI Hints:** Buff, Heal
*   **Notes:**
    *   This is intentionally smaller than Magic Shield and only blocks physical.

### 17. Shadow Rend
*   **ID:** `abilities/action/melee/shadow_rend`
*   **Category:** Action Ability (Weapon-Based)
*   **Context:** Combat Only
*   **Phase:** Action Phase
*   **Tags:** Melee, Weapon, TrueDamage, Shadow, Finisher, Dreadbound
*   **Learn Rules:**
    *   **Default Learners (Starter):** Hero
    *   **Other Player Learners:** Scroll Learnable (Trainer or Scroll)
    *   **Enemy Use:** Allowed
*   **Requirements:** Main Weapon must be melee
*   **Hit Check:** Accuracy vs Evasion (Weapon)
*   **Targeting:** Enemy Unit, Range: Weapon Range, Single Target, LOS: Yes
*   **AoE Shape:** Single
*   **Cost:** 10 Stamina
*   **Cooldown:** 3 turns
*   **Scaling Blocks:**
    *   **Damage Scaling:** WIL (Primary), INT (Secondary minor)
    *   **Effect Scaling:** WIL (Primary)
*   **Effects:**
    1.  **Weapon Strike:** 100% weapon damage
    2.  **Deal Damage:** Base_L1 4–6, Type: True (Uses Ability Damage Scaling: WIL)
    3.  **Bonus True Damage:** Base_L1 6–8 if target is below 50% HP (conditional execution)
*   **AI Hints:** Finisher
*   **Notes:**
    *   Hybrid scaling: Weapon Strike uses Weapon Stats (STR/DEX), True Damage uses Ability Stats (WIL).
    *   Supports the "High Risk / Magic Knight" fantasy of the Dreadbound.

---

## 8. Beast Starter Abilities (Shared Library)

### 18. Vicious Bite
*   **ID:** `abilities/action/beast/vicious_bite`
*   **Category:** Action Ability (Beast Strike)
*   **Context:** Combat Only
*   **Phase:** Action Phase
*   **Tags:** Beast, Melee, Physical, Bleed, Strike
*   **Learn Rules:**
    *   **Default Learners (Starter):** Druid (Auto-learned with Wolfkin Form)
    *   **Other Player Learners:** Not learnable in v1
    *   **Enemy Use:** Allowed
*   **Requirements:** None (uses Natural weapon profile)
*   **Hit Check:** Accuracy vs Evasion (Weapon)
*   **Targeting:** Enemy Unit, Range 2.0m, Single Target, LOS: Yes
*   **AoE Shape:** Single
*   **Cost:** 6 Stamina
*   **Cooldown:** 0 turns
*   **Scaling Blocks:**
    *   **Damage Scaling:** DEX (Primary), STR (Secondary minor)
    *   **Effect Scaling:** DEX (Primary)
*   **Effects:**
    1.  **Deal Damage:** Base_L1 5–7, Type: Physical (Melee)
    2.  **Apply Status:** `statuses/conditions/bleeding`, Duration 3 turns
    3.  **Bleeding Tick:** 3 Physical damage per turn (non-stacking), scales with Damage Scaling
*   **AI Hints:** Damage
*   **Notes:**
    *   Shared "beast attack + condition" building block.

### 19. Deep Slash
*   **ID:** `abilities/action/beast/deep_slash`
*   **Category:** Action Ability (Beast Strike)
*   **Context:** Combat Only
*   **Phase:** Action Phase
*   **Tags:** Beast, Melee, Physical, Finisher
*   **Learn Rules:**
    *   **Default Learners (Starter):** Druid (Auto-learned with Wolfkin Form)
    *   **Other Player Learners:** Not learnable in v1
    *   **Enemy Use:** Allowed
*   **Requirements:** None (uses Natural weapon profile)
*   **Hit Check:** Accuracy vs Evasion (Weapon)
*   **Targeting:** Enemy Unit, Range 2.0m, Single Target, LOS: Yes
*   **AoE Shape:** Single
*   **Cost:** 7 Stamina
*   **Cooldown:** 1 turn
*   **Scaling Blocks:**
    *   **Damage Scaling:** DEX (Primary), STR (Secondary minor)
    *   **Effect Scaling:** DEX (Primary)
*   **Effects:**
    1.  **Deal Damage:** Base_L1 4–6, Type: Physical (Melee)
    2.  **Conditional Bonus Damage:** If target has `statuses/conditions/bleeding`, deal additional Base_L1 5–7, Type: Physical
*   **AI Hints:** Damage
*   **Notes:**
    *   Combo payoff for Vicious Bite.

### 20. Pack Howl
*   **ID:** `abilities/action/beast/pack_howl`
*   **Category:** Action Ability (Beast Support)
*   **Context:** Combat Only
*   **Phase:** Action Phase
*   **Tags:** Beast, Shout, Support, Regen
*   **Learn Rules:**
    *   **Default Learners (Starter):** Druid (Auto-learned with Wolfkin Form)
    *   **Other Player Learners:** Not learnable in v1
    *   **Enemy Use:** Allowed
*   **Requirements:** None
*   **Hit Check:** Auto-Hit (Buff)
*   **Targeting:** Self-centered AoE, LOS: No
*   **AoE Shape:** Radius (Sphere/Circle around caster)
*   **AoE Size (v1):** Radius 10.0m
*   **Cost:** 10 Stamina
*   **Cooldown:** 3 turns
*   **Scaling Blocks:**
    *   **Damage Scaling:** None
    *   **Effect Scaling:** WIL (Primary), CHA (Secondary minor)
*   **Effects:**
    1.  **Apply Status:** `statuses/buffs/howl`, Duration 2 turns, to all allies in radius
*   **AI Hints:** Buff
*   **Notes:**
    *   Team aura test usage.

---

## 9. Druid Form Abilities

### 21. Wolfkin Form
*   **ID:** `abilities/utility/forms/wolfkin_form`
*   **Category:** Utility Ability (Form + Mobility)
*   **Context:** Combat Only
*   **Phase:** Movement Phase (does not consume Action)
*   **Tags:** Beast, Form, Mobility, Beastkin
*   **Learn Rules:**
    *   **Default Learners (Starter):** Druid
    *   **Other Player Learners:** Not learnable in v1
    *   **Enemy Use:** Not used by enemies in v1
*   **Hit Check:** Auto-Hit (Movement/Form)
*   **Targeting:** Enemy Unit, Range 12.0m, LOS: Yes
*   **Reposition Component:** Leap to a position behind the target (relative to target facing), landing within 1.5m if space is valid. If not valid, land at nearest valid point within 2.0m of the target.
*   **AoE Shape:** Single
*   **Cost:** 8 Stamina
*   **Cooldown:** 4 turns
*   **Scaling Blocks:**
    *   **Damage Scaling:** None
    *   **Effect Scaling:** DEX (Primary), VIT (Secondary minor)
*   **Effects:**
    1.  **Reposition Self:** Leap behind target (independent of movement radius)
    2.  **Apply Status (Self):** `statuses/forms/wolfkin_form`, Duration 3 turns
    3.  **Grant Beast Kit Access:** Enables Beast ability list toggle while active (Vicious Bite, Deep Slash, Pack Howl)
*   **Notes:**
    *   Casting a non-Beast spell ends form immediately.

### 22. Thorny Root
*   **ID:** `abilities/action/magic/thorny_root`
*   **Category:** Action Ability (Nature Spell)
*   **Context:** Combat Only
*   **Phase:** Action Phase
*   **Tags:** Magic, Nature, Control, DamageOverTime, Stormcaller
*   **Learn Rules:**
    *   **Default Learners (Starter):** Druid
    *   **Other Player Learners:** Scroll Learnable (Trainer or Scroll)
    *   **Enemy Use:** Allowed
*   **Hit Check:** Auto-Hit (Magic Defense applies mitigation)
*   **Targeting:** Enemy Unit, Range 8.0m, Single Target, LOS: Yes
*   **AoE Shape:** Single
*   **Cost:** 8 Mana
*   **Cooldown:** 2 turns
*   **Scaling Blocks:**
    *   **Damage Scaling:** WIL (Primary), INT (Secondary minor)
    *   **Effect Scaling:** WIL (Primary)
*   **Effects:**
    1.  **Apply Status:** `statuses/conditions/rooted`, Duration 3 turns
        *   *Meaning:* Cannot Move, Cannot Jump.
        *   *Tick:* Nature Damage at Start of Turn.
        *   *Stacking:* Non-stacking, refresh duration.
    2.  **Rooted Tick Value:** Base_L1: 5 damage per turn, Type: Nature (Scales with Damage Scaling).
*   **AI Hints:** Control
*   **Notes:**
    *   Primary "single-target lock + attrition" tool.
    *   No immediate damage to keep it clean as a Control/DoT spell.

### 23. Healing Wind
*   **ID:** `abilities/action/support/healing_wind`
*   **Category:** Action Ability (Nature Support)
*   **Context:** Combat Only
*   **Phase:** Action Phase
*   **Tags:** Support, Healing, Nature, HealOverTime, Lifewarden
*   **Learn Rules:**
    *   **Default Learners (Starter):** Druid
    *   **Other Player Learners:** Scroll Learnable (Trainer or Scroll)
    *   **Enemy Use:** Allowed
*   **Hit Check:** Auto-Hit (Buff/Heal)
*   **Targeting:** Ally Unit (or Self), Range 8.0m, Single Target, LOS: Yes
*   **AoE Shape:** Single
*   **Cost:** 10 Mana
*   **Cooldown:** 2 turns
*   **Scaling Blocks:**
    *   **Damage Scaling:** None
    *   **Effect Scaling:** WIL (Primary), CHA (Secondary minor)
*   **Effects:**
    1.  **Heal (Instant):** Base_L1 5–7
    2.  **Apply Status:** `statuses/buffs/regeneration`, Duration 2 turns
        *   *Tick:* Heal at Start of Turn.
        *   *Stacking:* Instance-Stacking (Global rule override if needed, but per doc usually non-stacking unless specified, using doc rule: Instance Stacking for Regen per Section 1.A.2).
    3.  **Regeneration Tick Value:** Base_L1: 7 per turn (Scales with Effect Scaling).
*   **AI Hints:** Heal
*   **Notes:**
    *   HoT total intentionally exceeds upfront heal.

---

## 10. Starter Enemy Abilities (v1)

### 24. Bite
*   **ID:** `abilities/action/melee/bite`
*   **Category:** Action Ability (Natural Strike)
*   **Context:** Combat Only
*   **Phase:** Action Phase
*   **Tags:** Beast, Melee, Physical, Strike
*   **Learn Rules:**
    *   **Default Learners (Starter):** Enemy-only (starter beasts)
    *   **Other Player Learners:** Not scroll-learnable in v1
    *   **Enemy Use:** Allowed
*   **Requirements:** Natural weapon strike source (fangs/claws) recommended but not required
*   **Hit Check:** Accuracy vs Evasion (Weapon)
*   **Targeting:** Enemy Unit, Range 2.0m, Single Target, LOS: Yes
*   **AoE Shape:** Single
*   **Cost:** 4 Stamina
*   **Cooldown:** 0 turns
*   **Scaling Blocks:**
    *   **Damage Scaling:** DEX (Primary), STR (Secondary minor)
    *   **Effect Scaling:** None
*   **Effects:**
    1.  **Deal Damage:** Base_L1 4–6, Type: Physical (Melee)
*   **AI Hints:** Damage
*   **Notes:**
    *   Simple beast strike for Cave Bat and other animal enemies.

### 25. Life Leech
*   **ID:** `abilities/action/magic/life_leech`
*   **Category:** Action Ability (Spell)
*   **Context:** Combat Only
*   **Phase:** Action Phase
*   **Tags:** Magic, Shadow, Drain, Sustain
*   **Learn Rules:**
    *   **Default Learners (Starter):** Enemy-only (Vampire Bat, later undead casters)
    *   **Other Player Learners:** Not scroll-learnable in v1
    *   **Enemy Use:** Allowed
*   **Hit Check:** Auto-Hit (Magic Defense applies mitigation)
*   **Targeting:** Enemy Unit, Range 6.0m, Single Target, LOS: Yes
*   **AoE Shape:** Single
*   **Cost:** 8 Mana
*   **Cooldown:** 2 turns
*   **Scaling Blocks:**
    *   **Damage Scaling:** WIL (Primary), INT (Secondary minor)
    *   **Effect Scaling:** WIL (Primary)
*   **Effects:**
    1.  **Deal Damage:** Base_L1 6–9, Type: Shadow
    2.  **Heal Self:** Heal for 70% of damage dealt (rounded down)
*   **AI Hints:** Damage, Heal
*   **Notes:**
    *   Vampire Bat’s "drain-tank" identity button.
    *   Healing is based on actual damage dealt.

### 26. Dirty Stab
*   **ID:** `abilities/action/melee/dirty_stab`
*   **Category:** Action Ability (Technique)
*   **Context:** Combat Only
*   **Phase:** Action Phase
*   **Tags:** Melee, Physical, Poison, Debuff
*   **Learn Rules:**
    *   **Default Learners (Starter):** Enemy-only (Goblin Scout)
    *   **Other Player Learners:** Not scroll-learnable in v1
    *   **Enemy Use:** Allowed
*   **Requirements:** One-handed melee weapon recommended (dagger/shiv), not required
*   **Hit Check:** Accuracy vs Evasion (Weapon)
*   **Targeting:** Enemy Unit, Range 2.0m, Single Target, LOS: Yes
*   **AoE Shape:** Single
*   **Cost:** 6 Stamina
*   **Cooldown:** 1 turn
*   **Scaling Blocks:**
    *   **Damage Scaling:** DEX (Primary), STR (Secondary minor)
    *   **Effect Scaling:** DEX (Primary)
*   **Effects:**
    1.  **Deal Damage:** Base_L1 3–5, Type: Physical (Melee)
    2.  **Apply Status:** `statuses/conditions/poisoned`, Duration 2 turns
    3.  **Poison Tick:** 3 Poison damage/turn (instance-stacking), scales with Damage Scaling
*   **AI Hints:** Damage, Debuff
*   **Notes:**
    *   Makes the scout feel threatening without complex movement.
    *   **Scaling Notes:** Direct hit inherits Damage Scaling. Poison tick inherits Damage Scaling (coefficient 0.5 implied by lower base).

### 27. Minor Heal
*   **ID:** `abilities/action/support/minor_heal`
*   **Category:** Action Ability (Spell)
*   **Context:** Combat Only
*   **Phase:** Action Phase
*   **Tags:** Support, Healing, Magic
*   **Learn Rules:**
    *   **Default Learners (Starter):** Enemy-only (Goblin Shaman)
    *   **Other Player Learners:** Scroll Learnable (later trainer/scroll)
    *   **Enemy Use:** Allowed
*   **Hit Check:** Auto-Hit (Buff/Heal)
*   **Targeting:** Ally Unit (or Self), Range 8.0m, Single Target, LOS: Yes
*   **AoE Shape:** Single
*   **Cost:** 7 Mana
*   **Cooldown:** 2 turns
*   **Scaling Blocks:**
    *   **Damage Scaling:** None
    *   **Effect Scaling:** WIL (Primary), INT (Secondary minor)
*   **Effects:**
    1.  **Heal (Instant):** Base_L1 8–12
*   **AI Hints:** Heal
*   **Notes:**
    *   Clean support tool for testing ally targeting and healer AI.

### 28. Fire Patch
*   **ID:** `abilities/action/zone/fire_patch`
*   **Category:** Action Ability (Zone Spell)
*   **Context:** Combat Only
*   **Phase:** Action Phase
*   **Tags:** Magic, Fire, Zone, AreaDenial
*   **Learn Rules:**
    *   **Default Learners (Starter):** Enemy-only (Goblin Shaman)
    *   **Other Player Learners:** Scroll Learnable (later)
    *   **Enemy Use:** Allowed
*   **Hit Check:** Auto-Hit (Zone)
*   **Targeting:** Ground Point, Range 7.0m, LOS: Yes
*   **AoE Shape:** Radius zone at target point
*   **AoE Size (v1):** Radius 2.5m
*   **Duration (v1):** 3 turns
*   **Cost:** 10 Mana
*   **Cooldown:** 3 turns
*   **Scaling Blocks:**
    *   **Damage Scaling:** INT (Primary), WIL (Secondary minor)
    *   **Effect Scaling:** INT (Primary)
*   **Effects:**
    1.  **Create Persistent Zone:** Fire Patch, Duration 3 turns
    2.  **Zone Tick (Start of Turn):** units inside take Base_L1 4–6 Fire damage/turn (scales with Damage Scaling)
*   **AI Hints:** Control
*   **Notes:**
    *   Core "persistent zone test" ability.
    *   No automatic Burning unless added later.
    *   **Scaling Notes:** Zone snapshots caster's Damage Scaling at cast time. Tick damage inherits snapshotted scaling.

### 29. Heavy Swing
*   **ID:** `abilities/action/melee/heavy_swing`
*   **Category:** Action Ability (Weapon-Based)
*   **Context:** Combat Only
*   **Phase:** Action Phase
*   **Tags:** Melee, Physical, Strike
*   **Learn Rules:**
    *   **Default Learners (Starter):** Enemy-only (Skeleton Warrior)
    *   **Other Player Learners:** Scroll Learnable (later)
    *   **Enemy Use:** Allowed
*   **Requirements:** Main Weapon must be melee
*   **Hit Check:** Accuracy vs Evasion (Weapon)
*   **Targeting:** Enemy Unit, Range: weapon reach (default 2.0m), Single Target, LOS: Yes
*   **AoE Shape:** Single
*   **Cost:** 7 Stamina
*   **Cooldown:** 1 turn
*   **Scaling Blocks:**
    *   **Damage Scaling:** STR (Primary), DEX (Secondary minor)
    *   **Effect Scaling:** None
*   **Effects:**
    1.  **Weapon Strike:** 125% weapon damage
*   **AI Hints:** Damage
*   **Notes:**
    *   Simple "hard hit" button for tanky melee enemies.
    *   **Scaling Notes:** WeaponStrike uses weapon scaling (not ability Damage Scaling). 125% multiplier applied after weapon-scaled roll.

