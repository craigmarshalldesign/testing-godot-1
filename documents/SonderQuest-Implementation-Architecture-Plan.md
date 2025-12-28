# SonderQuest Implementation Architecture Plan (v1)

## 1. Title and Goals

**Title:** SonderQuest Implementation Architecture Plan (v1)

**Goals:**
*   Establish a data-driven architecture using Godot Resources for all gameplay content.
*   Implement a robust Stat Resolution pipeline supporting layered stacking (Species -> Variant -> Class).
*   Create a generic Ability Runner to handle both player and enemy actions uniformly.
*   Enforce a strict "No Hardcoding" policy for content; all stats, effects, and cooldowns must be data-defined.
*   Support spatial tactical combat with precise Targeting and AoE logic.
*   Implement the v1 shared resource model (Mana/Stamina/Ultimate) and visible Regen stats.
*   Ensure save/load compatibility using a stable String ID registry.

**Non-Goals:**
*   Talent Trees or complex node-based progression (v2).
*   Chain-based or purely procedural AoE shapes.
*   Advanced AI Planners (GOAP/HTN); use a weighted reactive system for v1.
*   Co-op Networking or multiplayer synchronization.
*   Inventory tetris or complex crafting.
*   Dynamic faction diplomacy.

---

## 2. Data Folder Structure and ID Mapping

All gameplay data resides in `res://data/`. The system uses **String IDs** matching the folder path (snake_case) to reference Resources at runtime/save.

**Folder Schema:**

| Folder Path | ID Prefix | Resource Type |
| :--- | :--- | :--- |
| `res://data/abilities/` | `abilities/` | `AbilityDef` |
| `res://data/weapons/` | `weapons/` | `WeaponDef` |
| `res://data/armor/` | `armor/` | `ArmorDef` |
| `res://data/shields/` | `shields/` | `ArmorDef` |
| `res://data/layers/` | `layers/` | `StatLayerDef` |
| `res://data/units/` | `units/` | `UnitArchetypeDef` |
| `res://data/statuses/` | `statuses/` | `StatusDef` |
| `res://data/ai/` | `ai/` | `AIProfileDef` |
| `res://data/config/` | `config/` | `ProgressionDef` |

**ID Examples:**
*   `abilities/action/magic/firebolt`
*   `abilities/action/melee/cleave`
*   `abilities/utility/warrior/charge`
*   `abilities/utility/mage/teleport`
*   `abilities/action/melee/shadow_rend`
*   `abilities/action/beast/vicious_bite`
*   `weapons/families/sword_1h`
*   `weapons/sword_1h/sword_bronze`
*   `weapons/natural/fangs/fangs`
*   `layers/species/beast`
*   `layers/classes/mage`
*   `units/enemies/cave_bat`
*   `units/enemies/goblin_scout`
*   `statuses/conditions/burning`
*   `statuses/conditions/taunted`
*   `ai/behaviors/aggressive_melee`

**Constraint:** Action abilities should use functional categories (`magic`, `melee`, `support`). Utility abilities generally use class folders (`utility/mage`, `utility/warrior`) or functional folders (`utility/mobility`) depending on implementation preference, but Starter List currently uses functional subfolders for Action and Class folders for Utility.

---

## 3. Resource Schemas (Godot Resources)

These definitions map directly to `Resource` scripts in Godot.

### A. AbilityDef
*   **Purpose:** Defines a distinct action usable by any unit.
*   **Validations:** Must have at least one effect. IDs must be unique.
*   **Fields:**
    *   `id`: String (Required, unique)
    *   `display_name`: String (Required)
    *   `category`: Enum (Action, Utility) (Required)
    *   `description`: String (Optional)
    *   `icon`: Texture2D (Optional)
    *   `cost_mana`: Int (Optional)
    *   `cost_stamina`: Int (Optional)
    *   `cooldown_turns`: Int (Default 0)
    *   `targeting`: `AbilityTargetingDef` (Required)
    *   `effects`: Array[`EffectDef`] (Required, ordered)
    *   `scaling_damage`: `ScalingBlock` (Primary/Secondary stats + weights)
    *   `scaling_effect`: `ScalingBlock`
    *   `ai_hints`: `AIAbilityHint` (Usage tags)
    *   `requirements`: Array[`UseRequirement`] (WeaponType, Stance)

