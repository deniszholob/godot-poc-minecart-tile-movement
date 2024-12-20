## GlobalGame Singleton
extends Node

#region signal
signal minecart_control_scheme_updated(control: MineCartControlScheme)
signal control_object_changed(control: GameControlObjects)
#endregion

#region Enum
const MineCartControlScheme = preload("res://components/movement/mine-cart-control-scheme.enum.gd").MineCartControlScheme
const GameControlObjects = preload("res://services/game-control-objects.enum.gd").GameControlObjects
#endregion

#region vars
var minecart_control_scheme: MineCartControlScheme = MineCartControlScheme.Character:
	set(v):
		minecart_control_scheme = v
		minecart_control_scheme_updated.emit(minecart_control_scheme)

var control_object: GameControlObjects = GameControlObjects.Character:
	set(v):
		control_object = v
		control_object_changed.emit(control_object)
#endregion

var show_lights: bool = false
var show_debug: bool = false
