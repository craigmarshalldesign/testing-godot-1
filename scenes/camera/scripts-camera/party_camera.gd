extends SpringArm3D
class_name PartyCamera

## PartyCamera - Standalone camera that follows an active target (player or party member)

@export var follow_target: Node3D
@export var follow_speed: float = 10.0
@export var turn_rate: float = 180.0
@export var mouse_sensitivity: float = 0.07
@export var vertical_limit_min: float = -40.0
@export var vertical_limit_max: float = 60.0
@export var height_offset: float = 1.75

var mouse_input: Vector2 = Vector2.ZERO

@onready var camera: Camera3D = $Camera3D

func _ready() -> void:
	set_as_top_level(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# If no target assigned, try to find the player group members
	if not follow_target:
		var players: Array[Node] = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			follow_target = players[0]

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_input = - event.relative * mouse_sensitivity
	elif event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	# Handlers for rotation
	var look_input := Input.get_vector("view_right", "view_left", "view_down", "view_up")
	look_input = turn_rate * look_input * delta
	look_input += mouse_input
	mouse_input = Vector2.ZERO
	
	rotation_degrees.x += look_input.y
	rotation_degrees.y += look_input.x
	rotation_degrees.x = clampf(rotation_degrees.x, vertical_limit_min, vertical_limit_max)

func _physics_process(delta: float) -> void:
	if not follow_target:
		return
		
	# Smoothly follow the target
	var target_pos: Vector3 = follow_target.global_position + Vector3(0, height_offset, 0)
	global_position = global_position.lerp(target_pos, follow_speed * delta)

func set_target(new_target: Node3D) -> void:
	follow_target = new_target
