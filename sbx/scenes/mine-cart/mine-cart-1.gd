# class_name Minecart
extends RigidBody2D

@export var _rail_tilemap: TileMap
@export var rail_layer: int = 1
@export var speed: float = 100

var being_pushed: bool = false
@onready var area_2d: Area2D = $Area2D

# Properties
var current_tile_position:Vector2 = Vector2(0, 0)
var current_direction:Vector2 = Vector2(0, 0)

func _physics_process(delta: float):
	# Calculate the current tile position
	current_tile_position = _rail_tilemap.local_to_map(position)

	# Check if the tile at the current position is a rail tile
	if is_rail_tile(current_tile_position):
		# Update the current direction based on the rail layout
		current_direction = Vector2.ZERO  # Update this based on your rail layout
	else:
		current_direction = Vector2.ZERO

	# Move the minecart along the rail
	if current_direction != Vector2.ZERO:
		apply_central_impulse(current_direction * speed)

func is_rail_tile(tile_position:Vector2):
	# Check if the tile at the given position is a rail tile
	# You may need to adjust this logic based on your tileset
	var tile_id = _rail_tilemap.get_cell(tile_position.x, tile_position.y)
	return tile_id > 0  # Adjust this condition based on your rail tile IDs


#func _ready() -> void:
	#area_2d.body_entered.connect(_on_minecart_body_entered)
	#area_2d.body_exited.connect(_on_minecart_body_exited)

#func _physics_process(_delta: float) -> void:
	#if being_pushed: follow_rail()

func follow_rail() -> void:
	print('follow_rail', speed)
	var rail_tilemap = _rail_tilemap as TileMap
	# Get the minecart's position on the rail "minecart_pos"
	var current_tile: Vector2 = rail_tilemap.local_to_map(global_position)

	# Find the neighboring rail tiles
	var neighbors: Array[Vector2i] = rail_tilemap.get_surrounding_cells(current_tile)
	neighbors.filter(func(n: Vector2i): return rail_tilemap.get_cell_tile_data(rail_layer, n))

	# Calculate the direction based on linear_velocity
	var direction: Vector2 = linear_velocity.normalized()

	# Find the next tile in the direction of movement
	var next_tile: Vector2 = Vector2.ZERO
	if direction.x != 0:
		next_tile.x = current_tile.x + 1 if  direction.x > 0 else current_tile.x - 1
		next_tile.y = current_tile.y
	elif direction.y != 0:
		next_tile.y =current_tile.y + 1 if  direction.y > 0 else current_tile.y - 1
		next_tile.x = current_tile.x

	# Move towards the closest rail tile
	var target_pos: Vector2 = rail_tilemap.map_to_local(next_tile)
	var _direction: Vector2 = (target_pos - global_position).normalized()
	#linear_velocity = direction * speed
	apply_central_force(_direction * speed)
	#apply_central_impulse(-c.get_normal() * speed)

#func _on_minecart_body_entered(body: Node) -> void:
	#if body is Player: being_pushed = true
#
#func _on_minecart_body_exited(body: Node) -> void:
	#if body is Player: being_pushed = false
