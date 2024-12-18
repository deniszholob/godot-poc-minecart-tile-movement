class_name Wagon extends CharacterBody2D

var connected_to: Wagon

func connect_to_wagon(wagon: Wagon) -> void:
	connected_to = wagon

func disconnect_from_wagon() -> void:
	connected_to = null
