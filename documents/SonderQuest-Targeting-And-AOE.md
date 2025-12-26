# SonderQuest Targeting & Area of Effect (AoE) Design

This document defines the rules for targeting, range, and area shapes used by **Abilities** and **Weapons**, as well as the behavior of persistent zones.

---

## 1. Targeting Modes

The system supports four distinct modes of selecting a target in the 3D world.

### A. Self
*   **Definition:** The caster is the implicit target.
*   **Usage:** Buffs, Self-Heals, transformation toggles (Wolf Form).
*   **Preview:** Highlights the caster.

### B. Unit Target (Ally / Enemy / World Object)
*   **Definition:** Requires clicking/selecting a specific valid `GameObject` (Unit or Interactive Prop).
*   **Filtering:** Abilities define whitelists (e.g., `Ally Only`, `Enemy Only`, `Breakable Wall`).
*   **Preview:** outlines or highlights the hovered unit. Cursor changes to invalid if hovering wrong type.

### C. Ground Point Target
*   **Definition:** Selecting a specific Vector3 coordinate on the navmesh/floor.
*   **Usage:** Teleports, Summon spawning, Area Denial spells (placing a trap).
*   **Preview:** Shows a decal or ghost mesh at the mouse cursor location. Snaps to valid navmesh.

### D. Directional Target
*   **Definition:** Selecting a direction relative to the caster.
*   **Usage:** Dashes, Cone attacks, Linear projectiles launched forward.
*   **Preview:** Rotate an arrow or cone indicator around the caster based on mouse position.

---

## 2. Range Rules

### A. Range Source
*   **Weapon Range:** Uses the equipped weapon's range (e.g., Bow = 12m, Dagger = 1.5m).
*   **Ability Defined:** The ability explicitly sets the range (e.g., Fireball = 8m).

### B. Placement Logic
*   **Radius Constraint:** Ground Point targeting creates a valid "placement disc" around the caster. The cursor is clamped to this radius.
*   **Line of Sight (LOS):** 
    *   *Direct:* Requires a clear raycast from Caster Eye to Target Center.
    *   *Lobbed:* Allows ignoring LOS for obstacles below a certain height (e.g., Grenade, Meteor).

---

## 3. Area Shapes

When an ability hits (or is placed), it affects an area defined by one of these shapes:

*   **Single Target:** Affects strictly the selected unit.
*   **Circle / Sphere:** Affects all valid units within radius R of the impact point.
*   **Cone:** Affects all valid units within Angle A and Distance D, originating from Caster.
*   **Line:** Affects all valid units along a vector of Width W and Length L.
*   **Chain (Future):** Jumps from primary target to nearest neighbor X times.

---

## 4. Target Preview UX

Visual feedback is critical for a tactical game.

1.  **Selection:** When ability is clicked in UI, the mouse cursor enters "Targeting Mode."
2.  **Indicator:**
    *   *Unit Target:* Reticle appears over hovered unit.
    *   *Ground Target:* Decal (Circle/Square) follows mouse.
    *   *Directional:* Cone/Arrow mesh rotates around player.
3.  **Ghosting:** For movement abilities (Dash/Blink), show a semi-transparent "Ghost" of the character at the destination point.
4.  **Validation:**
    *   *Valid:* Indicator is Green/Blue.
    *   *Invalid:* Indicator is Red/Grey (e.g., out of range, blocked LOS).
5.  **Confirmation:** Left-Click confirms cast. Right-Click cancels targeting.

---

## 5. Persistent Areas (Zones)

Some abilities create "Zones" that remain in the world (e.g., Hurricane, Poison Cloud, Wall of Fire).

### A. Zone Definition
*   **Duration:** Measured in **Turns**.
*   **Tick Timing:** When does it apply its effect?
    *   *On Entry:* Immediate effect when a unit walks in.
    *   *End of Turn:* Applies if unit ends turn inside.
    *   *Start of Caster Turn:* Applies to everyone inside (DoT pulsing).
*   **Ownership:** Zones store the `CasterID` to calculate damage scaling dynamically.

### B. Behavior Types
*   **Fixed:** Stays at the spawn coordinate (e.g., Trap).
*   **Attached:** Follows the target unit (e.g., Aura).

---

## 6. Interaction with Turn Phases

*   **Movement Phase:**
    *   Utility Abilities (Dash, Blink) use *Directional* or *Ground Point* targeting to effectively modify the character's position *before* the Action phase.
    *   Preview shows the new resulting position.
*   **Action Phase:**
    *   Action Abilities (Attacks) execute from the *current* position (post-movement).
    *   Zones created during this phase persist through enemy turns until the Caster's next turn ticks the duration down.

---

## 7. Facing, Arcs, and Positional Checks

Combat is directional. All units possess a **Facing Vector**.

### A. Positional Arcs
1.  **Front Arc:** Target is facing the attacker. (Standard Defense).
2.  **Side Arcs:** Target is flanked. (Reduced Evasion typically).
3.  **Back Arc:** Target is facing away. (Bonus Damage / Crit Chance).

### B. Positional Logic
*   **Back Attacks:** Abilities may require being in the Back Arc to activate or grant specific bonuses (e.g., *Sneak Attack*).
*   **Movement Components:**
    *   **Dash/Teleport Behind:** Logic calculates a destination at a fixed offset behind the target's facing vector.
    *   **Validation:** If the "Behind" point is invalid (e.g., inside a wall), the ability should either fail or snap to the nearest valid mesh point (Design Choice).

*Example Concept:*
**Assassin Backstab Blink:** Select Enemy -> System Previews point behind enemy -> Blink to point -> Execute Weapon Strike.
