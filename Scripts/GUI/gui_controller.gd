extends Control

@onready var main_unit_img: TextureRect = %MainUnitImg
@onready var units_grid: GridContainer = %UnitsGrid
@onready var building_grid: GridContainer = %BuildingGrid
@onready var option_button: TextureButton = $SelectionBar/BuildingGrid/OptionButton
@onready var option_button_2: TextureButton = $SelectionBar/BuildingGrid/OptionButton2

var unit_img_button: PackedScene = preload("res://Scenes/unit_img_button.tscn")

const main_building_img: CompressedTexture2D = preload("res://Assets/GUI/MainBuildingImg.jpg")
const unit_building_img: CompressedTexture2D = preload("res://Assets/GUI/UnitBuildingImg.jpg")
const unit_worker_img: CompressedTexture2D = preload("res://Assets/GUI/WorkerImg.jpg")
const unit_warrior_img: CompressedTexture2D = preload("res://Assets/GUI/WarriorImg.jpg")

var current_selected_units: Array = []

var option_button_unit
var option_button_2_unit

func _on_rts_controller_units_selected(units: Array) -> void:
	current_selected_units = units
	for n in units_grid.get_children():
		n.queue_free()
		#units_grid.remove_child(n)
	
	for i in units.size():
		var img_button = unit_img_button.instantiate()
		units_grid.add_child(img_button)
		img_button.texture_normal = units[i].unit_img
	main_unit_img.texture = current_selected_units[0].unit_img
	set_button_images()


func hide_buttons() -> void:
	for button: TextureButton in building_grid.get_children():
		button.hide()


func show_buttons(active_buttons_num) -> void:
	hide_buttons()
	for i in range(active_buttons_num):
		building_grid.show()
	


func _on_option_button_pressed() -> void:
	pass # Replace with function body.


func _on_option_button_2_pressed() -> void:
	pass # Replace with function body.


func set_button_images() -> void:
	if current_selected_units[0] is MainBuilding:
		show_buttons(1)
		option_button_unit = Singleton.worker_scene
		option_button.texture_normal = unit_worker_img
	elif current_selected_units[0] is UnitBuilding:
		show_buttons(1)
		option_button_unit = Singleton.warrior_scene
		option_button.texture_normal = unit_warrior_img
	elif current_selected_units[0] is Worker:
		show_buttons(2)
		option_button_unit = Singleton.main_building_scene
		option_button.texture_normal = main_building_img
		option_button_2_unit = Singleton.unit_building_scene
		option_button_2.texture_normal = unit_building_img
	elif current_selected_units[0] is Warrior:
		show_buttons(0)
