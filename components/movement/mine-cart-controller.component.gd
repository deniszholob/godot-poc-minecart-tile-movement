@tool
## Keeps a Character2D body moving on set tilemap cells
class_name MineCartControllerComponent extends Node

#region signal
signal minecart_debug_info(debug_info: MineCartDebugInfo)
#endregion

#region enum
const MineCartControlScheme = preload("res://components/movement/mine-cart-control-scheme.enum.gd").MineCartControlScheme
#endregion

#region const
const WARN_REQ_actor: String = "Missing Actor Node, will be set to parent by default"
const WARN_REQ_input_device_direction: String = "Missing MoveCharacterSpriteAnimationRotationComponent"
const WARN_REQ_move_character_sprite_animation_rotation_component: String = "Missing InputDeviceDirectionComponent"
#endregion

#region @export
## Node to apply movement to
@export var actor: MineCart:
	set(v):
		actor = v
		if(Engine.is_editor_hint()): update_configuration_warnings()

@export_category("Direction")
## User control input
@export var input_device_direction: InputDeviceDirectionComponent:
	set(v):
		input_device_direction = v
		if(Engine.is_editor_hint()): update_configuration_warnings()
@export var initial_direction: Vector2 = Vector2.UP
@export var move_character_sprite_animation_rotation_component: MoveCharacterSpriteAnimationRotationComponent:
	set(v):
		move_character_sprite_animation_rotation_component = v
		if(Engine.is_editor_hint()): update_configuration_warnings()

@export_category("Stats")
@export var stats: MineCartModel
#endregion

#region @onready
@onready var TILE_SIZE: Vector2i = actor.tile_map.tile_set.tile_size
@onready var next_tile: Vector2i = actor.tile_map.local_to_map(actor.position)
@onready var next_direction: Vector2i = face_direction
@onready var face_direction: Vector2i = initial_direction:
	set(v):
		face_direction = v
		move_character_sprite_animation_rotation_component.on_direction_vector_update(v)
@onready var debug_data: MineCartDebugInfo = MineCartDebugInfo.new(face_direction, intended_relative_direction_vec, next_tile)
#endregion

#region var
var intended_relative_direction_vec: Vector2i = Vector2i.ZERO
var intended_relative_direction: int = 0: # (-) = left, (+) = right (relative to face_direction), this should only be -1, 0 or 1
	set(v):
		intended_relative_direction = v
		intended_relative_direction_vec = Vector2(face_direction).rotated(v * PI/2)
var intended_acceleration: int = 0 # (-) accelerate backward, (+) accelerate forward (relative to face_direction)

var acceleration: int = 0
var speed: float = 0 # (-) move backward, (+) move forward (relative to face_direction)
var acceleration_reversed: bool = false
#endregion


#region func: Overrides
# Shows warnings in editor
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:= PackedStringArray()
	if(!actor): warnings.append(WARN_REQ_actor)
	if(!input_device_direction): warnings.append(WARN_REQ_input_device_direction)
	if(!move_character_sprite_animation_rotation_component): warnings.append(WARN_REQ_move_character_sprite_animation_rotation_component)
	return warnings


func _ready() -> void:
	if(!actor): actor = get_parent() # Auto get parent node as the actor
	if(Engine.is_editor_hint()): return
	actor.motion_mode = actor.MOTION_MODE_FLOATING
	#actor.floor_max_angle = 0
	input_device_direction.movement_vector_update.connect(_on_movement_input_vector_update)
	minecart_debug_info.connect(actor.on_debug_update)

func _physics_process(delta: float) -> void:
	if(Engine.is_editor_hint()): return
	var cur_actor_world_pos: Vector2 = actor.position
	var cur_tile_map_pos: Vector2i = actor.tile_map.local_to_map(cur_actor_world_pos)
	var cur_tile_world_pos: Vector2 = actor.tile_map.map_to_local(cur_tile_map_pos) # Current tile center position in the world

	var reached_tile_center = cur_actor_world_pos.is_equal_approx(cur_tile_world_pos)

	if(reached_tile_center):
		if(speed != 0 or (speed == 0 and next_tile == cur_tile_map_pos)):
			_determine_next_move(delta)
			face_direction = next_direction
		# As soon as a dead track is reached speed should be set to 0
		var next_tile_world_pos = actor.tile_map.map_to_local(next_tile)
		if(next_tile_world_pos.is_equal_approx(cur_actor_world_pos)): speed = 0
	elif(!reached_tile_center and speed == 0 or acceleration_reversed):

		# TODO: proceed to next tile or go to current tile center?
		# if intended_acceleration is towards the next tile: keep next_tile as is (move toward it)
		# if not: the next_tile = intended_next_tile_map_pos
		var intended_next_tile_map_pos: Vector2i = cur_tile_map_pos + face_direction * intended_acceleration
		var intended_next_tile_world_pos: Vector2 = actor.tile_map.map_to_local(intended_next_tile_map_pos)
		var next_tile_world_pos = actor.tile_map.map_to_local(next_tile)

		var is_valid_intended_next_tile_map_pos = cell_is_rail(intended_next_tile_map_pos)
