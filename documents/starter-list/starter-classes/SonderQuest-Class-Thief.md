# SonderQuest Class: Thief (v1)

## 1. Class Fantasy & Role

The Thief is a dagger specialist who wins fights through positioning, burst windows, and lethal attrition. The kit is built around committing safely when you can, and staying evasive when you cannot.

**Combat Role:** Assassin / Skirmisher / Debuffer

**Level 1 Play Pattern (v1):**
1. Use **Shadow Slide** during Movement Phase to secure a good angle and safe distance.
2. Use **Backstab** when you can commit for burst damage.
3. Use **Toxic Blade** to apply poison pressure and finish durable targets over time.
4. Use **Shadow Throw** when you need ranged safety or to finish a low-health target.
5. Use **Shadowstep Barrage** as the Ultimate to wipe clustered enemies or delete a lone priority target.

### Specialization Themes (Descriptive Only)

#### Assassin
* **Fantasy:** Precision killer who deletes priority targets.
* **Focus:** Burst, single-target execution, positioning.
* **Key Elements:** Engagement timing, lethal windows.

#### Venomblade
* **Fantasy:** Poison specialist who wins by attrition and debilitation.
* **Focus:** Poison application, sustained pressure.
* **Key Elements:** DoT stacking, target cycling.

#### Shadowdancer
* **Fantasy:** Mobile skirmisher vanishing through the fight.
* **Focus:** Mobility, ranged poke, safe commits.
* **Key Elements:** Repositioning, threat management.

---

## 2. Resource Pattern

**Primary:** Stamina  
**Secondary:** Ultimate Charge  
**Mana:** Not a baseline Thief focus in v1

---

## 3. Growth Intent

**Primary Stats:** DEX  
**Secondary Stats:** STR (weapon throughput), optional INT later for shadow-themed talents

---

## 4. Equipment Proficiencies

### Weapons (Allowed Families, Exhaustive)

Thief is dagger-only in v1, with universal unarmed fallback.

* `weapons/families/dagger_1h`
* `weapons/families/natural/unarmed`

### Armor (Allowed Categories)

Thief proficiency is Medium, so they may also wear Light.

* Medium
* Light

### Shield

No shield usage in v1.

---

## 5. Starting Kit Summary (Level 1)

### Starting Equipment

**Main Weapon (Canonical Starter):**
* `weapons/dagger_1h/dagger_bronze`

**Unarmed Fallback (Universal):**
* `weapons/natural/unarmed/unarmed_strike`

**Armor Families (Expected):**
* `armor/families/medium_head`
* `armor/families/medium_torso`
* `armor/families/medium_legs`

**Starter Armor Items:**
* Head: `armor/medium/helmet/leather_cap`
* Torso: `armor/medium/torso/leather_tunic`
* Legs: `armor/medium/legs/leather_boots`

### Starting Abilities (Granted at Level 1)

**Utility Ability (Movement Phase):**
* `abilities/utility/thief/shadow_slide`

**Action Abilities (Action Phase):**
* `abilities/action/melee/backstab`
* `abilities/action/ranged/shadow_throw`
* `abilities/action/melee/toxic_blade`

**Ultimate (Action Phase, consumes Ultimate Charge):**
* `abilities/ultimate/thief/shadowstep_barrage`

---

## 6. Learn Rules (Planning Level)

### Class-Native (Thief)

These are the Thief’s baseline kit in v1:
* `abilities/utility/thief/shadow_slide`
* `abilities/action/melee/backstab`
* `abilities/action/ranged/shadow_throw`
* `abilities/action/melee/toxic_blade`
* `abilities/ultimate/thief/shadowstep_barrage`

### Trainer-Learnable

Trainer-learnable thief techniques will be added later (no additional ability IDs authored in this pass).

### Scroll-Learnable

Scroll-learnable “universal dagger techniques” may be added later (no additional ability IDs authored in this pass).

### Enemy-Only

None specific to Thief at this time.

---

## Thief Resource Usage Notes (v1)

* Thief actions should feel stamina-driven and tempo-focused.
* The class is intentionally constrained to daggers for clear identity and animation simplicity.
* The ultimate is a high-mobility finisher that scales both physical dagger throughput and arcane-shadow flavor without requiring new status rules.