> **Note:** `scaling_level_growth` is deliberately removed. In v1, the runtime does NOT evaluate `scaling_damage` or `scaling_effect`. These fields remain only for metadata, UI, or future extension.

### B. AbilityTargetingDef
*   **Purpose:** Nested resource defining selection logic.
*   **Fields:**
    *   `mode`: Enum (Self, Unit, Point, Direction)
    *   `shape`: Enum (Single, Circle, Cone, Line)
    *   `range_type`: Enum (Weapon, Custom)
    *   `range_value`: Float (Used if Custom)
    *   `radius`: Float (For Circle/Cone)
    *   `angle`: Float (For Cone)
    *   `width`: Float (For Line)
    *   `requires_los`: Bool (Default True)
    *   `can_target_allies`: Bool
    *   `can_target_enemies`: Bool
    *   `can_target_objects`: Bool

### C. EffectDef
*   **Purpose:** Atomic logic step in an ability.
*   **Base Class:** `EffectDef` (Abstract)
*   **Subtypes:**
    *   `EffectWeaponStrike`: uses equipped weapon stats.
    *   `EffectDealDamage`: `base_min_l1`, `base_max_l1`, `power_attribute_weights` (Dictionary).
    *   `EffectHeal`: `base_min_l1`, `base_max_l1`, `power_attribute_weights`.
    *   `EffectApplyStatus`: `status_id`, `duration_min`, `duration_max`.
    *   `EffectModifyStat`: `stat_id`, `amount`, `duration`.
    *   `EffectMove`: `type` (Push, Pull, Dash, Teleport), `distance`.
    *   `EffectSpawnZone`: `zone_def`, `duration`.
    *   `EffectEnvironment`: `tag` (Smash, Interact).

> **Numeric Scaling Logic:** For `DealDamage` and `Heal` (Spells/Monster Moves), the runner calculates: `(Base_L1 * PowerCurve(lvl)) + (Attributes * Weights)`.
> **Status Logic:** Status effects (stun, root, silence) do NOT scale in potency or duration based on level in v1. Damage-over-time scales via its own tick effects.

### D. WeaponDef & WeaponFamilyDef
*   **WeaponFamilyDef:**
    *   `id`: String
    *   `scaling_primary`: Enum (Attribute)
    *   `scaling_secondary`: Enum (Attribute)
    *   `anim_set_ref`: String
*   **WeaponDef:**
    *   `id`: String
    *   `family`: `WeaponFamilyDef` reference
    *   `tier`: Int
    *   `damage_min`: Int
    *   `damage_max`: Int
    *   `damage_category`: Enum (Physical, Magical)
    *   `damage_type`: Enum (Melee, Ranged, Crush, etc.)
    *   `range_override`: Float (Optional)
    *   `initiative_mod`: Int
    *   `accuracy_mod`: Float
    *   `on_hit_effects`: Array[`EffectDef`]

### K. ArmorDef & ArmorFamilyDef
*   **ArmorFamilyDef:**
    *   `id`: String
    *   `slot`: Enum (Head, Torso, Legs, Shield)
    *   `category`: Enum (Light, Medium, Heavy, Shield)
    *   `anim_set_ref`: String
*   **ArmorDef:**
    *   `id`: String
    *   `family`: `ArmorFamilyDef` reference
    *   `display_name`: String
    *   `tier`: Int
    *   `defense`: Int (Physical Mitigation)
    *   `magic_defense`: Int (Magical Mitigation)
    *   `stat_bonuses`: Dictionary (AttributeID -> Value) (e.g. {STR: 1})
    *   `passive_effects`: Array[`EffectDef`]
    *   `weight_class`: Enum (Light, Medium, Heavy)

