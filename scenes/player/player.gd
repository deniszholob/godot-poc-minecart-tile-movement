class_name Player extends CharacterBody2D

#region enum
const GameControlObjects = GlobalGame.GameControlObjects
#endregion

#region @onready
@onready var input_device_direction_component: InputDeviceDirectionComponent = $InputDeviceDirectionComponent
@onready var move_character_body_2d_component: MoveCharacterBody2DComponent = $MoveCharacterBody2DComponent
@onready var move_character_sprite_animation_rotation_component: MoveCharacterSpriteAnimationRotationComponent = $MoveCharacterSpriteAnimationRotationComponent
#endregion

#region var
var enabled: bool = true
#endregion

#region func: Overrides
func _ready() -> void:
	if(Engine.is_editor_hint()): return
	GlobalGame.control_object_changed.connect(self._enable_player)
	input_device_direction_component.direction_vector_update.connect(self._on_direction_vector_update)
#endregion

#region func: Private
func _on_direction_vector_update(direction_in: Vector2) -> void:
	var direction:Vector2 = direction_in if enabled else Vector2.ZERO
	move_character_body_2d_component.direction_vector = direction
	move_character_sprite_animation_rotation_component.direction_vector = direction

func _enable_player(control: GameControlObjects) -> void:
	enabled = control == GameControlObjects.Character
#endregion
