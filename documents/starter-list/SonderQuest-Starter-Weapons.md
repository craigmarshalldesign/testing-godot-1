# SonderQuest Starter Weapons (v1)

This document defines the initial set of Weapon Families and individual Weapons for SonderQuest v1. It serves as a planning guide for creating `WeaponDef` data assets.

---

## 1. Weapon Strike Source Rules

Basic Attack uses the current strike source: Main Weapon if equipped, else Unarmed, unless a Natural Weapon is assigned. Strike source defines damage range, melee reach or ranged distance, damage category, and damage type tags. Strike source also defines the scaling profile (melee typically STR primary, ranged typically DEX primary, staff typically INT primary). Initiative/accuracy modifiers from the weapon apply to Basic Attack.

---

## 2. Weapon Families (v1)

Weapon Families standardize animations, hand usage, and baseline scaling profiles.

### Natural Families (v1)

**1. Unarmed**
*   **Family:** `weapons/families/natural/unarmed`
*   **Display Name:** Unarmed
*   **Handedness:** Natural (treated as one-handed for animation purposes, but not a main-weapon slot item)
*   **Range Mode:** Melee
*   **Default Melee Reach:** 2.0m
*   **Default Damage Category:** Physical
*   **Default Damage Type Tags:** Melee
*   **Default Scaling Profile:**
    *   **Primary:** STR
    *   **Secondary:** DEX (minor)
*   **Notes:** This is the fallback strike source when nothing else is available.
*   **Default Animation Set:** TBD (unarmed punches/kicks)
*   **Default Strike Behavior:** Single-target weapon strike (used by Basic Attack)
*   **Intended Users:** All units as a fallback
*   **Planning Notes:**
    *   Unarmed is the default strike source if the unit has no Main Weapon and no Natural Weapon assigned.
    *   Unarmed is not an equipment item in a normal loot sense, but it is still a strike profile used for Basic Attack resolution.
    *   If you later add “fist weapons” or “gauntlets,” they should be separate families and not reuse this one.

**2. Fangs**
*   **Family:** `weapons/families/natural/fangs`
*   **Display Name:** Fangs
*   **Handedness:** Natural (treated as one-handed for animation purposes, but not a main-weapon slot item)
*   **Range Mode:** Melee
*   **Default Melee Reach:** 2.0m
*   **Default Damage Category:** Physical
*   **Default Damage Type Tags:** Melee
*   **Default Scaling Profile:**
    *   **Primary:** DEX
    *   **Secondary:** STR (minor)
*   **Notes:** Fast, precise natural strikes.
*   **Default Animation Set:** TBD (bite attack set)
*   **Default Strike Behavior:** Single-target weapon strike (used by Basic Attack and beast bite-style abilities)
*   **Intended Users:** Beast enemies, shapeshift forms, special units with bite attacks
*   **Planning Notes:**
    *   Fangs are typically assigned as a Natural Weapon strike source for beasts (example: bats).
    *   Individual fang weapons (like fangs vs fangs_sharp) will live under weapons/natural/fangs/... and reference this family.
    *   If an ability specifies “uses natural weapon profile,” it should use the currently assigned Natural Weapon, which can be a fangs weapon.

**3. Claws**
*   **Family:** `weapons/families/natural/claws`
*   **Display Name:** Claws
*   **Handedness:** Natural (treated as one-handed for animation purposes, but not a main-weapon slot item)
*   **Range Mode:** Melee
*   **Default Melee Reach:** 2.0m
*   **Default Damage Category:** Physical
*   **Default Damage Type Tags:** Melee
*   **Default Scaling Profile:**
    *   **Primary:** DEX
    *   **Secondary:** STR (minor)
*   **Notes:** Natural slashing strikes, often used by predators.
*   **Default Animation Set:** TBD (claw swipe set)
*   **Default Strike Behavior:** Single-target weapon strike (used by Basic Attack and claw-based abilities)
*   **Intended Users:** Beast enemies, shapeshift forms, special units with claw attacks
*   **Planning Notes:**
    *   Claws are assigned as a Natural Weapon strike source similarly to fangs.
    *   If later you want claw attacks to feel different than fangs beyond tags (example: wider arcs), that should be implemented as abilities or animation differences, not a new damage system.
    *   Claws are a good default natural family for wolf or cat-type enemies and for potential future Beastkin variations.

