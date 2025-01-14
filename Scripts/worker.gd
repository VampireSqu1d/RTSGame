class_name Worker extends RigidBody3D

@export var team: Singleton.Team = Singleton.Team.BLUE
@export var speed: float = 0
@export var vel: Vector3
var state_machine: AnimationNodeStateMachinePlayback


enum states {IDLE, WALKING, ATTACKING, MINING, BUILDING}
var current_state = states.IDLE

@onready var animation_tree: AnimationTree = %AnimationTree
@onready var selection_ring: MeshInstance3D = %SelectionRing
@onready var navigation_agent_3d: NavigationAgent3D = %NavigationAgent3D
@onready var ray_cast_3d: RayCast3D = %RayCast3D
@onready var armature: Node3D = $StoneUnit/Armature






func _ready() -> void:
	state_machine = animation_tree["parameters/playback"]
	selection_ring.material_override = Singleton.team_colors[team]


func _process(delta: float) -> void:
	var target = navigation_agent_3d.get_next_path_position()
	var pos = global_transform.origin
	
	var normal = ray_cast_3d.get_collision_normal()
	if normal.length_squared() < 0.001:
		normal = Vector3(0,1,0)
	
	vel = (target - pos).slide(normal).normalized() * speed
	armature.rotation.y = lerp_angle(armature.rotation.y, atan2(vel.x, vel.z), delta * 10)
	
	navigation_agent_3d.velocity = vel


func select():
	selection_ring.show()


func deselect():
	selection_ring.hide()


func change_state(state: String) -> void:
	match state:
		"idle":
			current_state = states.IDLE
			speed = 0.000001
			state_machine.travel("Idle")
		"walking":
			current_state = states.WALKING
			speed = 2
			state_machine.travel("Walk")


func move_to(target_pos: Vector3):
	change_state("walking")
	var closest_pos = NavigationServer3D.map_get_closest_point(get_world_3d().navigation_map, target_pos)
	navigation_agent_3d.target_position = closest_pos

func _on_navigation_agent_3d_target_reached() -> void:
	state_machine.travel("Idle")


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	linear_velocity = safe_velocity
