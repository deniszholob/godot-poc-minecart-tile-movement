extends CharacterBody2D

# Constants
const TOP_SPEED: int = 5
const ACCELERATION: int = 2
const BRAKE: int = ACCELERATION * 1
const SLOWDOWN: int = ACCELERATION / 2
const STOP_THRESHOLD = 0.02  # Threshold value to consider velocity as zero

# Exports
@export var initial_direction: Vector2 = Vector2.UP
@export var tile_map: TileMap
@export var input_device_direction: InputDeviceDirectionComponent
@export var rail_layer: int = 0
# Debug
@export var state_label: Label
@export var intended_direction_label: Label
@export var intended_acceleration_label: Label
@export var direction_label: Label
@export var acceleration_label: Label
@export var speed_label: Label
@export var velocity_label: Label

# Variables
var intended_direction: int = 0 # (-) = left, (+) = right (relative to face_direction), this should only be -1, 0 or 1
var intended_acceleration: int = 0 # (-) accelerate backward, (+) accelerate forward (relative to face_direction)
var face_direction: Vector2i = initial_direction
var acceleration: int = 0
var speed: float = 0 # (-) move backward, (+) move forward (relative to face_direction)

func _ready():
	input_device_direction.direction_vector_update.connect(on_direction_vector_update)

	var switch_direction: Vector2i =  find_next_move()
	prints(switch_direction, face_direction)

func debug() -> void:
	intended_direction_label.text = str(intended_direction)
	intended_acceleration_label.text = str(intended_acceleration)
	direction_label.text = str(face_direction)
	acceleration_label.text = str(acceleration)
	speed_label.text = str(speed)
	velocity_label.text = str(velocity)

func cell_is_rail(coord: Vector2i) -> bool:
	var cell_data: TileData = tile_map.get_cell_tile_data(rail_layer, coord)
	return !!cell_data

func sign_non_0(val: float) -> int:
	return -1 if val < 0 else 1

func movement_1(delta: float) -> void:
	var sign = sign_non_0(speed) if speed != 0 else sign_non_0(intended_acceleration)
	#prints(sign, speed, sign_non_0(speed), intended_acceleration, sign_non_0(intended_acceleration))
	#prints(sign)

	var move_direction = face_direction * sign
	var left_direction: Vector2i = Vector2(move_direction).rotated(-PI/2)
	var right_direction: Vector2i = Vector2(move_direction).rotated(PI/2)
	#prints(Vector2i.ZERO, move_direction, left_direction, right_direction)

	var current_tile: Vector2i = tile_map.local_to_map(position)
	var tile_ahead: Vector2i = current_tile + move_direction
	var tile_left: Vector2i = current_tile + left_direction
	var tile_right: Vector2i = current_tile + right_direction

	var tile_ahead_is_rail: bool = cell_is_rail(tile_ahead)
	var tile_left_is_rail: bool = cell_is_rail(tile_left)
	var tile_right_is_rail: bool = cell_is_rail(tile_right)
	#prints(current_tile, tile_ahead, tile_left, tile_right)
	#prints(cell_is_rail(current_tile), tile_ahead_is_rail, tile_left_is_rail, tile_right_is_rail)


	var next_tile: Vector2i = current_tile
	var switch_direction: Vector2i = face_direction


	if(tile_ahead_is_rail):
		next_tile = tile_ahead
	else:
		if(tile_left_is_rail and !tile_right_is_rail):
			next_tile = tile_left
			switch_direction = left_direction
		if(!tile_left_is_rail and tile_right_is_rail):
			next_tile = tile_right
			switch_direction = right_direction

	state_label.text = str(current_tile, '__', next_tile)
	face_direction = switch_direction
	calc_speed(delta)
	velocity = speed * normalized_Vector2i(face_direction)
	#prints(next_tile, face_direction)
	tile_move(next_tile, abs(speed))
	global_position = global_position.move_toward( tile_map.map_to_local(next_tile), abs(speed))

func tile_move(target_tile_map_pos: Vector2i, speed: int):
	var cur_actor_world_pos: Vector2 = global_position
	var cur_tile_map_pos: Vector2i = tile_map.local_to_map(global_position)
	var cur_tile_world_pos: Vector2 = tile_map.map_to_local(cur_tile_map_pos) # Current tile center position in the world
	var target_tile_world_pos: Vector2 = tile_map.map_to_local(target_tile_map_pos) # Target tile center position in the world

	var direction_to_next_tile: Vector2  = cur_actor_world_pos.direction_to(target_tile_world_pos)

	prints(direction_to_next_tile, direction_to_next_tile.aspect(), rad_to_deg(direction_to_next_tile.angle()))
	# If forward movement keep going
	# if turn:

	#global_position = global_position.move_toward(tile_map.map_to_local(next_tile), abs(speed))



func calc_speed(delta: float) -> void:
	if (intended_acceleration > 0):
		acceleration = ACCELERATION if speed >= 0 else BRAKE
	elif (intended_acceleration < 0):
		acceleration = -BRAKE if speed > 0 else -ACCELERATION
	elif(intended_acceleration == 0 and speed != 0):
		acceleration = -SLOWDOWN if speed >= 0 else SLOWDOWN
	else:
		acceleration = 0

	speed += acceleration * delta
	speed = clamp(speed, -TOP_SPEED, TOP_SPEED)

	# Make speed exactly zero if it's close to zero
	if (speed < STOP_THRESHOLD and speed > -STOP_THRESHOLD):
		speed = 0


func on_direction_vector_update(direction: Vector2) -> void:
	intended_direction = round(direction.x)
	intended_acceleration = round(direction.y) * -1 # y directions signes are flipped in godot

