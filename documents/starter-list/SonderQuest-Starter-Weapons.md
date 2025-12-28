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
*   **Notes:** Natural melee strikes, often used by predators.
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
    *   Heavier-feeling impact without adding new systems.

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

---

## 4. Armor Framework v1

Armor in v1 is defined as equipment occupying three specific slots. It provides passive stats (primarily Defense) and visual appearance.

### Slots
1.  **Head:** Helmets, Hoods, Circlets.
2.  **Torso:** Chestplates, Robes, Tunics.
3.  **Legs:** Greaves, Pants, Skirts.

### Categories
*   **Light:** Cloth/Silk. Intended for casters or stealth units. Minimal weight/movement penalties (placeholder).
*   **Medium:** Leather/Chain. Generalist protection. Balanced stats.
*   **Heavy:** Plate/Scale. Frontline protection. High defense, potential movement/initiative penalties (placeholder).

### Equipping Rules
Classes define their **Highest Armor Proficiency**. They can equip that category and anything lighter.
*   **Heavy Classes (Warrior, Hero):** Can equip Heavy, Medium, Light.
*   **Medium Classes (Thief, Druid):** Can equip Medium, Light.
*   **Light Classes (Mage):** Can equip Light only.

### Stat Placeholders (v1)
*   **Defense:** Physical damage reduction.
*   **Magic Defense:** Magical damage reduction.
*   **Weight:** Placeholder for future movement logic.

---

## 5. Armor Families (v1)

Families standardize armor visuals and baseline stat ratios per slot/weight.

### Light Armor Families
**1. Light Head**
*   **ID:** `armor/families/light_head`
*   **Display Name:** Light Headgear
*   **Category:** Light
*   **Slot:** Head
*   **Default Stats:** Low Defense, Moderate Magic Defense.
*   **Notes:** Hoods, hats, bands.

**2. Light Torso**
*   **ID:** `armor/families/light_torso`
*   **Display Name:** Light Body
*   **Category:** Light
*   **Slot:** Torso
*   **Default Stats:** Low Defense, High Magic Defense.
*   **Notes:** Robes, tunics.

**3. Light Legs**
*   **ID:** `armor/families/light_legs`
*   **Display Name:** Light Legwear
*   **Category:** Light
*   **Slot:** Legs
*   **Default Stats:** Low Defense, Moderate Magic Defense.
*   **Notes:** Pants, sandals.

### Medium Armor Families
**4. Medium Head**
*   **ID:** `armor/families/medium_head`
*   **Display Name:** Medium Headgear
*   **Category:** Medium
*   **Slot:** Head
*   **Default Stats:** Medium Defense, Low Magic Defense.
*   **Notes:** Leather caps, chain coifs.

**5. Medium Torso**
*   **ID:** `armor/families/medium_torso`
*   **Display Name:** Medium Body
*   **Category:** Medium
*   **Slot:** Torso
*   **Default Stats:** Medium Defense, Low Magic Defense.
*   **Notes:** Leather jerkins, chainmail.

**6. Medium Legs**
*   **ID:** `armor/families/medium_legs`
*   **Display Name:** Medium Legwear
*   **Category:** Medium
*   **Slot:** Legs
*   **Default Stats:** Medium Defense, Low Magic Defense.
*   **Notes:** Leather boots, chain leggings.

### Heavy Armor Families
**7. Heavy Head**
*   **ID:** `armor/families/heavy_head`
*   **Display Name:** Heavy Headgear
*   **Category:** Heavy
*   **Slot:** Head
*   **Default Stats:** High Defense, No Magic Defense.
*   **Notes:** Full helms, visors.

**8. Heavy Torso**
*   **ID:** `armor/families/heavy_torso`
*   **Display Name:** Heavy Body
*   **Category:** Heavy
*   **Slot:** Torso
*   **Default Stats:** High Defense, No Magic Defense.
*   **Notes:** Plate breastplates.

**9. Heavy Legs**
*   **ID:** `armor/families/heavy_legs`
*   **Display Name:** Heavy Legwear
*   **Category:** Heavy
*   **Slot:** Legs
*   **Default Stats:** High Defense, No Magic Defense.
*   **Notes:** Sabatons, greaves.

---

## 6. Starter Armor Items (v1)

### Heavy Set (Bronze)
**1. Bronze Helmet**
*   **ID:** `armor/heavy/helmet/bronze_helmet`
*   **Display Name:** Bronze Helmet
*   **Family ID:** `armor/families/heavy_head`
*   **Category:** Heavy
*   **Slot:** Head
*   **Tier:** 1
*   **Defense:** 3
*   **Magic Defense:** 0
*   **Stat Bonuses:** None
*   **Passive Effects:** None
*   **Notes:** Basic starter helm for heavy users.

