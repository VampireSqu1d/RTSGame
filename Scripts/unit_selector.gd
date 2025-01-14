extends Control

@export var select_box_color: Color = Color.AQUA
@export var select_box_border_color: Color = Color.CORNFLOWER_BLUE
@export var select_box_line_width: = 4


var is_visible_local: bool = false
var mouse_pos: Vector2 = Vector2()
var start_pos: Vector2 = Vector2()


func _draw() -> void:
	if is_visible_local and start_pos != mouse_pos:
		#var rect_size = Vector2(start_pos.x - mouse_pos.x, start_pos.y - mouse_pos.y)
		var rect_size = start_pos - mouse_pos
		var rect = Rect2(mouse_pos, rect_size)
		draw_rect(rect, select_box_color, select_box_line_width)
		draw_rect(rect, select_box_border_color, false, select_box_line_width)


func _process(_delta: float) -> void:
	queue_redraw()
