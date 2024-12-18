class_name LocomotiveControllerComponent extends Node

class NextMove:
	var next_tile: Vector2i
	var next_direction: Vector2i

signal locomotive_info

# Exports
@export var actor: CharacterBody2D
@export_category("Direction")
@export var input_device_direction: InputDeviceDirectionComponent
@export var initial_direction: Vector2 = Vector2.UP
@export var move_character_sprite_animation_rotation_component: MoveCharacterSpriteAnimationRotationComponent
@export_category("TileMap")
@export var tile_map: TileMap
@export var rail_layer: int = 0
@export_category("Props")
@export var TOP_SPEED: int = 2
@export var ACCELERATION: int = 2
@export var BRAKE: int = ACCELERATION * 2
@export var SLOWDOWN: int = ACCELERATION / 2
@export var STOP_THRESHOLD = 0.02  # Threshold value to consider velocity as zero
@export_category("Debug")
@export var face_direction_ray: RayCast2D
@export var intended_direction_ray: RayCast2D
@export var tile_select: Node2D

# Variables
@onready var TILE_SIZE: Vector2i = tile_map.tile_set.tile_size
var intended_direction: int = 0: # (-) = left, (+) = right (relative to face_direction), this should only be -1, 0 or 1
	set(v):
		intended_direction = v
		var intended_direction_vec: Vector2i = Vector2(face_direction).rotated(v*PI/2)
		intended_direction_ray.target_position = intended_direction_vec * TILE_SIZE
var intended_acceleration: int = 0 # (-) accelerate backward, (+) accelerate forward (relative to face_direction)
@onready var face_direction: Vector2i = initial_direction:
	set(v):
		face_direction = v
		move_character_sprite_animation_rotation_component.on_direction_vector_update(v)
		if v.length() > 0 : face_direction_ray.target_position = v * TILE_SIZE
var acceleration: int = 0
var speed: float = 0 # (-) move backward, (+) move forward (relative to face_direction)
var acceleration_reversed: bool = false

@onready var next_tile: Vector2i = tile_map.local_to_map(actor.position)
@onready var next_direction: Vector2i = face_direction

func _ready() -> void:
	input_device_direction.direction_vector_update.connect(_on_direction_vector_update)

func _physics_process(delta: float) -> void:
	var cur_actor_world_pos: Vector2 = actor.position
	var cur_tile_map_pos: Vector2i = tile_map.local_to_map(cur_actor_world_pos)
	var cur_tile_world_pos: Vector2 = tile_map.map_to_local(cur_tile_map_pos) # Current tile center position in the world

	var reached_tile_center = cur_actor_world_pos.is_equal_approx(cur_tile_world_pos)

	if(reached_tile_center):
		if(speed != 0 or (speed == 0 and next_tile == cur_tile_map_pos)):
			determine_next_move(delta)
			face_direction = next_direction
		# As soon as a dead track is reached speed should be set to 0
		var next_tile_world_pos = tile_map.map_to_local(next_tile)
		if(next_tile_world_pos.is_equal_approx(cur_actor_world_pos)): speed = 0
	elif(!reached_tile_center and speed == 0 or acceleration_reversed):

		# proceed to next tile or go to current tile center?
		# if intended_acceleration is towards the next tile keep next_tile as is (move toward it)
		# if not the next_tile = intended_next_tile_map_pos
		var intended_next_tile_map_pos: Vector2i = cur_tile_map_pos + face_direction * intended_acceleration
		var intended_next_tile_world_pos: Vector2 = tile_map.map_to_local(intended_next_tile_map_pos)
		var next_tile_world_pos = tile_map.map_to_local(next_tile)

		var is_valid_intended_next_tile_map_pos = cell_is_rail(intended_next_tile_map_pos)
#
		if(next_tile != intended_next_tile_map_pos and is_valid_intended_next_tile_map_pos):
			var intended_tile_direction = (intended_next_tile_world_pos - cur_actor_world_pos).normalized()
			var next_tile_direction = (next_tile_world_pos - cur_actor_world_pos).normalized()
			if(intended_tile_direction != next_tile_direction):
				next_tile = intended_next_tile_map_pos

	next_tile_select_debug(next_tile)

	calc_speed(delta)
	actor.velocity = speed * normalized_Vector2i(face_direction)
	actor.global_position = actor.global_position.move_toward( tile_map.map_to_local(next_tile), abs(speed))

