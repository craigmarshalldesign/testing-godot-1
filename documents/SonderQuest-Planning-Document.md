SonderQuest Game Planning Document

This document summarizes the core systems planned for the platforming RPG, **SonderQuest**, based on the design conversation.1. Core Design Philosophy

* **Foundation:** A turn-based, party-system RPG drawing inspiration from *Aidyn Chronicles: The First Mage*, *Baldur's Gate*, and D\&D.  
* **Unified Ability System:** **Everything is an Ability** (spells, warrior skills, enemy actions). Naming and class-gating are layered on top.  
  * *Execution:* Abilities are a list of sequentially fired **Effects** (e.g., DealDamage, ApplyStatus, SpawnSummon, ModifyStat).  
* **Spatial Combat:** Builds on existing turn order (Speed-sorted) and spatial mechanics (range, hit radius, party formation).  
* **Level Cap:** **40**.  
* **Max Party Size:** **4 characters**.  
* **Hub/Roster:** A *Shining Force*\-style hub where all recruited allies gather and can be swapped into the active party.

2\. Damage & Defensive Model

A two-layer system for damage and defense ensures deep tuning control.A. Damage Categorization

Every damage instance has two tags: **Damage Category** (for broad defense) and **Damage Type** (for specific resistance).

| Damage Category | Primary Damage Types | Secondary Tags (Status Effects) |
| ----- | ----- | ----- |
| **Physical** | Melee, Ranged, Bleed, Crush | N/A |
| **Magical** | Fire, Ice, Shock, Poison, Arcane, Nature | Burning, Frozen, Shocked, Poisoned, Wet |
| **True** | N/A | N/A (Ignores most mitigation) |

B. Defensive Hierarchy

Damage is mitigated in two sequential layers:

1. **Layer 1: Category Mitigation**  
   * **Physical Defense:** Reduces all incoming Physical damage.  
   * **Magic Defense:** Reduces all incoming Magical damage.  
   * *Formula:* `DamageAfterCategory = IncomingDamage * (100 / (100 + Defense))`  
2. **Layer 2: Type Resistance**  
   * **Resistances:** Melee, Ranged, Fire, Ice, Shock, Poison, Arcane, Nature.  
   * *Formula:* `DamageAfterType = DamageAfterCategory * (1 - ResistancePercent)` (Typical range: \-50% to \+75%)

3\. Core Attributes and Derived StatsA. Core Attributes (Primary Stats)

These are the foundation, growing via level, class, and gear.

| Attribute | Primary Benefits (Combat & Skills) |
| ----- | ----- |
| **Strength (STR)** | Melee Attack Power, Physical Defense (slight), Carry Capacity, Intimidation Skill. |
| **Dexterity (DEX)** | Accuracy, Evasion, Ranged Attack Power, Crit Chance (small), Speed, Physical Skills (Lockpicking, Stealth). |
| **Intelligence (INT)** | Magic Power, Max Mana, Elemental Effect Chance, Knowledge Skills (Lore, Arcana). |
| **Willpower (WIL)** | Magic Defense, Status Resistance, Mana Regeneration, Survival Skills. |
| **Vitality (VIT)** | Max HP, Physical Defense, Healing Received. |
| **Charisma (CHA)** | Dialogue outcomes, Vendor prices, Social Skills (Persuasion, Deception). |

B. Derived Combat Stats

These are calculated based on attributes, level growth, and gear.

* **Resources:** Max HP, Max Mana, Max Stamina (derived from STR \+ DEX).  
* **Offensive Power:** Melee Attack Power, Ranged Attack Power, Magic Power.  
* **Critical:** Crit Chance, Crit Damage (Base 150%).  
* **Speed:** Affects turn order and movement radius in combat.  
* **Accuracy / Avoidance:** Accuracy (from DEX), Evasion (from DEX and movement bonuses).

C. Status Interaction Stats

* **Status Chance:** Base ability chance modified by INT and talents.  
* **Status Resistance:** Derived from WIL.  
* **Duration Modifiers:** Buff Duration Bonus, Debuff Duration Reduction.

4\. Stat Growth Model (Supports Class Swapping)