#
		if(next_tile != intended_next_tile_map_pos and is_valid_intended_next_tile_map_pos):
			var intended_tile_direction = (intended_next_tile_world_pos - cur_actor_world_pos).normalized()
			var next_tile_direction = (next_tile_world_pos - cur_actor_world_pos).normalized()
			if(intended_tile_direction != next_tile_direction):
				next_tile = intended_next_tile_map_pos

	calc_speed(delta)
	actor.velocity = speed * normalized_Vector2i(face_direction)
	actor.global_position = actor.global_position.move_toward(actor.tile_map.map_to_local(next_tile), abs(speed))

	_emit_debug_info()
#endregion


#region func: Private
func _emit_debug_info() -> void:
	debug_data.next_tile = next_tile
	debug_data.face_direction = face_direction
	debug_data.intended_relative_direction = intended_relative_direction_vec
	minecart_debug_info.emit(debug_data)

func _determine_next_move(_delta: float) -> void:
	var sign = sign_non_0(speed) if speed != 0 else sign_non_0(intended_acceleration)

	var move_direction = face_direction * sign
	var left_direction: Vector2i = Vector2(move_direction).rotated(-PI/2)
	var right_direction: Vector2i = Vector2(move_direction).rotated(PI/2)

	var current_tile: Vector2i = actor.tile_map.local_to_map(actor.position)
	var tile_ahead: Vector2i = current_tile + move_direction
	var tile_left: Vector2i = current_tile + left_direction
	var tile_right: Vector2i = current_tile + right_direction

	var tile_ahead_is_rail: bool = cell_is_rail(tile_ahead)
	var tile_left_is_rail: bool = cell_is_rail(tile_left)
	var tile_right_is_rail: bool = cell_is_rail(tile_right)

	next_tile = current_tile
	next_direction = face_direction

	if(tile_ahead_is_rail):
		next_tile = tile_ahead
	else:
		if(tile_left_is_rail and !tile_right_is_rail):
			next_tile = tile_left
			next_direction = left_direction * sign
		if(!tile_left_is_rail and tile_right_is_rail):
			next_tile = tile_right
			next_direction = right_direction * sign

	var intended_relative_direction_vec: Vector2i = Vector2(face_direction).rotated(intended_relative_direction*PI/2)
	if(intended_relative_direction_vec != face_direction and intended_relative_direction_vec != next_direction * sign):
		var tile_intended_relative_direction: Vector2i = current_tile + intended_relative_direction_vec
		var tile_intended_relative_direction_is_rail: bool = cell_is_rail(tile_intended_relative_direction)
		if(tile_intended_relative_direction_is_rail):
			next_tile = tile_intended_relative_direction
			next_direction = intended_relative_direction_vec * sign

## movement:vector3 (left/right, up/down, power/brake)
func _on_movement_input_vector_update(movement: Vector3) -> void:
	match actor.control_scheme:
		MineCartControlScheme.Vehicle_Relative:
			intended_relative_direction = round(movement.x)
			intended_acceleration = round(movement.y) * -1 # y directions signes are flipped in godot

		MineCartControlScheme.Character:
			# for acc, check  current face_direction, if direction axis matches + acc or - acc
			#if(face_direction.length() !=0):
			if(face_direction.y != 0): # up/down
				intended_acceleration = round(movement.y) * sign_non_0(face_direction.y)
				intended_relative_direction = round(movement.x) * sign_non_0(face_direction.y) * -1
			else: # left/right
				intended_acceleration = round(movement.x) * sign_non_0(face_direction.x)
				intended_relative_direction = round(movement.y) * sign_non_0(face_direction.x)

		MineCartControlScheme.Vehicle_Absolute:
			intended_acceleration = round(movement.z) * -1 # y directions signes are flipped in godot
			if(face_direction.y != 0): # up/down
				intended_relative_direction = round(movement.x) * sign_non_0(face_direction.y) * -1
			else:
				intended_relative_direction = round(movement.y) * sign_non_0(face_direction.x)
#endregion


#region func: Helper
func calc_speed(delta: float) -> void:
	if (intended_acceleration > 0):
		acceleration = stats.ACCELERATION if speed >= 0 else stats.BRAKE
	elif (intended_acceleration < 0):
		acceleration = -stats.BRAKE if speed > 0 else -stats.ACCELERATION
	elif(intended_acceleration == 0 and speed != 0):
		acceleration = -stats.SLOWDOWN if speed >= 0 else stats.SLOWDOWN
	else:
		acceleration = 0

	var top_speed = stats.TOP_SPEED
	var previous_speed = speed

	speed += acceleration * delta
	speed = clamp(speed, -top_speed, top_speed)

	# Make speed exactly zero if it's close to zero
	if (speed < stats.STOP_THRESHOLD and speed > -stats.STOP_THRESHOLD):
		speed = 0
	acceleration_reversed = sign(previous_speed) != sign(speed)
#endregion


#region func: Utility
func cell_is_rail(coord: Vector2i) -> bool:
	var cell_data: TileData = actor.tile_map.get_cell_tile_data(actor.rail_layer, coord)
	return !!cell_data

func sign_non_0(val: float) -> int:
	return -1 if val < 0 else 1

func normalized_Vector2i(v: Vector2i) -> Vector2i:
	return v / v.length()
#endregion
