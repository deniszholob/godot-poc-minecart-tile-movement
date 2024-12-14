## const MineCartControlScheme = preload("res://components/movement/mine-cart-control-scheme.enum.gd").MineCartControlScheme
## or make global via autoload
enum MineCartControlScheme {
	## Directions (left, right, up, down) e.g. Core Keeper Character/Mine Cart. Factorio characterMost 2D top down character movements
	Character,
	## Acceleration + Directions  e.g Factorio Trains
	Vehicle_Absolute,
	## Acceleration + turning
	Vehicle_Relative,
}
