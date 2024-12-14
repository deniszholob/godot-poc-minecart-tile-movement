## GlobalGame Singleton
extends Node

#region signal
signal control_scheme_updated(control: MineCartControlScheme)
#endregion

#region Enum
const MineCartControlScheme = preload("res://components/movement/mine-cart-control-scheme.enum.gd").MineCartControlScheme
#endregion

#region vars
var minecart_control_scheme: MineCartControlScheme = MineCartControlScheme.Character:
	set(v):
		#print(v)
		minecart_control_scheme = v
		control_scheme_updated.emit(minecart_control_scheme)
#endregion

var show_lights: bool = false
var show_debug: bool = false
