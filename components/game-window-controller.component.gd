## Handles Game window stuff like quitting and resizing
class_name GameWindowControllerComponent extends Node

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("window_fullscreen"):
		swap_fullscreen_mode()
	# Instead of quit hotkey, quick through menu, can always ALT-F4?
	#if Input.is_action_just_pressed("quit"):
		#get_tree().quit()

func swap_fullscreen_mode():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
