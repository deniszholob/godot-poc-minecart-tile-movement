class_name MineCartDebugInfo

var face_direction: Vector2i = Vector2i.ZERO
var intended_relative_direction: Vector2i = Vector2i.ZERO
var next_tile: Vector2i = Vector2i.ZERO

func _init(face_direction: Vector2i, intended_relative_direction: Vector2i , next_tile: Vector2i ) -> void:
	self.face_direction = face_direction
	self.intended_relative_direction = intended_relative_direction
	self.next_tile = next_tile
