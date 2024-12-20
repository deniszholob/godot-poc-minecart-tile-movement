@tool
# Applies move_and_slide() on a CharacterBody2D, based on direction and speed
class_name MoveCharacterBody2DComponent extends Node

const WARN_REQ_actor: String = "Missing Actor Node, will be set to parent by default"

# Node to apply movement to
@export var actor: CharacterBody2D:
	set(v):
		actor = v
		if(Engine.is_editor_hint()): update_configuration_warnings()
# FIXME: Set in editor for constant direction, or reference to change dynamically
@export var direction_vector: Vector2 = Vector2.ZERO
# FIXME: Set in editor for constant speed, or reference to change dynamically
@export var speed: int = 200

# Remembers where the character is pointing to after inputs have stopped
var facing_direction: Vector2 = Vector2.DOWN

# Shows warnings in editor
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:= PackedStringArray()
	if(!actor): warnings.append(WARN_REQ_actor)
	return warnings

func _ready() -> void:
	if(!actor): actor = get_parent() # Auto get parent node as the actor
	if(Engine.is_editor_hint()): return
	actor.motion_mode = actor.MOTION_MODE_FLOATING

func _physics_process(_delta: float) -> void:
	if(Engine.is_editor_hint()): return
	actor.velocity = direction_vector.normalized() * speed
	actor.move_and_slide()

# Connect via signal or update from separate script
func on_direction_vector_update(_direction: Vector2) -> void:
	direction_vector = _direction
	if(direction_vector):
		facing_direction = direction_vector
