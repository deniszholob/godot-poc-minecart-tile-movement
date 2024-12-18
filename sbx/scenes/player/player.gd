class_name Player extends CharacterBody2D

@onready var input_device_direction_component: InputDeviceDirectionComponent = $InputDeviceDirectionComponent
@onready var move_character_body_2d_component: MoveCharacterBody2DComponent = $MoveCharacterBody2DComponent

func _ready() -> void:
	input_device_direction_component.direction_vector_update.connect(
		func(direction: Vector2):
			move_character_body_2d_component.direction_vector = direction
	)
