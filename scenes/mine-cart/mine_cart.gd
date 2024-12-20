@tool
# Hold top level info like the tilemap, control scheme and debug info
class_name MineCart extends CharacterBody2D

#region signal
#regionend

#region const
const WARN_REQ_tile_map: String = "Missing TileMap"
#endregion

#region enum
const MineCartControlScheme = GlobalGame.MineCartControlScheme
const GameControlObjects = GlobalGame.GameControlObjects
#endregion

#region @export
@export_category("TileMap")
## Tilemap that contains rail tiles for the minecart
@export var tile_map: TileMap:
	set(v):
		tile_map = v
		if(Engine.is_editor_hint()): update_configuration_warnings()
## What layer in the tile map are rails for the minecart are on
@export var rail_layer: int = 0

@export_category("Debug")
@export var debug_enable: bool = true:
	set(v):
		debug_enable = v
		_disable_debug_node(debug_tile_select)
		_disable_debug_node(debug_face_direction_ray)
		_disable_debug_node(debug_intended_relative_direction_ray)
#endregion

#region @onready
@onready var debug_face_direction_ray: RayCast2D = $MineCartDebug/FaceDirectionRay:
	set(v):
		debug_face_direction_ray = v
		debug_face_direction_ray.modulate = Color.from_ok_hsl(200, 100, 80) # Blue
@onready var debug_intended_relative_direction_ray: RayCast2D = $MineCartDebug/IntendedDirectionRay:
	set(v):
		debug_intended_relative_direction_ray = v
		debug_intended_relative_direction_ray.modulate = Color.from_ok_hsl(10, 100, 80) # Red
@onready var debug_tile_select: Node2D = $MineCartDebug/TileSelectNode2D
@onready var lights: Node2D = $Pivot/Lights
#endregion

#region var
# Change through some game menu screen via global game state
var control_scheme: MineCartControlScheme = MineCartControlScheme.Character
var enabled: bool = false
#endregion

#region func: Overrides
# Shows warnings in editor
func _get_configuration_warnings() -> PackedStringArray:
	var warnings:= PackedStringArray()
	if(!tile_map): warnings.append(WARN_REQ_tile_map)
	return warnings

func _ready() -> void:
	if(Engine.is_editor_hint()): return
	GlobalGame.minecart_control_scheme_updated.connect(self.set_control_scheme)
	GlobalGame.control_object_changed.connect(self._enable_minecart)

func _process(delta: float) -> void:
	if(Engine.is_editor_hint()): return
	lights.visible = GlobalGame.show_lights
	debug_enable = GlobalGame.show_debug
#endregion

#region func: Public
func on_debug_update(debug_info: MineCartDebugInfo) -> void:
	if debug_info.face_direction.length() > 0:
		debug_face_direction_ray.target_position = debug_info.face_direction * tile_map.tile_set.tile_size
	debug_intended_relative_direction_ray.target_position = debug_info.intended_relative_direction * tile_map.tile_set.tile_size
	debug_tile_select.global_position = tile_map.map_to_local(debug_info.next_tile)

func set_control_scheme(control:MineCartControlScheme):
	control_scheme = control
#endregion

#region func: Private
func _disable_debug_node(node: Node2D) -> void:
	if(!node): return
	node.visible = debug_enable
	node.process_mode = Node.PROCESS_MODE_INHERIT if debug_enable else Node.PROCESS_MODE_DISABLED

func _enable_minecart(control:GameControlObjects):
	enabled = control == GameControlObjects.Minecart
#endregion
