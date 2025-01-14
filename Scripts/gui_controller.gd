extends Control

@onready var units_grid: GridContainer = %UnitsGrid

var unit_img_button: = preload("res://Scenes/unit_img_button.tscn")
var current_selected_untis: Array = []

func _on_rts_controller_units_selected(units: Array) -> void:
	current_selected_untis = units
	for n in units_grid.get_children():
		n.queue_free()
		#units_grid.remove_child(n)
	
	for i in units.size():
		var img_button = unit_img_button.instantiate()
		units_grid.add_child(img_button)