### Melee Families

**4. Dagger (1H)**
*   **Family:** `weapons/families/dagger_1h`
*   **Display Name:** One-Handed Dagger
*   **Handedness:** One-handed
*   **Range Mode:** Melee
*   **Default Melee Reach:** 2.0m
*   **Default Damage Category:** Physical
*   **Default Damage Type Tags:** Melee
*   **Default Scaling Profile:**
    *   **Primary:** DEX
    *   **Secondary:** STR (minor)
*   **Notes:** Daggers are precision weapons with strong DEX identity.
*   **Default Animation Set:** TBD (dagger 1h set)
*   **Default Strike Behavior:** Single-target weapon strike (used by Basic Attack and dagger techniques)
*   **Intended Users:** Thief (all trees), some goblins, light humanoids
*   **Planning Notes:**
    *   Stalker is dagger-based in v1. Mid-range pressure comes from abilities, not a thrown weapon family.
    *   Daggers should generally have higher accuracy and higher initiative feel than swords, but exact numbers are item-level or family defaults later.

**5. Sword (1H)**
*   **Family:** `weapons/families/sword_1h`
*   **Display Name:** One-Handed Sword
*   **Handedness:** One-handed
*   **Range Mode:** Melee
*   **Default Melee Reach:** 2.2m
*   **Default Damage Category:** Physical
*   **Default Damage Type Tags:** Melee
*   **Default Scaling Profile:**
    *   **Primary:** STR
    *   **Secondary:** DEX (minor)
*   **Notes:** Flexible melee baseline for most humanoids.
*   **Default Animation Set:** TBD (sword 1h set)
*   **Default Strike Behavior:** Single-target weapon strike (used by Basic Attack and sword techniques)
*   **Intended Users:** Hero, Warrior, many humanoid enemies
*   **Planning Notes:**
    *   One-handed swords are the core “standard melee” family and should be the reference point for early balancing.
    *   Compatible with shields since it is one-handed.

**6. Sword (2H)**
*   **Family:** `weapons/families/sword_2h`
*   **Display Name:** Two-Handed Sword
*   **Handedness:** Two-handed
*   **Range Mode:** Melee
*   **Default Melee Reach:** 2.6m
*   **Default Damage Category:** Physical
*   **Default Damage Type Tags:** Melee
*   **Default Scaling Profile:**
    *   **Primary:** STR
    *   **Secondary:** VIT (minor)
*   **Notes:** Heavy weapons reward STR and suit durable frontliners.
*   **Default Animation Set:** TBD (sword 2h set)
*   **Default Strike Behavior:** Single-target weapon strike with heavier cadence (used by Basic Attack and heavy swings)
*   **Intended Users:** Warrior, heavier enemies such as skeletons
*   **Planning Notes:**
    *   Two-handed swords cannot be used with shields.
    *   This family is used for Greatswords and “Ancient Blade” style weapons.
    *   If you later add wide arc basic attacks for 2h, that should be an ability behavior, not the weapon family.

**7. Mace (1H)**
*   **Family:** `weapons/families/mace_1h`
*   **Display Name:** One-Handed Mace
*   **Handedness:** One-handed
*   **Range Mode:** Melee
*   **Default Melee Reach:** 2.1m
*   **Default Damage Category:** Physical
*   **Default Damage Type Tag:** Crush
*   **Default Scaling Profile:**
    *   **Primary:** STR
    *   **Secondary:** VIT (minor)
*   **Default Animation Set:** TBD (mace 1h set)
*   **Default Strike Behavior:** Single-target weapon strike (used by Basic Attack and blunt techniques)
*   **Intended Users:** Warrior, heavy humanoid enemies
*   **Planning Notes:**
    *   Maces are the baseline “impact” family and use the Crush tag as their single weapon damage type.
    *   Compatible with shields since it is one-handed.

**8. Axe (1H)**
*   **Family:** `weapons/families/axe_1h`
*   **Display Name:** One-Handed Axe
*   **Handedness:** One-handed
*   **Range Mode:** Melee
*   **Default Melee Reach:** 2.2m
*   **Default Damage Category:** Physical
*   **Default Damage Type Tag:** Melee
*   **Default Scaling Profile:**
    *   **Primary:** STR
    *   **Secondary:** DEX (minor)
