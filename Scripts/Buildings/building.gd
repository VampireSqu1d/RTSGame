class_name Building extends StaticBody3D

@export var team: Singleton.Team = Singleton.Team.BLUE
@export var building_type: building_types = building_types.MAIN_BUILDING
@export var spawning_unit: PackedScene = preload("res://Scenes/worker.tscn")
@export var unit_img: Texture = preload("res://Assets/GUI/MainBuildingImg.jpg")
@export var spawning_img: Texture = null
@export_category("Building Stats")
@export var cost: int = 200
@export var max_units: int = 4
@export var current_units_created: int = 0
@export var health: float = 100.0

@onready var selection_ring: MeshInstance3D = %SelectionRing
@onready var unit_destination: MeshInstance3D = %UnitDestination
@onready var unit_spawn_point: Marker3D = %UnitSpawnPoint
@export var units_h_box: HBoxContainer
@export var unit_progress_bar: ProgressBar
@export var unit_progress_container: CanvasLayer
@onready var nav_mesh = get_parent()


enum building_types{MAIN_BUILDING, UNIT_BUILDING}

var units_to_spawn: Array = []
var units_images: Array = []
var unit_building
var under_contruction: bool = false
var can_build: bool = true

#const worker_unit


var progress_start: = 10.0
var active: bool = false
var is_rotating: bool = false


const unit_img_button = preload("res://Scenes/GUI/unit_img_button.tscn")
var new_tween: Tween
var tween_callable_spawn_unit: = Callable(self, "spawn_unit")
var tween_callable_spawn_repeat: = Callable(self, "spawn_repeat")


func _ready() -> void:
	add_to_group("units")
	selection_ring.material_override = Singleton.team_colors[team]
	unit_destination.position = unit_spawn_point.position + Vector3(0.1, 0, 0.1)


func select() -> void:
	selection_ring.show()
	unit_destination.show()


func deselect() -> void:
	selection_ring.hide()
	unit_destination.hide()


func add_unit_to_spawn(unit: Unit) -> void:
	if current_units_created < max_units:
		var unit_img: TextureButton = unit_img_button.instantiate()
		unit_img.texture_normal = spawning_img
		current_units_created += 1
		units_h_box.add_child(unit_img)
		var callable = Callable(self, "cancel_unit")
		unit_img.pressed.connect(callable.bind(unit_img, unit))
		units_images.append(unit_img)
		units_to_spawn.append(unit)
		if current_units_created == 1:
			new_tween = get_tree().create_tween()
			new_tween.tween_property(unit_progress_bar, "value", 100.0, 3)
			spawn_repeat()
			unit_progress_container.show()


func spawn_repeat() -> void:
	new_tween.finished.connect(tween_callable_spawn_unit)


func spawn_unit() -> void:
	new_tween.stop()
	var unit: Unit = spawning_unit.instantiate()
	units_to_spawn.remove_at(0)
	units_images.remove_at(0)
	units_h_box.get_child(0).queue_free()
	var spawn_position = NavigationServer3D \
	.map_get_closest_point(\
	get_world_3d()\
	.get_navigation_map(), unit_spawn_point.global_transform.origin)
	nav_mesh.add_child(unit)
	unit.global_transform.origin
	unit.move_to(unit_destination.global_transform.origin)
	unit_progress_bar.value = 0.0
	current_units_created -= 1
	if current_units_created >= 1:
		new_tween.play()
		new_tween.tween_callback(tween_callable_spawn_repeat)
	finish_spawning()


func finish_spawning() -> void:
	if current_units_created == 0:
		new_tween.kill()
		unit_progress_container.hide()
	else:
		unit_progress_container.show()
	


func cancel_unit(img, unit: Unit) -> void:
	if units_images[0] == img:
		unit_progress_bar.value = 0
		new_tween.stop()
		new_tween.play()
	units_to_spawn.erase(unit)
	unit.queue_free()
	units_images.erase(img)
	img.queue_free()
	current_units_created -= 1
	finish_spawning()