### E. StatusDef
*   **Purpose:** Temporary conditions.
*   **Fields:**
    *   `id`: String
    *   `is_debuff`: Bool
    *   `resistance_stat`: Enum (WIL, VIT, etc.)
    *   `break_check_chance`: Float (Base chance to remove per turn)
    *   `on_apply_effects`: Array[`EffectDef`]
    *   `on_tick_effects`: Array[`EffectDef`] (Applied Start of Turn)
    *   `stat_modifiers`: Dictionary (StatID -> value)

### F. ZoneDef
*   **Purpose:** Persistent AoE.
*   **Fields:**
    *   `shape`: (Circle, Line, etc.)
    *   `size`: Float
    *   `tick_timing`: Enum (OnEntry, EndTurn, StartCasterTurn)
    *   `is_attached`: Bool
    *   `effects`: Array[`EffectDef`]

### G. StatLayerDef
*   **Purpose:** Composable stat blocks (Species, Class, Variants).
*   **Constraint:** StatLayers are data-only. They must not contain scripts, signals, or logic.
*   **Fields:**
    *   `id`: String
    *   `display_name`: String
    *   `add_attributes`: Dictionary (STR: 2, INT: 1...)
    *   `add_baseline_stats`: Dictionary (MaxHP: 10, MaxMana: 5...)
    *   `add_resistances`: Dictionary (Fire: 0.10...)
    *   `movement_tags`: Array[String] (Fly, Swim)
    *   `trait_abilities`: Array[`AbilityDef`] (Racial skills)

### H. UnitArchetypeDef
*   **Purpose:** The blueprint for a sponable unit.
*   **Fields:**
    *   `id`: String
    *   `layer_stack`: Array[`StatLayerDef`] (Ordered: Species -> Variant -> Class)
    *   `base_level`: Int
    *   `default_weapon`: `WeaponDef` (Optional)
    *   `ability_kit`: Array[`AbilityDef`]
    *   `ai_profile`: `AIProfileDef`

### I. UnitOverridesDef
*   **Purpose:** Scene-specific tuning.
*   **Fields:**
    *   `level_override`: Int (Optional)
    *   `bonus_stats`: Dictionary (Additive)
    *   `add_abilities`: Array[`AbilityDef`]
    *   `remove_abilities`: Array[String] (IDs)

### J. AIProfileDef & AIAbilityHint
*   **AIProfileDef:**
    *   `aggression`: Float
    *   `retreat_threshold`: Float (HP %)
    *   `bias_tags`: Dictionary (Tag -> Weight)
*   **AIAbilityHint (Struct within Ability):**
    *   `role_tags`: Array[Enum] (Damage, Heal, Control)
    *   `priority_weight`: Int
    *   `condition`: Enum (None, LowHP, HasStatus)

### K. ProgressionDef
*   **Purpose:** Global logic settings.
*   **Fields:**
    *   `level_cap`: Int (40)
    *   `power_curve`: Curve (Normalized 0..1)
    *   `xp_curve`: Curve
    *   `hp_per_vit`: Float
    *   `mana_per_int`: Float
    *   `stamina_per_vit`: Float
    *   `mana_regen_base`: Float
    *   `stamina_regen_base`: Float
    *   `mana_regen_per_wil`: Float
    *   `stamina_regen_per_vit`: Float

> **Curve Normalization:** Input `t` for curves is calculated as `t = (level - 1) / (level_cap - 1)`.

---

## 4. Runtime Classes and Responsibilities

*   `GameDB` (Autoload)
    *   Scans `res://data/` on startup.
    *   Maps String IDs -> Resource.
    *   `get_ability(id)`, `get_unit(id)`, etc.