*   **Default Animation Set:** TBD (axe 1h set)
*   **Default Strike Behavior:** Single-target weapon strike (used by Basic Attack and cleaving techniques)
*   **Intended Users:** Warrior, aggressive humanoid enemies
*   **Planning Notes:**
    *   Axes are a slightly heavier-feeling one-handed melee option without introducing additional weapon tag complexity.
    *   Compatible with shields since it is one-handed.

### Caster Families

**9. Staff (2H)**
*   **Family:** `weapons/families/staff_2h`
*   **Display Name:** Two-Handed Staff
*   **Handedness:** Two-handed
*   **Range Mode:** Melee
*   **Default Melee Reach:** 2.4m
*   **Default Damage Category:** Physical
*   **Default Damage Type Tag:** Crush
*   **Default Scaling Profile:**
    *   **Primary:** INT
    *   **Secondary:** WIL (minor)
*   **Default Animation Set:** TBD (staff 2h set)
*   **Default Strike Behavior:** Single-target weapon strike (used by Basic Attack when a staff is equipped)
*   **Intended Users:** Mage, caster enemies (example: Goblin Shaman)
*   **Planning Notes:**
    *   Staves are primarily a caster weapon identity but still resolve Basic Attack as a physical strike in v1.
    *   Any spell power is from abilities, not the staff’s damage type tag.

### Ranged Families
*Note: Thief uses Thrown Daggers via abilities, not a ranged weapon slot in v1.*

**10. Bow (2H)**
*   **Family:** `weapons/families/bow_2h`
*   **Display Name:** Two-Handed Bow
*   **Handedness:** Two-handed
*   **Range Mode:** Ranged
*   **Default Ranged Distance:** 12.0m
*   **Default Damage Category:** Physical
*   **Default Damage Type Tag:** Ranged
*   **Default Scaling Profile:**
    *   **Primary:** DEX
    *   **Secondary:** STR (minor)
*   **Default Animation Set:** TBD (bow 2h set)
*   **Default Strike Behavior:** Single-target ranged weapon strike (used by Basic Attack when a bow is equipped)
*   **Intended Users:** Enemy ranged units (player bows are not a v1 focus)
*   **Planning Notes:**
    *   Bows are included mainly for early enemy variety and future expansion.
    *   Since the player Thief is dagger-based, keep bow weapon content minimal in the starter set.

---

## 3. Starter Weapons (v1)

Individual weapon items players and enemies can equip.

### Swords & Blades

**1. Bronze Sword**
*   **Weapon:** `weapons/sword_1h/sword_bronze`
*   **Name:** Bronze Sword
*   **Family:** `weapons/families/sword_1h`
*   **Handedness:** One-handed
*   **Damage Range (v1):** 4–7
*   **Damage Category:** Physical
*   **Damage Type Tags:** Melee
*   **Range:** Melee reach 2.2m
*   **Scaling Profile:** STR (Primary), DEX (Secondary minor)
*   **Initiative Modifier:** 0
*   **Accuracy Modifier:** 0
*   **Requirements:** None
*   **Notes:**
    *   Baseline starter sword for early humanoid units.

**2. Bronze Greatsword**
*   **Weapon:** `weapons/sword_2h/greatsword_bronze`
*   **Name:** Bronze Greatsword
*   **Family:** `weapons/families/sword_2h`
*   **Handedness:** Two-handed
*   **Damage Range (v1):** 6–10
*   **Damage Category:** Physical
*   **Damage Type Tags:** Melee
*   **Range:** Melee reach 2.6m
*   **Scaling Profile:** STR (Primary), VIT (Secondary minor)
*   **Initiative Modifier:** -1
*   **Accuracy Modifier:** -2
*   **Requirements:** None
*   **Notes:**
    *   Slower, heavier baseline for two-handed sword testing.

