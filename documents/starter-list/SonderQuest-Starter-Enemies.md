# SonderQuest Starter Enemies (v1)

This document defines the **v1 Starter Enemy Roster** for playtesting and greybox implementation.

All enemies here are **Level 1** and based on the `SonderQuest-Enemies-Framework.md` roster. They use the same **Movement Phase → Action Phase** turn structure as player units.

---

## 0. Shared Combat Notes (v1)

* AI always performs movement first, then exactly one action.  
* No post-action repositioning exists in v1 ("hit and run" behavior is not permitted).  
* All damage and healing values shown are **Level 1 Base_L1 values** before mitigation or resistances.  
* Each enemy's "Resolved Stats" are calculated from the Layer stacks in **Appendix A** using the rules in **Appendix B**.

---

## 1. Cave Bat

**Unit ID:** `units/enemies/cave_bat`  
**Role:** fragile flyer, evasive melee  
**Level:** 1

### 1.1 Layer Stack
1. `layers/species/beast`  
2. `layers/species/beast/bat`  
3. `layers/species/beast/bat/cave`

### 1.2 Weapon
* `weapons/natural/fangs/fangs`  
  *Damage Range (L1): 2–4 Physical*

### 1.3 Abilities
* `abilities/action/melee/bite`

### 1.4 AI Profile
`ai/behaviors/simple_aggressive`  
* Moves to nearest reachable enemy within movement radius, attacks with Bite if in range.*

### 1.5 Resolved Stats (L1)
|Stat|Value|
|:--|:--|
|STR|6|
|DEX|10|
|INT|3|
|WIL|4|
|VIT|6|
|CHA|4|
|HP|12|
|Move Radius|8 m|
|Accuracy|65|
|Evasion|40|
|Phys Def|2|
|Mag Def|1|

### 1.6 Damage / Healing Expectations (L1)
*Basic Attack:* 2–4 Physical  
*Bite:* 4–6 Physical  

---

## 2. Vampire Bat

**Unit ID:** `units/enemies/vampire_bat`  
**Role:** evasive drain attacker  
**Level:** 1

### 2.1 Layer Stack
1. `layers/species/beast`  
2. `layers/species/beast/bat`  
3. `layers/species/beast/bat/vampire`

### 2.2 Weapon
* `weapons/natural/fangs/fangs_sharp`  *Damage Range (L1): 3–5 Physical*

### 2.3 Abilities
* `abilities/action/melee/bite`  
* `abilities/action/magic/life_leech`

### 2.4 AI Profile
`ai/behaviors/flanker`  
* Moves to side/back if possible, prioritizes Life Leech when injured.*

### 2.5 Resolved Stats (L1)
|Stat|Value|
|:--|:--|
|STR|7|
|DEX|9|
|INT|4|
|WIL|6|
|VIT|8|
|CHA|5|
|HP|16|
|Move Radius|8 m|
|Accuracy|68|
|Evasion|35|
|Phys Def|3|
|Mag Def|3|

### 2.6 Damage / Healing Expectations (L1)
*Basic Attack:* 3–5 Physical  
*Bite:* 4–6 Physical  
*Life Leech:* 6–9 Shadow damage + self-heal ≈ 4–6  

---

## 3. Goblin Scout

**Unit ID:** `units/enemies/goblin_scout`  
**Role:** agile melee striker  
**Level:** 1

### 3.1 Layer Stack
1. `layers/species/humanoid`  
2. `layers/species/humanoid/goblin`  
3. `layers/species/humanoid/goblin/scout`

### 3.2 Weapon
* `weapons/dagger_1h/rusty_shiv`  *Damage Range (L1): 2–4 Physical*

### 3.3 Abilities
* `abilities/action/melee/dirty_stab`

### 3.4 AI Profile
`ai/behaviors/hit_and_run` (phase-legal interpretation)  
* Moves to side arc if possible, uses Dirty Stab once in range, then holds position.*

### 3.5 Resolved Stats (L1)
|Stat|Value|
|:--|:--|
|STR|6|
|DEX|9|
|INT|4|
|WIL|4|
|VIT|7|
|CHA|5|
|HP|15|
|Move Radius|7 m|
|Accuracy|70|
|Evasion|35|
|Phys Def|3|
|Mag Def|2|

### 3.6 Damage / Healing Expectations (L1)
*Basic Attack:* 2–4 Physical  
*Dirty Stab:* 3–5 Physical + Poison (3 per turn × 2 turns = 6 total)  

---

## 4. Goblin Shaman

**Unit ID:** `units/enemies/goblin_shaman`  
**Role:** ranged caster support  
**Level:** 1

### 4.1 Layer Stack
1. `layers/species/humanoid`  
2. `layers/species/humanoid/goblin`  
3. `layers/species/humanoid/goblin/shaman`

### 4.2 Weapon
* `weapons/staff_2h/gnarled_staff`  *Damage Range (L1): 4–7 Physical (Crush)*

### 4.3 Abilities
* `abilities/action/magic/firebolt`  
* `abilities/action/support/minor_heal`  
* `abilities/action/zone/fire_patch`

