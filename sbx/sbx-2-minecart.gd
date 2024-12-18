extends Node2D

@export var menu: Control

func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("menu")):
		menu.visible = !menu.visible