**3. Ancient Blade**
*   **Weapon:** `weapons/sword_2h/ancient_blade`
*   **Name:** Ancient Blade
*   **Family:** `weapons/families/sword_2h`
*   **Handedness:** Two-handed
*   **Damage Range (v1):** 7–12
*   **Damage Category:** Physical
*   **Damage Type Tags:** Melee
*   **Range:** Melee reach 2.6m
*   **Scaling Profile:** STR (Primary), VIT (Secondary minor)
*   **Initiative Modifier:** -1
*   **Accuracy Modifier:** -1
*   **Requirements:** None
*   **Notes:**
    *   Used by Skeleton Warrior.
    *   Tagged with Crush to support heavier-feeling impact without adding new systems.

### Daggers

**4. Bronze Dagger**
*   **Weapon:** `weapons/dagger_1h/dagger_bronze`
*   **Name:** Bronze Dagger
*   **Family:** `weapons/families/dagger_1h`
*   **Handedness:** One-handed
*   **Damage Range (v1):** 3–5
*   **Damage Category:** Physical
*   **Damage Type Tags:** Melee
*   **Range:** Melee reach 2.0m
*   **Scaling Profile:** DEX (Primary), STR (Secondary minor)
*   **Initiative Modifier:** +1
*   **Accuracy Modifier:** +2
*   **Requirements:** None
*   **Notes:**
    *   Baseline dagger for Thief and light enemies.

**5. Rusty Shiv**
*   **Weapon:** `weapons/dagger_1h/rusty_shiv`
*   **Name:** Rusty Shiv
*   **Family:** `weapons/families/dagger_1h`
*   **Handedness:** One-handed
*   **Damage Range (v1):** 2–4
*   **Damage Category:** Physical
*   **Damage Type Tags:** Melee
*   **Range:** Melee reach 2.0m
*   **Scaling Profile:** DEX (Primary), STR (Secondary minor)
*   **Initiative Modifier:** +1
*   **Accuracy Modifier:** 0
*   **Requirements:** None
*   **Notes:**
    *   Used by Goblin Scout.

### Axes & Maces

**6. Bronze Mace**
*   **Weapon:** `weapons/mace_1h/mace_bronze`
*   **Name:** Bronze Mace
*   **Family:** `weapons/families/mace_1h`
*   **Handedness:** One-handed
*   **Damage Range (v1):** 5–8
*   **Damage Category:** Physical
*   **Damage Type Tags:** Crush
*   **Range:** Melee reach 2.1m
*   **Scaling Profile:** STR (Primary), VIT (Secondary minor)
*   **Initiative Modifier:** -1
*   **Accuracy Modifier:** 0
*   **Requirements:** None
*   **Notes:**
    *   Alternative starter for Warrior focusing on impact.

**7. Bronze Axe**
*   **Weapon:** `weapons/axe_1h/axe_bronze`
*   **Name:** Bronze Axe
*   **Family:** `weapons/families/axe_1h`
*   **Handedness:** One-handed
*   **Damage Range (v1):** 5–8
*   **Damage Category:** Physical
*   **Damage Type Tags:** Melee
*   **Range:** Melee reach 2.2m
*   **Scaling Profile:** STR (Primary), DEX (Secondary minor)
*   **Initiative Modifier:** 0
*   **Accuracy Modifier:** -1
*   **Requirements:** None
*   **Notes:**
    *   Alternative starter for Warrior focusing on aggressive styling.

### Staves

**8. Oak Staff**
*   **Weapon:** `weapons/staff_2h/oak_staff`
*   **Name:** Oak Staff
*   **Family:** `weapons/families/staff_2h`
*   **Handedness:** Two-handed
*   **Damage Range (v1):** 3–6
*   **Damage Category:** Physical
*   **Damage Type Tag:** Crush
*   **Range:** Melee reach 2.4m
*   **Scaling Profile:** INT (Primary), WIL (Secondary minor)
*   **Initiative Modifier:** 0
*   **Accuracy Modifier:** 0
*   **Requirements:** None
*   **Notes:**
    *   Simple starter staff for player casters.

**9. Gnarled Staff**
*   **Weapon:** `weapons/staff_2h/gnarled_staff`
*   **Name:** Gnarled Staff
*   **Family:** `weapons/families/staff_2h`
*   **Handedness:** Two-handed
*   **Damage Range (v1):** 4–7
*   **Damage Category:** Physical
*   **Damage Type Tag:** Crush
*   **Range:** Melee reach 2.4m
*   **Scaling Profile:** INT (Primary), WIL (Secondary minor)
*   **Initiative Modifier:** 0
*   **Accuracy Modifier:** -1
*   **Requirements:** None
*   **Notes:**
    *   Used by Goblin Shaman.
    *   Slightly stronger than Oak Staff, with a small accuracy drawback to keep it feeling crude.