### 4.4 AI Profile
`ai/behaviors/caster_support`  
* Maintains 7–8 m distance for Firebolt, casts Minor Heal on low HP ally, positions Fire Patch for area denial.*

### 4.5 Resolved Stats (L1)
|Stat|Value|
|:--|:--|
|STR|5|
|DEX|6|
|INT|9|
|WIL|8|
|VIT|6|
|CHA|5|
|HP|14|
|Move Radius|6 m|
|Accuracy|65|
|Evasion|25|
|Phys Def|2|
|Mag Def|4|

### 4.6 Damage / Healing Expectations (L1)
*Firebolt:* 6–8 Fire + Burn (4 × 3 turns = 12) → ≈ 18–20 total  
*Minor Heal:* 8–12 instant  
*Fire Patch:* 4–6 per turn × 3 turns → 12–18 total  

---

## 5. Skeleton Warrior

**Unit ID:** `units/enemies/skeleton_warrior`  
**Role:** tank frontliner  
**Level:** 1

### 5.1 Layer Stack
1. `layers/species/undead`  
2. `layers/species/undead/skeleton`  
3. `layers/species/undead/skeleton/warrior`

### 5.2 Weapon
* `weapons/sword_2h/ancient_blade`  *Damage Range (L1): 7–12 Physical*

### 5.3 Abilities
* `abilities/action/melee/heavy_swing`

### 5.4 AI Profile
`ai/behaviors/tank`  
* Moves to block paths and reach melee range, uses Heavy Swing when in range.*

### 5.5 Resolved Stats (L1)
|Stat|Value|
|:--|:--|
|STR|10|
|DEX|6|
|INT|3|
|WIL|5|
|VIT|10|
|CHA|3|
|HP|20|
|Move Radius|5 m|
|Accuracy|65|
|Evasion|15|
|Phys Def|5|
|Mag Def|2|

### 5.6 Damage / Healing Expectations (L1)
*Basic Attack:* 7–12 Physical  
*Heavy Swing:* 8–15 Physical (125% weapon multiplier)  

---

# Appendix A — Enemy Stat Layers (v1 numeric)

|Layer ID|Δ STR|Δ DEX|Δ INT|Δ WIL|Δ VIT|Δ CHA|Δ HP|Δ Move|Δ Acc|Δ Eva|Δ PDef|Δ MDef|
|:--|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
|layers/species/beast| 0| +1| -1| -1| +0| -1| 0| 0| 0| 0| 0| 0|
|layers/species/beast/bat| -1| +2| 0| 0| -1| 0| 0| +1| 0| +5| 0| 0|
|layers/species/beast/bat/cave| +0| +1| 0| 0| +1| 0| +2| 0| 0| +3| +1| 0|
|layers/species/beast/bat/vampire| +1| 0| +1| +2| +2| +1| +4| 0| +3| 0| +1| +1|
|layers/species/humanoid| 0| 0| 0| 0| 0| 0| 0| 0| 0| 0| 0| 0|
|layers/species/humanoid/goblin| 0| +1| 0| 0| -1| 0| 0| 0| +2| +2| 0| 0|
|layers/species/humanoid/goblin/scout| 0| +2| 0| 0| +1| +1| +3| 0| +3| +3| +1| 0|
|layers/species/humanoid/goblin/shaman| -1| 0| +3| +3| 0| 0| +2| 0| 0| 0| 0| +2|
|layers/species/undead| +0| 0| -1| 0| +2| -1| +4| -1| 0| -2| +1| 0|
|layers/species/undead/skeleton| +2| 0| 0| 0| +1| 0| +2| 0| +2| -1| +1| 0|
|layers/species/undead/skeleton/warrior| +2| 0| 0| 0| +1| 0| +2| 0| +1| 0| +1| 0|

---

# Appendix B — Derived Stat Formulas (v1)

> **Note:** These formulas are for documentation purposes. The authoritative formulas should be verified against `SonderQuest-Implementation-Architecture-Plan.md`.

```
MaxHP = 10 + VIT × 1.0 + Σ (Δ HP)
MaxMana = 10 + WIL × 1.0
MaxStamina = 10 + VIT × 0.5
MoveRadius = 5 + Σ (Δ Move)
Accuracy = 60 + (DEX × 0.5) + Σ (Δ Acc)
Evasion = 20 + (DEX × 0.5) + Σ (Δ Eva)
Phys Def = 1 + (VIT × 0.2) + Σ (Δ PDef)
Mag Def = 1 + (WIL × 0.2) + Σ (Δ MDef)
```

---

# Appendix C — Implementation Checklist

- [ ] EnemyDef resources for each entry  
- [ ] StatLayerDef resources for each layer listed above  
- [ ] Weapons and Abilities already exist in starter docs  
- [ ] AI profiles updated to Movement → Action phase logic  
- [ ] Resolved stats match tables here at Level 1  
- [ ] Spawn encounters use only these five enemies for v1 playtests  

---

*End of SonderQuest Starter Enemies (v1)*
