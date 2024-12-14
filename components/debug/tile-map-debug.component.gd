@tool
## Adds debug info to tilemap, place underneath a TileMap component to autoset it in this script
class_name TileMapDebugComponent extends Node

const WARN_REQ_tile_map: String = "Missing Actor Node, will be set to parent by default"

## Tilemap to display debug info on
@export var tile_map: TileMap:
	set(v):
		tile_map = v
		if(Engine.is_editor_hint()): update_configuration_warnings()
## Label scene to show (x,y) info on
@export var DEBUG_LABEL: PackedScene = preload('./debug_label.tscn')
## Toggle the debug info display
@export var show_debug_info: bool = true

# Shows warnings in editor
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:= PackedStringArray()
	if(!tile_map): warnings.append(WARN_REQ_tile_map)
	return warnings

func _ready() -> void:
	if(!tile_map): tile_map = get_parent() # Auto get parent node as the tile_map
	if(Engine.is_editor_hint()): return
	if(show_debug_info): _draw_debug_labels()

func _draw_debug_labels() -> void:
	for cell in tile_map.get_used_cells(0):
		var debug_label = DEBUG_LABEL.instantiate()
		debug_label.position = tile_map.map_to_local(cell)
		debug_label.text = str(cell.x, ',', cell.y, '  ', debug_label.position.x, ',', debug_label.position.y)
		add_child(debug_label)
