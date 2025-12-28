# SonderQuest Class: Warrior (v1)

## 1. Class Fantasy & Role

The Warrior is the durable frontliner: an armored enforcer who wins fights by controlling space, denying movement, and surviving long enough to finish the job.

**Combat Role:** Tank / Bruiser / Control

**Level 1 Play Pattern (v1):**
1. Use **Charge** to engage, break traversal blockers, and set positioning.
2. Use **Taunting Shout** to force attention and protect the backline.
3. Use **Ground Stomp** to lock enemies in place.
4. Use **Rage Strike** to burst down a priority target once movement is denied.

### Specialization Themes (Descriptive Only)

#### Berserker
* **Fantasy:** Blood-fueled destroyer trading safety for power.
* **Focus:** Burst melee, self-damage, stamina-heavy offense.
* **Key Elements:** Risk vs reward, aggressive single-target pressure.

#### Warden
* **Fantasy:** Armored enforcer controlling the battlefield.
* **Focus:** Zone control, grounding/knockdown style effects, durability.
* **Key Elements:** Movement denial, frontline stability.

#### Commander
* **Fantasy:** Battlefield leader shaping the fight with presence and shouts.
* **Focus:** Taunts, buffs/debuffs, team enabling.
* **Key Elements:** CHA-driven presence effects, enemy manipulation.

---

## 2. Resource Pattern

**Primary:** Stamina  
**Secondary:** Ultimate Charge  
**Mana:** Not a baseline Warrior focus in v1 (may appear later via cross-learns)

---

## 3. Growth Intent

**Primary Stats:** STR, VIT  
**Secondary Stats:** DEX (accuracy, initiative), CHA (presence tools, ultimate charge rate)

---

## 4. Equipment Proficiencies

### Weapons (Allowed Families, Exhaustive)

Warrior can equip any weapon family except bows in v1.

* `weapons/families/dagger_1h` (backup blade)
* `weapons/families/sword_1h` (versatile one-hand)
* `weapons/families/sword_2h` (heavy two-hand)
* `weapons/families/mace_1h` (impact/control leaning)
* `weapons/families/axe_1h` (aggressive one-hand)
* `weapons/families/staff_2h` (allowed but unconventional)
* `weapons/families/natural/unarmed` (universal fallback)

**Not Allowed:**
* `weapons/families/bow_2h`

### Armor (Allowed Categories)

Warrior proficiency is Heavy, so they may also wear Medium and Light.

* Heavy
* Medium
* Light

### Shield

Shields are allowed when a one-handed weapon is equipped.

---

## 5. Starting Kit Summary (Level 1)

### Starting Equipment

**Main Weapon (Canonical Starter):**
* `weapons/axe_1h/axe_bronze`

**Shield (Canonical Starter):**
* `shields/shield_1h/bronze_shield`

**Unarmed Fallback (Universal):**
* `weapons/natural/unarmed/unarmed_strike`

**Armor Families (Expected):**
* `armor/families/heavy_head`
* `armor/families/heavy_torso`
* `armor/families/heavy_legs`

**Starter Armor Items:**
* Head: `armor/heavy/helmet/bronze_helmet`
* Torso: `armor/heavy/torso/bronze_breastplate`
* Legs: `armor/heavy/legs/bronze_greaves`

### Starting Abilities (Granted at Level 1)

**Utility Ability (Movement Phase):**
* `abilities/utility/warrior/charge`

**Action Abilities (Action Phase):**
* `abilities/action/melee/rage_strike`
* `abilities/action/melee/ground_stomp`
* `abilities/action/buff/taunting_shout`

**Ultimate (Action Phase, consumes Ultimate Charge):**
* `abilities/ultimate/warrior/seismic_cleave`

---

## 6. Learn Rules (Planning Level)

### Class-Native (Warrior)

These are the Warrior’s baseline kit in v1:
* `abilities/utility/warrior/charge`
* `abilities/action/melee/rage_strike`
* `abilities/action/melee/ground_stomp`
* `abilities/action/buff/taunting_shout`
* `abilities/ultimate/warrior/seismic_cleave`

### Trainer-Learnable

Trainer-learnable Warrior techniques and shouts will be added later (no additional ability IDs authored in this pass).

### Scroll-Learnable

Scroll-learnable “universal weapon techniques” may be added later (no additional ability IDs authored in this pass).

### Enemy-Only

None specific to Warrior at this time.

---

## Warrior Resource Usage Notes (v1)

* The Warrior’s Level 1 action kit is intentionally **stamina-heavy**, reinforcing VIT and stamina regen value.
* Presence tools (like Taunting Shout) are expected to be the main place CHA matters early.
* The Ultimate is a high-impact control moment that converts built-up Ultimate Charge into a decisive lockdown play.
