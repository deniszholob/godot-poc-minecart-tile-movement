class_name MineCartModel extends Resource

@export var TOP_SPEED: int = 2
@export var ACCELERATION: int = 2
## ACCELERATION * 2
@export var BRAKE: int = 4
## ACCELERATION / 2
@export var SLOWDOWN: int = 1
## Threshold value to consider velocity as zero
@export var STOP_THRESHOLD = 0.01
