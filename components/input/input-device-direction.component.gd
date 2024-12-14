## Sends out a signal with the input direction that can be used elsewhere
class_name InputDeviceDirectionComponent extends Node
#TODO: Rename to movementComponent?

signal direction_vector_update(direction_vector: Vector2)
signal movement_vector_update(movement_vector: Vector3)

func _process(_delta: float) -> void:
	var direction_vector: Vector2 = Vector2.ZERO
	# direction_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	direction_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	direction_vector_update.emit(direction_vector)

	var movement_vector: Vector3 = Vector3.ZERO
	movement_vector.x = Input.get_axis("move_left", "move_right")
	movement_vector.y = Input.get_axis("move_up", "move_down")
	movement_vector.z = Input.get_axis("accelerate", "brake")
	movement_vector_update.emit(movement_vector)
