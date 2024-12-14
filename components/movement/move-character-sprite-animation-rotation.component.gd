## Applies animation frames from a spritesheet
## Spritesheet should have 360 rotation frames
class_name MoveCharacterSpriteAnimationRotationComponent extends Node

# === Signals === #
# === Enums === #
enum DIRECTION { DOWN, LEFT, UP, RIGHT }
# === Constants === #
const DIRECTION_TO_VECTOR_DIC = {
	DIRECTION.DOWN: Vector2.DOWN,
	DIRECTION.LEFT: Vector2.LEFT,
	DIRECTION.UP: Vector2.UP,
	DIRECTION.RIGHT: Vector2.RIGHT,
}
const FULL_CIRCLE_ANGLE: float = 2 * PI # 360 in radians

#region Exports
## Set in editor for constant direction_vector, or reference to change dynamically
@export var direction_vector: Vector2 = Vector2.ZERO
@export_group("Sprite Setup")
@export var sprite: Sprite2D
# TODO: This can be simplified to just the range, or just reading the sprite v/h frames
@export_range(4, 360, 4) var directions: int = 4
@export var frames_per_direction: int = 1
@export var frame_start_direction: DIRECTION = DIRECTION.DOWN:
	set(v): _frame_start_direction = DIRECTION_TO_VECTOR_DIC[v]
@export var frames_rotation:ClockDirection = CLOCKWISE
@export var pivot: Node2D
#endregion

# === Public === #
var frames_total: int = frames_per_direction * directions
var rotation_angle_step: float = FULL_CIRCLE_ANGLE / frames_total;

# === Private === #
var _frame_start_direction: Vector2 = Vector2.DOWN

# === Onready === #

#region Functions: Overrides
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
