# SonderQuest Class: Hero (v1)

## 1. Class Fantasy & Role

The Hero is the game’s baseline frontline hybrid: a reliable greatsword fighter who can protect allies with Radiant power and finish enemies with Shadow power. The Hero’s kit is intentionally conflicted, mixing support and brutality in the same loadout to reflect being pulled between worlds.

**Combat Role:** Frontliner / Hybrid / Protector / Finisher

**Level 1 Play Pattern (v1):**
1. Use **Dash** during Movement Phase to engage, line up cone angles, or reach a threatened ally.
2. Use **Cleave** to control tempo against multiple enemies.
3. Use **Radiant Guard** to prevent a death and stabilize the party.
4. Use **Shadow Rend** to push through defenses and execute weakened targets.
5. Use **Oathsplitter Verdict** as the Ultimate to deliver a decisive, morally conflicted strike that mixes Shadow and Radiant power.

### Specialization Themes (Descriptive Only)

#### Blademaster
* **Fantasy:** Reliable weapon expert who wins by fundamentals.
* **Focus:** Weapon throughput, cleave patterns, tempo control.
* **Key Elements:** Consistency, positioning, multi-target pressure.

#### Lightbearer
* **Fantasy:** Protector who shields and heals allies through Radiant power.
* **Focus:** Barriers, emergency healing, preventing permadeath moments.
* **Key Elements:** Defensive timing, ally targeting, survivability.

#### Dreadbound
* **Fantasy:** Magic knight channeling Shadow to end fights quickly.
* **Focus:** Finisher tools, hybrid damage sources, execution windows.
* **Key Elements:** Risk and commitment, decisive closing plays.

---

## 2. Resource Pattern

**Primary:** Stamina (weapon techniques)  
**Secondary:** Mana (Radiant support tools)  
**Additional:** Ultimate Charge (signature hybrid strike)

---

## 3. Growth Intent

**Primary Stats:** STR, WIL  
**Secondary Stats:** VIT (frontline), DEX (reliability), CHA (support flavor later)

---

## 4. Equipment Proficiencies

### Weapons (Allowed Families, Exhaustive)

Hero is a melee generalist with a greatsword starter and broad weapon flexibility.

* `weapons/families/natural/unarmed`
* `weapons/families/dagger_1h`
* `weapons/families/sword_1h`
* `weapons/families/sword_2h`

### Armor (Allowed Categories)

Hero is allowed to equip all armor categories in v1.

* Heavy
* Medium
* Light

### Shield

No starter shield in v1. Shield usage depends on later itemization and one-handed weapon choices.

---

## 5. Starting Kit Summary (Level 1)

### Starting Equipment

**Main Weapon (Canonical Starter):**
* `weapons/sword_2h/greatsword_bronze`

**Unarmed Fallback (Universal):**
* `weapons/natural/unarmed/unarmed_strike`

**Starter Armor Items (Heavy Set):**
* Head: `armor/heavy/helmet/bronze_helmet`
* Torso: `armor/heavy/torso/bronze_breastplate`
* Legs: `armor/heavy/legs/bronze_greaves`

### Starting Abilities (Granted at Level 1)

**Utility Ability (Movement Phase):**
* `abilities/utility/hero/dash`

**Action Abilities (Action Phase):**
* `abilities/action/melee/cleave`
* `abilities/action/support/radiant_guard`
* `abilities/action/melee/shadow_rend`

**Ultimate (Action Phase, consumes Ultimate Charge):**
* `abilities/ultimate/hero/oathsplitter_verdict`

---

## 6. Learn Rules (Planning Level)

### Class-Native (Hero)

These are the Hero’s baseline kit in v1:
* `abilities/utility/hero/dash`
* `abilities/action/melee/cleave`
* `abilities/action/support/radiant_guard`
* `abilities/action/melee/shadow_rend`
* `abilities/ultimate/hero/oathsplitter_verdict`

### Trainer-Learnable

Hero trainer techniques and support options will be added later (no additional ability IDs authored in this pass).

### Scroll-Learnable

Hero starter abilities that are broadly usable by other classes via scroll rules (as defined in their ability entries):
* `abilities/action/melee/cleave`
* `abilities/action/support/radiant_guard`
* `abilities/action/melee/shadow_rend`

### Enemy-Only

None specific to Hero at this time.

---

## Hero Resource Usage Notes (v1)

* The Hero deliberately uses both Stamina and Mana to feel like a complete protagonist kit.
* Cleave validates weapon-based AoE and facing.
* Radiant Guard is the “prevent a death” button and anchors the protective identity.
* Shadow Rend provides reliable progress via hybrid weapon + true damage.
* The Ultimate unifies the class theme by mixing Shadow harm, Radiant judgment, and self-sustain in a single decisive action.
