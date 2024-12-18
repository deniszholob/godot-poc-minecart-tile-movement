extends Control

#region Enum
const MineCartControlScheme = preload("res://components/movement/mine-cart-control-scheme.enum.gd").MineCartControlScheme
#endregion

#region export
@export var button_group: ButtonGroup
#endregion

#region onready
@onready var character_control_text: RichTextLabel = %CharacterControlText
@onready var vehicle_relative_control_text: RichTextLabel = %VehicleRelativeControlText
@onready var vehicle_absolute_control_text: RichTextLabel = %VehicleAbsoluteControlText
@onready var quit_button: Button = %QuitButton
@onready var back_button: Button = %BackButton
@onready var lights_button: CheckButton = %LightsButton
@onready var debug_button: CheckButton = %DebugButton
#endregion

#region func: Overrides
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_set_defaults_from_ui()
	_connect_action_events()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
#endregion

#region func: Private
func _set_defaults_from_ui() -> void:
	_on_control_changed(button_group.get_pressed_button())
	_show_lights(lights_button.button_pressed)
	_show_debug(debug_button.button_pressed)

func _connect_action_events() -> void:
	quit_button.pressed.connect(func(): get_tree().quit())
	button_group.pressed.connect(_on_control_changed)
	lights_button.pressed.connect(func(): _show_lights(!GlobalGame.show_lights))
	debug_button.pressed.connect(func(): _show_debug(!GlobalGame.show_debug))

func _show_lights(value: bool) -> void:
	GlobalGame.show_lights = value

func _show_debug(value: bool) -> void:
	GlobalGame.show_debug = value

func _on_control_changed(button: BaseButton) -> void:
	#print(button.name)
	match button.name:
		'Character':
			GlobalGame.minecart_control_scheme = MineCartControlScheme.Character
			character_control_text.visible = true
			vehicle_relative_control_text.visible = false
			vehicle_absolute_control_text.visible = false
		'Vehicle_Relative': # Vehicle
			GlobalGame.minecart_control_scheme = MineCartControlScheme.Vehicle_Relative
			character_control_text.visible = false
			vehicle_relative_control_text.visible = true
			vehicle_absolute_control_text.visible = false
		'Vehicle_Absolute': # Combo
			GlobalGame.minecart_control_scheme = MineCartControlScheme.Vehicle_Absolute
			character_control_text.visible = false
			vehicle_relative_control_text.visible = false
			vehicle_absolute_control_text.visible = true
#endregion
