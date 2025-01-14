extends Node3D

@export var team: Singleton.Team = Singleton.Team.BLUE
@export var building_type: building_types = building_types.MAIN_BUILDING
@export var spawning_unit: Worker = null
@export var spawning_img: Image = null
@export_category("Building Stats")
@export var cost: int = 200
@export var max_units: int = 4
@export var current_units_created: int = 0
@export var health: float = 100.0

@onready var selection_ring: MeshInstance3D = %SelectionRing
@onready var unit_destination: MeshInstance3D = %UnitDestination
@onready var unit_spawn_point: Marker3D = %UnitSpawnPoint



enum building_types{MAIN_BUILDING, UNIT_BUILDING}

var units_to_spawn: Array = []
var units_images: Array = []
var unit_building
var under_contruction: bool = false
var can_build: bool = true


var progress_start: = 10.0
var active: bool = false
var is_rotating: bool = false


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
