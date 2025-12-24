class_name TargetingSystem
extends RefCounted

## TargetingUtility - Helpers for finding the best target in combat

const WEIGHT_DISTANCE: float = 1.0
const WEIGHT_HEALTH: float = 2.0 # Prefer slightly weaker targets if nearby

# Finds the best target from a group of candidates relative to the seeker
static func find_best_target(seeker: Node3D, candidates: Array[Node]) -> Node3D:
	var best_target: Node3D = null
	var best_score: float = 99999.0
	
	for candidate in candidates:
		# Validation checks
		if not is_instance_valid(candidate): continue
		if not candidate is Node3D: continue
		if candidate == seeker: continue
		
		# Check death status
		if candidate.get("is_dead"): continue
		
		# Check visibility/active status (e.g. inactive party members)
		if not candidate.is_visible_in_tree(): continue
		
		# Calculate Score (Lower is better)
		var dist: float = seeker.global_position.distance_to(candidate.global_position)
		
		# Health factor (0.0 to 1.0)
		var health_factor: float = 1.0
		var stats: CombatantStats = candidate.get("stats")
		if stats:
			if stats.max_health > 0:
				health_factor = float(stats.current_health) / float(stats.max_health)
				
		# Composite score
		# We want low distance and low health to be "good" (low score)
		var score: float = (dist * WEIGHT_DISTANCE) + (health_factor * 20.0 * WEIGHT_HEALTH)
		
		if score < best_score:
			best_score = score
			best_target = candidate
			
	return best_target

# Simple closest target finder
static func find_closest_target(seeker: Node3D, candidates: Array[Node]) -> Node3D:
	var best_target: Node3D = null
	var min_dist: float = 99999.0
	
	for candidate in candidates:
		if not is_instance_valid(candidate): continue
		if not candidate is Node3D: continue
		if candidate.get("is_dead"): continue
		if not candidate.is_visible_in_tree(): continue
		
		var dist: float = seeker.global_position.distance_to(candidate.global_position)
		if dist < min_dist:
			min_dist = dist
			best_target = candidate
			
	return best_target