**2. Bronze Breastplate**
*   **ID:** `armor/heavy/torso/bronze_breastplate`
*   **Display Name:** Bronze Breastplate
*   **Family ID:** `armor/families/heavy_torso`
*   **Category:** Heavy
*   **Slot:** Torso
*   **Tier:** 1
*   **Defense:** 6
*   **Magic Defense:** 1
*   **Stat Bonuses:** None
*   **Passive Effects:** None
*   **Notes:** Basic starter plate.

**3. Bronze Greaves**
*   **ID:** `armor/heavy/legs/bronze_greaves`
*   **Display Name:** Bronze Greaves
*   **Family ID:** `armor/families/heavy_legs`
*   **Category:** Heavy
*   **Slot:** Legs
*   **Tier:** 1
*   **Defense:** 4
*   **Magic Defense:** 0
*   **Stat Bonuses:** None
*   **Passive Effects:** None
*   **Notes:** Basic starter leg protection.

### Medium Set (Leather)
**4. Leather Helmet**
*   **ID:** `armor/medium/helmet/leather_cap`
*   **Display Name:** Leather Cap
*   **Family ID:** `armor/families/medium_head`
*   **Category:** Medium
*   **Slot:** Head
*   **Tier:** 1
*   **Defense:** 2
*   **Magic Defense:** 1
*   **Stat Bonuses:** None
*   **Passive Effects:** None
*   **Notes:** Basic starter cap.

**5. Leather Tunic**
*   **ID:** `armor/medium/torso/leather_tunic`
*   **Display Name:** Leather Tunic
*   **Family ID:** `armor/families/medium_torso`
*   **Category:** Medium
*   **Slot:** Torso
*   **Tier:** 1
*   **Defense:** 4
*   **Magic Defense:** 2
*   **Stat Bonuses:** None
*   **Passive Effects:** None
*   **Notes:** Basic starter leather armor.

**6. Leather Boots**
*   **ID:** `armor/medium/legs/leather_boots`
*   **Display Name:** Leather Boots
*   **Family ID:** `armor/families/medium_legs`
*   **Category:** Medium
*   **Slot:** Legs
*   **Tier:** 1
*   **Defense:** 2
*   **Magic Defense:** 1
*   **Stat Bonuses:** None
*   **Passive Effects:** None
*   **Notes:** Basic starter boots.

### Light Set (Cloth)
**7. Cloth Hood**
*   **ID:** `armor/light/helmet/cloth_hood`
*   **Display Name:** Cloth Hood
*   **Family ID:** `armor/families/light_head`
*   **Category:** Light
*   **Slot:** Head
*   **Tier:** 1
*   **Defense:** 1
*   **Magic Defense:** 2
*   **Stat Bonuses:** None
*   **Passive Effects:** None
*   **Notes:** Basic starter hood with minor casting focus.

**8. Cloth Robes**
*   **ID:** `armor/light/torso/cloth_robes`
*   **Display Name:** Cloth Robes
*   **Family ID:** `armor/families/light_torso`
*   **Category:** Light
*   **Slot:** Torso
*   **Tier:** 1
*   **Defense:** 2
*   **Magic Defense:** 4
*   **Stat Bonuses:** None
*   **Passive Effects:** None
*   **Notes:** Basic starter caster robes.

**9. Cloth Pants**
*   **ID:** `armor/light/legs/cloth_pants`
*   **Display Name:** Cloth Pants
*   **Family ID:** `armor/families/light_legs`
*   **Category:** Light
*   **Slot:** Legs
*   **Tier:** 1
*   **Defense:** 1
*   **Magic Defense:** 2
*   **Stat Bonuses:** None
*   **Passive Effects:** None
*   **Notes:** Basic starter pants.

---

## 7. Shields Framework (v1)

Shields are a distinct equipment type using the `ArmorDef` schema.

*   **Slot:** Shield (Off-hand).
*   **Requirement:** Can only be equipped if the Main Weapon is **One-Handed**.
*   **Function:** Provides significant Defense and Magic Defense stats.
*   **Damage:** Shields do **not** have weapon damage tags or scaling profiles in v1. They are defensive tools.

---

## 8. Shield Families (v1)

**1. Standard Shield**
*   **ID:** `shields/families/shield_1h`
*   **Display Name:** Standard Shield
*   **Category:** Shield
*   **Slot:** Shield
*   **Requirement:** One-Handed Main Weapon
*   **Default Stats:** High Defense, Moderate Magic Defense.
*   **Notes:** The baseline family for all heater/round shields in v1.

---

