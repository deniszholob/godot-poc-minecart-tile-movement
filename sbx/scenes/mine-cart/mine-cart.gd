class_name Minecart
#extends RigidBody2D
extends CharacterBody2D

@export var _rail_tilemap: TileMap
@export var rail_layer: int = 1
@export var speed: float = 100


@onready var input_device_direction_component: InputDeviceDirectionComponent = %InputDeviceDirectionComponent
# @onready var move_rigid_body_2d_component: MoveRigidBody2DComponent = %MoveRigidBody2DComponent
@onready var move_character_body_2d_component: MoveCharacterBody2DComponent = %MoveCharacterBody2DComponent

func _ready() -> void:
	input_device_direction_component.direction_vector_update.connect(constrained_movement)
	pass

func _physics_process(delta: float):
	pass

func constrained_movement(direction_vector: Vector2) -> void:
	var constrained_vector: Vector2 = direction_vector
	move_character_body_2d_component.on_direction_vector_update(constrained_vector)