*   `UnitInstance` (Node/Ref)
    *   Holds runtime state: `current_hp`, `current_mana`, `current_stamina`, `current_ultimate`.
    *   Holds references: `archetype`, `weapon_instance`.
    *   Manages `active_effects` (statuses).
    *   Exposes `resolved_stats` (computed by StatResolver).
*   `StatResolver` (Library Class)
    *   Static function: `resolve(archetype, overrides, specific_level) -> ResolvedStats`.
    *   Applies layers + curve multipliers + attribute derivations.
*   `AbilityRunner` / `EffectRunner` (Node)
    *   Manages the execution queue of effects.
    *   Context object: `caster`, `target`, `source_ability`, `position`.
*   `CombatState` (Manager Node)
    *   Maintains Initative Queue.
    *   Tracks Turn Phases (Movement vs Action).
    *   Manages List of Active Zones.
*   `AIController` (Node)
    *   Evaluates available abilities against context.
    *   Selects best candidate based on Weighted Random of valid options.

---

## 5. Stat Resolution Pipeline

> **Unified Pipeline:** This logic applies identically to Players (`Hero`) and Enemies (`UnitInstance`). Players are simply Units that obtain layers from Character Creation rather than specific Archetype definitions.

The `StatResolver` performs these steps in order:

1.  **Baseline Accumulation:**
    *   Iterate `UnitArchetype.layer_stack` (or Player's layer stack).
    *   Sum `add_attributes` (STR, INT...) into `RawAttributes`.
    *   Sum `add_baseline_stats` (MaxHP, MaxMana...) into `RawBaselines`.
    *   Sum `add_resistances` into `RawResists`.
2.  **Override Application:**
    *   Apply `UnitOverridesDef` additively to Raw maps.
3.  **Curve Scaling:**
    *   Get global `power_multiplier` from `ProgressionDef.power_curve` at `CurrentLevel`.
    *   `ScaledBaselines = RawBaselines * power_multiplier`.
4.  **Attribute Derivation:**
    *   `DerivedHP = ScaledBaselines.HP + (RawAttributes.VIT * HP_PER_VIT)`.
    *   `DerivedMana = ScaledBaselines.Mana + (RawAttributes.INT * MANA_PER_INT)`.
    *   `DerivedStamina = ScaledBaselines.Stamina + (RawAttributes.VIT * STAM_PER_VIT)`.
    *   `DerivedManaRegen = ManaRegenBase + (RawAttributes.WIL * MANA_REGEN_PER_WIL)`.
    *   `DerivedStaminaRegen = StaminaRegenBase + (RawAttributes.VIT * STAMINA_REGEN_PER_VIT)`.
    *   **Substats:** Derived stats like Accuracy/Crit are calculated here.
    *   **Defense:** Base mitigation from Layers/Attributes is summed with **Armor** (Head/Torso/Legs) and **Shield** stats.
5.  **Equipment & Buffs (Runtime Only):**
    *   Add weapon/gear bonuses to final values.
    *   Apply Status Effect modifiers.

> **Validation:** Editor previews run steps 1-4 and result in READ-ONLY values. They are never saved.

---

## 6. Ability Execution Flow
1.  **Selection:** Player clicks Ability.
2.  **Phase Check:**
    *   If `Utility`: Must be Movement Phase.
    *   If `Action`: Must be Action Phase.
3.  **Cost Validation:** Check `current_mana >= cost`.
4.  **Targeting:**
    *   Spawn Preview (Range/Shape).
    *   Player confirms selection (Unit/Point).
    *   Validate Range/LOS.
5.  **Commit:**
    *   Deduct Resources.
    *   Start Cooldown.
    *   End Phase (if Action).
6.  **Resolution (EffectRunner):**
    *   Iterate `effects` list.
    *   **Weapon Strike:** Use equipped weapon damage + scaling.
    *   **Numeric Effect:** `(BaseL1 * Curve(Lvl)) + (Attributes * Weights)`.
    *   **Mitigate:**
        *   If `Category == True`: Skip def.
        *   Else: `Value *= (100 / (100 + TargetDef))`.
    *   **Resist:**
        *   If `Category == True`: Skip resist.
        *   Else: `Value *= (1 - TargetResist)`. (Negative resist increases damage).

---

## 7. Validation Rules

*   **Error:** Missing ID in any Def or ID containing class names in restricted folders.
*   **Error:** AbilityTargetingDef shape missing required parameters (eg Circle missing radius, Cone missing angle, Line missing width).
*   **Error:** UnitOverridesDef attempts forbidden changes (eg modifying layer_stack or other non-overrideable fields).
*   **Error:** EffectDealDamage missing damage category or damage type.
*   **Error:** WeaponDef missing scaling profile.
*   **Error:** UnitArchetype referencing non-existent Layer ID or empty layer stack.
*   **Error:** Circular dependency in Layers (though unlikely with stack list).
*   **Error:** Class starting gear includes Shield but no One-Handed Weapon.
*   **Error:** Class references undefined armor categories (e.g., "Plate" instead of "Heavy").
*   **Warning:** Missing Icon for visible element.
*   **Warning:** Unit without a default weapon (will fallback to Unarmed).

---

## 8. Save/Load Model

Save files store **Identifiers**, not objects.

**Unit Entry (JSON):**
```json
{
  "instance_id": "u_001",
  "archetype_id": "units/enemies/cave_bat",
  "position": {"x": 10, "y": 0, "z": 5},
  "current_stats": {
    "hp": 45,
    "mana": 10,
    "stamina": 20
  },
  "cooldowns": {
    "abilities/action/control/sonic_screech": 2
  },
  "statuses": [
    {"id": "statuses/conditions/burn", "rem_turns": 1, "source": "u_player_mage"}
  ]
}
```

---

## 9. Example: Vampire Bat

**Data Setup:**
1.  **Layer 1:** `layers/species/beast` (+2 STR, +2 VIT, Tag: Wild).
2.  **Layer 2:** `layers/species/beast/bat` (+4 DEX, Ability: `dash_fly`, Tag: Fly).
3.  **Layer 3:** `layers/species/beast/bat/vampire` (+2 INT, Ability: `life_leech`, Resist: Light -25%).
4.  **Archetype:** `units/enemies/beast/bat/vampire_bat`
    *   Stack: [Beast, Bat, Vampire]
    *   Base Level: 5
    *   Weapon: `weapons/natural/fangs` (Dagger family, Bleed proc).
5.  **Scene Usage:**
    *   Placed in Level 1 Dungeon.
    *   Override: `unit_overrides/elite` (+2 Level, Add Ability: `group_screech`).

**Resolution (Level 7):**
*   Base Stats from Layers summed.
*   Scaled by `power_curve(0.175)` (approx level 7/40).
*   Final Stats: High DEX (Evasion), Weakness to Light, Has Flight, Lifesteal bite.

---

## 10. Implementation Checklist

1.  **Define Core Resources:** Create `AbilityDef`, `EffectDef`, `StatLayerDef`, `UnitArchetypeDef`, `WeaponDef` scripts.
2.  **Build GameDB:** Implement singleton to load/index `res://data/` on start.
3.  **Implement StatResolver:** Write the pure logic class to sum layers and apply curves.
4.  **Editor Preview:** Create a simple tool script or InspectorPlugin to show "Resolved Stats" on a Unit node.
5.  **Implement EffectRunner:** Code the logic for `DealDamage`, `Heal`, and `ApplyStatus` (v1 basics).
6.  **Implement AbilityRunner:** Handle Phase state, costs, and call EffectRunner.
7.  **AI Chooser:** Implement weighted random selection based on available abilities in kit.
8.  **Save/Load:** Implement serialization of UnitInstance to Dict/JSON.
