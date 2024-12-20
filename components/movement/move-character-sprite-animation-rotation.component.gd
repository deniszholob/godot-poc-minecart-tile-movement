#@tool
## Applies animation frames from a spritesheet
## Spritesheet should have 360 rotation frames
## Also applies rotation to a pivot node
class_name MoveCharacterSpriteAnimationRotationComponent extends Node

# === Signals === #
# === Enums === #
enum DIRECTION { DOWN, LEFT, UP, RIGHT }
# === Constants === #
const WARN_REQ_sprite: String = "Missing Sprite Node!"

const DIRECTION_TO_VECTOR_DIC = {
	DIRECTION.DOWN: Vector2.DOWN,
	DIRECTION.LEFT: Vector2.LEFT,
	DIRECTION.UP: Vector2.UP,
	DIRECTION.RIGHT: Vector2.RIGHT,
}
const FULL_CIRCLE_ANGLE: float = 2 * PI # 360 in radians

#region Exports
## FIXME: Set in editor for constant direction_vector, or reference to change dynamically
@export var direction_vector: Vector2 = Vector2.ZERO
@export_group("Sprite Setup")
@export var sprite: Sprite2D:
	set(v):
		sprite = v
		if(Engine.is_editor_hint()): update_configuration_warnings()
@export var frame_start_direction: DIRECTION = DIRECTION.DOWN:
	set(v): _frame_start_direction = DIRECTION_TO_VECTOR_DIC[v]
@export var frames_rotation:ClockDirection = CLOCKWISE
@export var pivot: Node2D
#endregion

# === Public === #
var frames_total: int = 0
var rotation_angle_step: float = 0;

# === Private === #
var _frame_start_direction: Vector2 = Vector2.DOWN

#region Functions: Overrides
# Shows warnings in editor
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:= PackedStringArray()
	if(!sprite): warnings.append(WARN_REQ_sprite)
	return warnings

func _ready() -> void:
	if(Engine.is_editor_hint()): return
	frames_total = sprite.hframes * sprite.vframes
	rotation_angle_step = FULL_CIRCLE_ANGLE / frames_total;

func _process(_delta: float) -> void:
	if(Engine.is_editor_hint()): return
	if(direction_vector.length()):
		var direction_angle = PI * 2 - direction_vector.angle_to(_frame_start_direction)
		_animate_sprite(direction_angle);
#endregion

#region Functions: Public
## Connect via signal or update from separate script
func on_direction_vector_update(_direction: Vector2) -> void:
	direction_vector = _direction
#endregion

#region Functions: Private
# 0 1     2
# 0 11.25 22.5
func _animate_sprite(angle: float):
	if(pivot): pivot.rotation = angle
	if(sprite): sprite.frame = _angle_to_frame(angle);

func _angle_to_frame(angle: float) -> int:
	var constrained_angle = fmod(angle, FULL_CIRCLE_ANGLE)
	#var frame = int(constrained_frame / FULL_CIRCLE_ANGLE * total_frames)
	var rounded_frame = roundi(constrained_angle / rotation_angle_step)
	var frame = rounded_frame % frames_total
	return frame
#endregion
