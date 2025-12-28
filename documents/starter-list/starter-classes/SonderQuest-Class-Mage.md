# SonderQuest Class: Mage (v1)

## 1. Class Fantasy & Role

The Mage is a ranged spellcaster who wins fights through elemental pressure, setup states, and protective wards. At Level 1 the Mage teaches core status rules (Burning and Wet) and has a simple defensive button to stabilize risky turns.

**Combat Role:** Ranged Damage / Setup / Support

**Level 1 Play Pattern (v1):**
1. Use **Teleport** during Movement Phase to maintain spacing and line-of-sight.
2. Use **Drench** to apply Wet and set up party follow-ups.
3. Use **Firebolt** to apply Burning pressure when you want damage over time.
4. Use **Magic Shield** to prevent deaths and keep casting online.
5. Use **Arcane Sigil** as the Ultimate to shape space and punish enemies who stand their ground.

### Specialization Themes (Descriptive Only)

#### Pyromancer
* **Fantasy:** Firestarter who overwhelms with damage over time.
* **Focus:** Burning application, Fire damage, pressure.
* **Key Elements:** DoT stacking, targeting priorities, attrition wins.

#### Cryomancer
* **Fantasy:** Cold mage who controls space and slows enemies.
* **Focus:** Wet setup leading into ice control later.
* **Key Elements:** Movement reduction play, setup and conversion rules.

#### Conjuror
* **Fantasy:** Ward-maker and battlefield shaper.
* **Focus:** Barriers, zones, and utility spellcraft.
* **Key Elements:** Defensive planning, area denial, resource efficiency.

---

## 2. Resource Pattern

**Primary:** Mana  
**Secondary:** Ultimate Charge  
**Stamina:** Exists for baseline movement and basic actions, not a Mage focus in v1

---

## 3. Growth Intent

**Primary Stats:** INT, WIL  
**Secondary Stats:** DEX (initiative, reliability)

---

## 4. Equipment Proficiencies

### Weapons (Allowed Families, Exhaustive)

* `weapons/families/staff_2h`
* `weapons/families/dagger_1h`
* `weapons/families/sword_1h`
* `weapons/families/natural/unarmed`

### Armor (Allowed Categories)

Mage proficiency is Light only.

* Light

### Shield

No shield usage in v1.

---

## 5. Starting Kit Summary (Level 1)

### Starting Equipment

**Main Weapon (Canonical Starter):**
* `weapons/staff_2h/oak_staff`

**Armor Families (Expected):**
* `armor/families/light_head`
* `armor/families/light_torso`
* `armor/families/light_legs`

**Starter Armor Items:**
* Head: `armor/light/helmet/cloth_hood`
* Torso: `armor/light/torso/cloth_robes`
* Legs: `armor/light/legs/cloth_pants`

### Starting Abilities (Granted at Level 1)

**Utility Ability (Movement Phase):**
* `abilities/utility/mage/teleport`

**Action Abilities (Action Phase):**
* `abilities/action/magic/firebolt`
* `abilities/action/magic/drench`
* `abilities/action/magic/magic_shield`

**Ultimate (Action Phase, consumes Ultimate Charge):**
* `abilities/ultimate/mage/arcane_sigil`

---

## 6. Learn Rules (Planning Level)

### Class-Native (Mage)

These are the Mage’s baseline kit in v1:
* `abilities/utility/mage/teleport`
* `abilities/action/magic/firebolt`
* `abilities/action/magic/drench`
* `abilities/action/magic/magic_shield`
* `abilities/ultimate/mage/arcane_sigil`

### Trainer-Learnable

Mage trainer spells will be added later (no additional ability IDs authored in this pass).

### Scroll-Learnable

The Mage starter spells are broadly usable by other classes via scroll rules (as defined in the ability entries):
* `abilities/action/magic/firebolt`
* `abilities/action/magic/drench`
* `abilities/action/magic/magic_shield`

### Enemy-Only

None specific to Mage at this time.

---

## Mage Resource Usage Notes (v1)

* Mage gameplay should be obviously **mana-driven**, with WIL and mana regen feeling valuable early.
* Drench is the primary setup button at Level 1 and should clearly demonstrate Wet rules.
* Magic Shield is the Mage’s “keep someone alive” tool and anchors the support identity without adding complexity.
* Arcane Sigil is a neutral ultimate that rewards positioning and punishes enemies who do not move.