func normalized_Vector2i(v: Vector2i) -> Vector2i:
	return v / v.length()
	#return v.normalized()







func find_next_move() -> Vector2i:
	var sign = sign_non_0(speed) if speed != 0 else intended_acceleration
	var move_direction = face_direction * sign
	var left_direction: Vector2i = Vector2(move_direction).rotated(-PI/2)
	var right_direction: Vector2i = Vector2(move_direction).rotated(PI/2)
	prints(Vector2i.ZERO, move_direction, left_direction, right_direction)

	var current_tile: Vector2i = tile_map.local_to_map(position)
	var tile_ahead: Vector2i = current_tile + move_direction
	var tile_left: Vector2i = current_tile + left_direction
	var tile_right: Vector2i = current_tile + right_direction

	var tile_ahead_is_rail: bool = cell_is_rail(tile_ahead)
	var tile_left_is_rail: bool = cell_is_rail(tile_left)
	var tile_right_is_rail: bool = cell_is_rail(tile_right)
	prints(current_tile, tile_ahead, tile_left, tile_right)
	prints(cell_is_rail(current_tile), tile_ahead_is_rail, tile_left_is_rail, tile_right_is_rail)

	if(tile_ahead_is_rail): return tile_ahead
	else:
		if(tile_left_is_rail and !tile_right_is_rail): return tile_left
		if(!tile_left_is_rail and tile_right_is_rail): return tile_right
		else: return current_tile
	return current_tile

	#if(tile_ahead_is_rail): return move_direction
	#else:
		#if(tile_left_is_rail and !tile_right_is_rail): return left_direction
		#if(!tile_left_is_rail and tile_right_is_rail): return right_direction
		#else: return Vector2i.ZERO
	#return Vector2i.ZERO

func movement_2(delta: float) -> void:
	var switch_direction: Vector2i =  find_next_move()
	if(switch_direction == Vector2i.ZERO): speed = 0
	else:
		face_direction = switch_direction * sign_non_0(speed)
		calc_speed(delta)
	prints(switch_direction, face_direction)
	# Move relative to face direction
	velocity = speed * normalized_Vector2i(face_direction)
	# Move the locomotive
	move_and_collide(velocity)


func _physics_process(delta: float):
	debug()
	movement_1(delta)

	# before next velocity calculation, check what tile is available to move to, based on speed and face_direction:
		# If speed is zero: skip
		# if there is an intended direction:
			# if there is a tile available to go to intended direction (relative to face_direction + speed), set direction to that tile (UP, DOWN, LEFT RIGHT) no 45degree movements
				# example: intended_direction = leif face_direction is UP and speed is in the UP direction, check tile in UP, LEFT, RIGHT
		# If no tile available to go to with the desired direction treat as coasting without intended direction
		# If coasting and tiles are available ahead or to side, move there by:
			# if tile ahead always move there
			# if no tiles ahead but tile on one side move there
			# if no tiles ahead and 2 tiles on eithr side, stop
		# If either coasting or not, when there is no tile ahead, and no tile left and no tile right then hard STOP


	# # Before calculating velocity, check if there is a tile available to move to, based on speed and face_direction
	# if speed != 0:
	# 	# Check if there is intended direction
	# 	if intended_direction != 0:
	# 		# Check if there is a tile available to go to intended direction
	# 		var intended_direction_vector: Vector2i = Vector2i(intended_direction, 0) + Vector2i(face_direction.x, face_direction.y) * sign(speed)
	# 		var tile_available: Vector2i = intended_direction_vector + current_tile
	# 		if tile_map.get_cellv(tile_available) != -1:
	# 			face_direction = intended_direction_vector
	# 		else:
	# 			intended_direction = 0
	# 	# If no tile available to go to with the desired direction treat as coasting without intended direction

	# 	# If coasting and tiles are available ahead or to side, move there by:
	# 		# if tile ahead always move there
	# 		var tile_ahead: Vector2i = current_tile + face_direction
	# 		if tile_map.get_cellv(tile_ahead) != -1:
	# 			face_direction = face_direction.normalized()
	# 		# if no tiles ahead but tile on one side move there
	# 		else:
	# 			var tile_side: Vector2i = current_tile + Vector2i(face_direction.y, -face_direction.x)
	# 			if tile_map.get_cellv(tile_side) != -1:
	# 				face_direction = Vector2i(face_direction.y, -face_direction.x).normalized()
	# 			# if no tiles ahead and 2 tiles on eithr side, stop
	# 			else:
	# 				var tile_left: Vector2i = current_tile + Vector2i(-1, 0)
	# 				var tile_right: Vector2i = current_tile + Vector2i(1, 0)
	# 				if tile_map.get_cellv(tile_left) != -1 and tile_map.get_cellv(tile_right) != -1:
	# 					face_direction = Vector2.ZERO
	# 	# If either coasting or not, when there is no tile ahead, and no tile left and no tile right then hard STOP
	# 	if face_direction == Vector2.ZERO and tile_map.get_cellv(current_tile + Vector2i(-1, 0)) == -1 and tile_map.get_cellv(current_tile + Vector2i(1, 0)) == -1:
	# 		face_direction = Vector2.ZERO


	#var switch_direction: Vector2i =  find_next_move()
	#if(switch_direction == Vector2i.ZERO): speed = 0
	#else:
		#face_direction = switch_direction * sign_non_0(speed)
		#calc_speed(delta)
	#prints(switch_direction, face_direction)
	## Move relative to face direction
	#velocity = speed * normalized_Vector2i(face_direction)
	## Move the locomotive
	#move_and_collide(velocity)