### Bows

**10. Crude Shortbow**
*   **Weapon:** `weapons/bow_2h/crude_shortbow`
*   **Name:** Crude Shortbow
*   **Family:** `weapons/families/bow_2h`
*   **Handedness:** Two-handed
*   **Damage Range (v1):** 3–5
*   **Damage Category:** Physical
*   **Damage Type Tag:** Ranged
*   **Range:** 12.0m
*   **Scaling Profile:** DEX (Primary), STR (Secondary minor)
*   **Initiative Modifier:** +1
*   **Accuracy Modifier:** 0
*   **Requirements:** None
*   **Notes:**
    *   Minimal bow option intended mainly for early enemy ranged units.

### Natural Weapons

**11. Unarmed Strike**
*   **Weapon:** `weapons/natural/unarmed/unarmed_strike`
*   **Name:** Unarmed Strike
*   **Family:** `weapons/families/natural/unarmed`
*   **Handedness:** Natural (non-slot strike source)
*   **Damage Range (v1):** 1–2
*   **Damage Category:** Physical
*   **Damage Type Tags:** Melee
*   **Range:** Melee reach 2.0m
*   **Scaling Profile:** STR (Primary), DEX (Secondary minor)
*   **Initiative Modifier:** 0
*   **Accuracy Modifier:** 0
*   **Requirements:** None
*   **Intended Use:** Global fallback strike source for Basic Attack
*   **Notes:**
    *   Used automatically when a unit has no equipped Main Weapon and no assigned Natural Weapon.
    *   Not intended to be looted or equipped as an item in v1.

**12. Fangs**
*   **Weapon:** `weapons/natural/fangs/fangs`
*   **Name:** Fangs
*   **Family:** `weapons/families/natural/fangs`
*   **Handedness:** Natural (non-slot strike source)
*   **Damage Range (v1):** 2–4
*   **Damage Category:** Physical
*   **Damage Type Tags:** Melee
*   **Range:** Melee reach 2.0m
*   **Scaling Profile:** DEX (Primary), STR (Secondary minor)
*   **Initiative Modifier:** +1
*   **Accuracy Modifier:** +5
*   **Requirements:** None
*   **Intended Use:** Small beast bite strike source
*   **Notes:**
    *   Assigned to early beasts such as Cave Bat.
    *   Keeps damage low but accuracy high to reinforce “harasser” identity.

**13. Sharp Fangs**
*   **Weapon:** `weapons/natural/fangs/fangs_sharp`
*   **Name:** Sharp Fangs
*   **Family:** `weapons/families/natural/fangs`
*   **Handedness:** Natural (non-slot strike source)
*   **Damage Range (v1):** 3–5
*   **Damage Category:** Physical
*   **Damage Type Tags:** Melee
*   **Range:** Melee reach 2.0m
*   **Scaling Profile:** DEX (Primary), STR (Secondary minor)
*   **Initiative Modifier:** +1
*   **Accuracy Modifier:** +5
*   **Requirements:** None
*   **Intended Use:** Upgraded bite strike source for tougher beasts
*   **Notes:**
    *   Assigned to Vampire Bat.
    *   Slightly higher damage than base fangs to support drain-tank behavior.

**14. Claws**
*   **Weapon:** `weapons/natural/claws/claws`
*   **Name:** Claws
*   **Family:** `weapons/families/natural/claws`
*   **Handedness:** Natural (non-slot strike source)
*   **Damage Range (v1):** 2–5
*   **Damage Category:** Physical
*   **Damage Type Tags:** Melee
*   **Range:** Melee reach 2.0m
*   **Scaling Profile:** DEX (Primary), STR (Secondary minor)
*   **Initiative Modifier:** 0
*   **Accuracy Modifier:** 0
*   **Requirements:** None
*   **Intended Use:** General claw swipe strike source for beasts
*   **Notes:**
    *   Placeholder natural weapon for claw-based enemies and potential future Beastkin variants.
    *   If later you want claw attacks to have a wider hit shape, do that via abilities, not the weapon entry.
