# SonderQuest Class: Druid (v1)

## 1. Class Fantasy & Role

The Druid is a versatile nature shaper who can pivot between two distinct combat identities: a spellcasting guardian who locks enemies down and sustains allies, and a feral Wolfkin who skirmishes in melee with stamina-based beast techniques. The Druid’s strength is adaptability, choosing the right mode for the moment.

**Combat Role:** Hybrid Support / Control / Skirmisher

**Level 1 Play Pattern (v1):**
1. Use **Bird Form** for vertical mobility and safe repositioning.
2. Use **Thorny Root** to lock a threat in place and win by attrition.
3. Use **Healing Wind** to stabilize an ally and sustain through regeneration.
4. Use **Wolfkin Form** when you need melee pressure and stamina-based tempo.
5. In Wolfkin mode, apply Bleeding with **Vicious Bite**, cash in with **Deep Slash**, and support the team with **Pack Howl**.
6. Use the Ultimate (**Force of Nature**) to reset the fight state with a nature surge that heals allies and harms enemies, and it ends Wolfkin Form.

### Specialization Themes (Descriptive Only)

#### Lifewarden
* **Fantasy:** Nature healer and protector.
* **Focus:** Healing Wind, regeneration, party stability.
* **Key Elements:** Recovery, sustain, preventing deaths.

#### Stormcaller
* **Fantasy:** Nature control caster binding enemies to the earth.
* **Focus:** Rooted control and attrition.
* **Key Elements:** Lockdowns, spacing, target denial.

#### Beastkin
* **Fantasy:** Shapeshifter who becomes the predator.
* **Focus:** Wolfkin Form, beast combo loop, stamina aura.
* **Key Elements:** Mobility commits, bleed combos, skirmishing.

---

## 2. Resource Pattern

**Druid Loadout (Caster):** Mana-forward  
**Wolfkin Loadout (Beast):** Stamina-forward  
**Additional:** Ultimate Charge

---

## 3. Growth Intent

**Druid Loadout:** WIL primary (nature spell power), INT minor  
**Wolfkin Loadout:** DEX primary (beast strike reliability), STR minor  
**Support Flavor:** CHA minor (aura/healing support scaling where applicable)

---

## 4. Equipment Proficiencies

### Weapons (Allowed Families, Exhaustive)

Druid can use these weapon families in normal form:

* `weapons/families/natural/unarmed`
* `weapons/families/dagger_1h`
* `weapons/families/mace_1h`
* `weapons/families/staff_2h`

While Wolfkin Form is active, the Druid uses a specialized claws weapon:

* `weapons/families/natural/claws`

### Armor (Allowed Categories)

Druid proficiency is Medium, so they may also wear Light.

* Medium
* Light

### Shield

No starter shield in v1.

---

## 5. Starting Kit Summary (Level 1)

### Starting Equipment

**Main Weapon (Canonical Starter):**
* `weapons/mace_1h/mace_bronze`

**Unarmed Fallback (Universal):**
* `weapons/natural/unarmed/unarmed_strike`

**Starter Armor Items (Medium Set):**
* Head: `armor/medium/helmet/leather_cap`
* Torso: `armor/medium/torso/leather_tunic`
* Legs: `armor/medium/legs/leather_boots`

### Starting Abilities (Granted at Level 1)

**Utility Ability (Movement Phase):**
* `abilities/utility/druid/bird_form`

**Action Abilities (Action Phase, Druid Loadout):**
* `abilities/action/magic/thorny_root`
* `abilities/action/support/healing_wind`

**Form Ability (Movement Phase, enables Wolfkin Loadout):**
* `abilities/utility/forms/wolfkin_form`

**Wolfkin Loadout Actions (Auto-learned while Wolfkin Form is active):**
* `abilities/action/beast/vicious_bite`
* `abilities/action/beast/deep_slash`
* `abilities/action/beast/pack_howl`

**Ultimate (Action Phase, consumes Ultimate Charge):**
* `abilities/ultimate/druid/force_of_nature`

---

## 6. Learn Rules (Planning Level)

### Class-Native (Druid)

These are the Druid’s baseline kit in v1:
* `abilities/utility/druid/bird_form`
* `abilities/action/magic/thorny_root`
* `abilities/action/support/healing_wind`
* `abilities/utility/forms/wolfkin_form`
* `abilities/action/beast/vicious_bite` (via form)
* `abilities/action/beast/deep_slash` (via form)
* `abilities/action/beast/pack_howl` (via form)
* `abilities/ultimate/druid/force_of_nature`

### Trainer-Learnable

Trainer-learnable Druid spells and forms will be added later (no additional ability IDs authored in this pass).

### Scroll-Learnable

Druid caster spells can be learned by other classes via scroll rules (as defined in their ability entries):
* `abilities/action/magic/thorny_root`
* `abilities/action/support/healing_wind`

### Enemy-Only

None specific to Druid at this time.

---

## Druid Form and Loadout Rules (v1)

### Two Loadouts

The Druid has two combat loadouts:
* **Druid Loadout:** caster/support actions
* **Wolfkin Loadout:** beast actions

While `statuses/forms/wolfkin_form` is active, the player can toggle between these loadouts to view abilities. Selecting an ability may change form based on the rules below.

### Form Change Rules

* **Casting a Beast Action** while Wolfkin:
  * Wolfkin Form remains active.
  * Wolfkin claws remain equipped.

* **Casting a Druid Action** while Wolfkin:
  * Wolfkin Form ends immediately.
  * The Druid’s prior weapon is restored.
  * The chosen Druid action resolves normally.

* **Casting Druid utility mobility** while Wolfkin (Bird Form):
  * Does the movement/animation.
  * Wolfkin Form remains active.

### Wolfkin Form Refresh

`abilities/utility/forms/wolfkin_form` can be cast while Wolfkin is already active:
* Performs the leap-behind reposition.
* Refreshes the Wolfkin Form duration to 3 turns.
* Keeps Wolfkin claws equipped.

---

## Druid Resource Usage Notes (v1)

* Druid caster actions should feel mana-driven and strategic.
* Wolfkin actions should feel stamina-driven and tempo-based.
* The Ultimate is a “reset and stabilize” moment that ends Wolfkin to reinforce the choice: beast pressure or nature restoration.