func determine_next_move(delta: float) -> void:
	var sign = sign_non_0(speed) if speed != 0 else sign_non_0(intended_acceleration)
	#prints(sign, speed, sign_non_0(speed), intended_acceleration, sign_non_0(intended_acceleration))
	#prints(sign)

	var move_direction = face_direction * sign
	var left_direction: Vector2i = Vector2(move_direction).rotated(-PI/2)
	var right_direction: Vector2i = Vector2(move_direction).rotated(PI/2)
	#prints(Vector2i.ZERO, move_direction, left_direction, right_direction)

	var current_tile: Vector2i = tile_map.local_to_map(actor.position)
	var tile_ahead: Vector2i = current_tile + move_direction
	var tile_left: Vector2i = current_tile + left_direction
	var tile_right: Vector2i = current_tile + right_direction

	var tile_ahead_is_rail: bool = cell_is_rail(tile_ahead)
	var tile_left_is_rail: bool = cell_is_rail(tile_left)
	var tile_right_is_rail: bool = cell_is_rail(tile_right)
	#prints(current_tile, tile_ahead, tile_left, tile_right)
	#prints(cell_is_rail(current_tile), tile_ahead_is_rail, tile_left_is_rail, tile_right_is_rail)

	#var next_tile: Vector2i = current_tile
	#var next_direction: Vector2i = face_direction
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

	var intended_direction_vec: Vector2i = Vector2(face_direction).rotated(intended_direction*PI/2)
	if(intended_direction_vec != face_direction and intended_direction_vec != next_direction * sign):
		var tile_intended_direction: Vector2i = current_tile + intended_direction_vec
		var tile_intended_direction_is_rail: bool = cell_is_rail(tile_intended_direction)
		if(tile_intended_direction_is_rail):
			next_tile = tile_intended_direction
			next_direction = intended_direction_vec * sign


func _on_direction_vector_update(direction: Vector2) -> void:
	intended_direction = round(direction.x)
	intended_acceleration = round(direction.y) * -1 # y directions signes are flipped in godot

# ==== Helper functions ==== #

func next_tile_select_debug(next_cell: Vector2i) -> void:
	tile_select.position = tile_map.map_to_local(next_cell)


#func calc_velocity(delta: float) -> void:
	#var face_direction = direction_ray.get_relative_transform_to_parent()
	#velocity = speed * normalized_Vector2i(face_direction)

func calc_speed(delta: float) -> void:
	if (intended_acceleration > 0):
		acceleration = ACCELERATION if speed >= 0 else BRAKE
	elif (intended_acceleration < 0):
		acceleration = -BRAKE if speed > 0 else -ACCELERATION
	elif(intended_acceleration == 0 and speed != 0):
		acceleration = -SLOWDOWN if speed >= 0 else SLOWDOWN
	else:
		acceleration = 0

	var top_speed = TOP_SPEED
	if(Input.is_action_pressed('boost')):
		acceleration *= 4
		#top_speed *=2

	var previous_speed = speed
	speed += acceleration * delta
	speed = clamp(speed, -top_speed, top_speed)

	# Make speed exactly zero if it's close to zero
	if (speed < STOP_THRESHOLD and speed > -STOP_THRESHOLD):
		speed = 0
	acceleration_reversed = sign(previous_speed) != sign(speed)


# ==== Utility Functions ==== #

func cell_is_rail(coord: Vector2i) -> bool:
	var cell_data: TileData = tile_map.get_cell_tile_data(rail_layer, coord)
	return !!cell_data

func sign_non_0(val: float) -> int:
	return -1 if val < 0 else 1

func normalized_Vector2i(v: Vector2i) -> Vector2i:
	return v / v.length()







func test_logic(intended_acceleration: int = 0):
	prints('test_logic with intended_acceleration=', intended_acceleration)
	#var next_tile: Vector2i = Vector2i(-2, 0)
	#const cur_actor_world_pos:Vector2 = Vector2(-24, 11) # y is off tile center
	#var cur_tile_map_pos: Vector2i = tile_map.local_to_map(cur_actor_world_pos)
	#var cur_tile_world_pos: Vector2 = tile_map.map_to_local(cur_tile_map_pos) # Current tile center position in the world
#
	#const face_direction:Vector2i = Vector2i(0, -1) # going up
	#var intended_next_tile_map_pos: Vector2i = cur_tile_map_pos + face_direction * intended_acceleration # Vector2(-2, 1) | Vector2(-2, 0) | Vector2(-2, -1)
	#var intended_next_tile_world_pos: Vector2 = tile_map.map_to_local(intended_next_tile_map_pos)
#
	#var next_tile_world_pos:Vector2 = tile_map.map_to_local(next_tile)
#
	#prints(face_direction, 'face_direction')
	#prints(cur_tile_map_pos, cur_actor_world_pos, 'actor')
	#prints(cur_tile_map_pos, cur_tile_world_pos, 'cur tile')
	#prints(intended_next_tile_map_pos, intended_next_tile_world_pos, 'intended tile')
	#prints(next_tile, next_tile_world_pos, 'next tile')
#
	#actor.position = cur_actor_world_pos
	#self.next_tile = next_tile
#
	#if(next_tile != intended_next_tile_map_pos):
		#var intended_tile_direction = (intended_next_tile_world_pos - cur_actor_world_pos).normalized()
		#var next_tile_direction = (next_tile_world_pos - cur_actor_world_pos).normalized()
		#if(intended_tile_direction != next_tile_direction):
			#next_tile = intended_tile_direction
		#prints(intended_tile_direction, next_tile_direction, 'direction')
#
	#prints(next_tile, 'next tile final')
	#prints()
	prints()