Final stats are determined by layers, allowing a character to swap classes without resetting their identity.

**FinalStats(level) \= SpeciesBase(level) \+ CharacterGrowth(level) \+ ClassGrowth(level) \+ Gear \+ TemporaryEffects**

* **SpeciesBase:** The base curve for the creature (human, wolf, goblin).  
* **CharacterGrowth:** The unique personal curve for a specific companion.  
* **ClassGrowth:** The class overlay, which is the only layer that changes upon class swap.

5\. Skills (Non-Combat/Exploration)

Skills are flat numeric values tied to attributes for checks (e.g., Lockpicking \+ DEX modifier vs. Difficulty Class).

| Skill Category | Skills (Examples) | Governing Attribute |
| ----- | ----- | ----- |
| **Physical** | Athletics, Acrobatics, Stealth, Lockpicking, Traps | DEX, STR |
| **Knowledge** | Lore, Arcana, Nature, Engineering, Medicine | INT |
| **Social** | Persuasion, Intimidation, Deception, Leadership | CHA |
| **Survival** | Tracking, Survival | WIL, DEX |

6\. Class System (Launch Roster)

Classes offer different **ClassGrowth** layers, talent trees, and unique exploration abilities.A. Ability Loadout Rules

* **Active Slots:** Players can equip up to **8** active abilities for combat.  
* **Ultimate:** Has its own separate slot and is not counted in the 8\.  
* **Basic Attack:** Always available, does not use a slot.  
* **Scrolls:** Grant ability unlocks with class/stat/talent-point requirements, acting as utility or side-grades.

B. Ultimate System

* **Charge Mechanic:** `UltimateCharge 0-100`.  
* **Charge Gain:** \+X charge at the start of the character's turn (baseline \+10), with bonuses from certain actions.  
* **Usage:** Ultimate consumes 100 Charge.

C. Launch Classes

| Class | Role Focus | Resources | Key Exploration Abilities | Ultimate | Passives |
| ----- | ----- | ----- | ----- | ----- | ----- |
| **Mage** | Nuker, Control, Utility | Mana | Arcane Sight, Telekinesis, Elemental Interaction (Melt/Freeze) | **Arcane Tempest** (Large AOE) | Bonus elemental effect chance. |
| **Warrior** | Frontliner, Tank, Melee Damage | Stamina, Rage | Break Barriers, Lift Heavy Objects, Intimidate Dialogue | **War Cry of the Fallen** (Party buff \+ Taunt/Fear) | Reduced damage from first hit each turn. |
| **Druid** | Traversal, Nature Control, Healer | Mana/Spirit | Bird Form (Flight), Wolf Form (Gaps), Root Growth, Calm Beasts | **Avatar of the Wild** (Empowered form \+ Aura) | Passive regen outdoors. |
| **Thief/Assassin** | Exploration Specialist, Tactical Striker | Stamina | Lockpicking, Trap Detection/Disarm, Silent Movement, Wall Climb | **Perfect Silence** (Vanish \+ Massive damage opener) | Increased loot quality and trap success. |
| **Hero** | Adaptable Fighter, Alignment Focus | Stamina | Rally (Party Movement Buff), Light/Shadow Path abilities (Partial utility) | **Fatebreaker** (Big single-target hit with alignment bonus) | Party-wide minor stat bonus. |

7\. Permadeath and Exploration Gating

* **Rule:** Allies die permanently; Hero death is Game Over.  
* **Exploration Gating:** Obstacles are tagged by **capability requirements** (e.g., `lockpick` OR `brute_force` OR `magic_unlock`), not by class. This prevents soft-locks if a key character dies.  
* **Hub:** Functions as a memorial for fallen allies and a place to recruit replacements.

8\. Experience and Level Control

* **Grinding Control:** Enemies below a certain level difference grant reduced or zero XP.  
  * *Suggested Formula:* Enemy level ≤ player level \- 4 → **0 XP**.  
  * This ensures the player must progress to gain experience effectively.  
* **Enemy Scaling:** Enemies use the same stat, ability, and cooldown systems as players, ensuring fair and legible combat.