## 9. Starter Shields (v1)

**1. Bronze Shield**
*   **ID:** `shields/shield_1h/bronze_shield`
*   **Display Name:** Bronze Shield
*   **Family ID:** `shields/families/shield_1h`
*   **Category:** Shield
*   **Slot:** Shield
*   **Tier:** 1
*   **Defense:** 4
*   **Magic Defense:** 2
*   **Stat Bonuses:** None
*   **Passive Effects:** None
*   **Notes:** Basic starter shield for Warriors.


## 5. Natural Weapons (v1)

### Wolfkin Claws
*   **Weapon:** `weapons/natural/claws/wolfkin_claws`
*   **Name:** Wolfkin Claws
*   **Family ID:** `weapons/families/natural/claws`
*   **Damage Type Tag (v1):** Melee
*   **Hands:** Natural
*   **Range:** 2.0m
*   **Scaling Profile:** DEX (Primary), STR (Secondary minor)
*   **Base Damage (L1):** 3–5 Physical
*   **On-Hit Extra Effect (v1 test):**
    *   **Deal Damage:** Base_L1 1–2, Type: Nature
    *   **Scaling:** uses the weapon scaling profile (DEX-forward)
*   **Notes:**
    *   Automatically equipped while `statuses/forms/wolfkin_form` is active.
    *   On leaving Wolfkin Form, restore the previously equipped main weapon.
    *   On-hit extra damage triggers on every WeaponStrike (Basic Attack and WeaponStrike effects inside abilities).
    *   Multi-hit abilities trigger on-hit effects once per hit.

### Fangs (Beast - Basic)
*   **Weapon:** `weapons/natural/fangs/fangs`
*   **Name:** Fangs
*   **Family ID:** `weapons/families/natural/fangs`
*   **Damage Type Tag (v1):** Melee
*   **Hands:** Natural
*   **Range:** 2.0m
*   **Scaling Profile:** DEX (Primary), STR (Secondary minor)
*   **Base Damage (L1):** 2–4 Physical
*   **Notes:**
    *   Default natural weapon for basic beast enemies (Cave Bat).
    *   Used with `abilities/action/melee/bite`.

### Fangs (Beast - Sharp)
*   **Weapon:** `weapons/natural/fangs/fangs_sharp`
*   **Name:** Sharp Fangs
*   **Family ID:** `weapons/families/natural/fangs`
*   **Damage Type Tag (v1):** Melee
*   **Hands:** Natural
*   **Range:** 2.0m
*   **Scaling Profile:** DEX (Primary), STR (Secondary minor)
*   **Base Damage (L1):** 3–5 Physical
*   **Notes:**
    *   Enhanced natural weapon for elite beasts (Vampire Bat).
    *   Higher damage than basic fangs.

---

## 6. Enemy Weapons (v1)

These weapons are used by starter enemies defined in `SonderQuest-Enemies-Framework.md`.

### Rusty Shiv
*   **Weapon:** `weapons/daggers/rusty_shiv`
*   **Name:** Rusty Shiv
*   **Family ID:** `weapons/families/dagger_1h`
*   **Damage Type Tag (v1):** Melee
*   **Hands:** One-Handed
*   **Range:** 2.0m
*   **Tier:** 0 (Below starter tier)
*   **Scaling Profile:** DEX (Primary), STR (Secondary minor)
*   **Base Damage (L1):** 2–3 Physical
*   **Notes:**
    *   Goblin Scout weapon.
    *   Low damage, fast.

### Gnarled Staff
*   **Weapon:** `weapons/staves/gnarled_staff`
*   **Name:** Gnarled Staff
*   **Family ID:** `weapons/families/staff_2h`
*   **Damage Type Tag (v1):** Melee
*   **Hands:** Two-Handed
*   **Range:** 2.5m
*   **Tier:** 0 (Below starter tier)
*   **Scaling Profile:** INT (Primary), WIL (Secondary minor)
*   **Base Damage (L1):** 2–4 Physical
*   **Notes:**
    *   Goblin Shaman weapon.
    *   Used for melee fallback; primary use is spell casting.

### Ancient Blade
*   **Weapon:** `weapons/swords/ancient_blade`
*   **Name:** Ancient Blade
*   **Family ID:** `weapons/families/sword_1h`
*   **Damage Type Tag (v1):** Melee
*   **Hands:** One-Handed
*   **Range:** 2.0m
*   **Tier:** 0 (Below starter tier)
*   **Scaling Profile:** STR (Primary), DEX (Secondary minor)
*   **Base Damage (L1):** 3–5 Physical
*   **Notes:**
    *   Skeleton Warrior weapon.
    *   Corroded but still dangerous.
