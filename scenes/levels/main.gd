extends Node2D

@onready var canvas_modulate: CanvasModulate = $CanvasModulate

@export var menu: Control

func _process(delta: float) -> void:
	canvas_modulate.visible = GlobalGame.show_lights

func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("menu")):
		menu.visible = !menu.visible
	if(event.is_action_pressed("option")):
		print('tab')
		if(GlobalGame.control_object == GlobalGame.GameControlObjects.Character):
			GlobalGame.control_object = GlobalGame.GameControlObjects.Minecart
		elif(GlobalGame.control_object == GlobalGame.GameControlObjects.Minecart):
			GlobalGame.control_object = GlobalGame.GameControlObjects.Character
