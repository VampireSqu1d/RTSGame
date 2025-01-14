extends Node3D

signal units_selected(units: Array)

@export var MOVE_MARGIN: int = 20
@export var MOVE_SPEED: int = 15
@export var team: Singleton.Team = Singleton.Team.BLUE
@export var units_in_circle: = 4
@export var units_in_line: = 4
@export var selected_units_limit: int = 24
@onready var camera: Camera3D = %Camera3D
@onready var unit_selector: Control = %UnitSelector

const ray_length: int = 1000
var selected_units: Array = []
var old_selected_units: Array = []
var start_select_pos: = Vector2()

var mouse_pos: = Vector2()

var target_position_list: Array[Vector3] = []
var unit_position_index: int = 0

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	mouse_pos = get_viewport().get_mouse_position()
	camera_movement(delta)
	if Input.is_action_just_pressed("command"):
		move_selected_untis()
	if Input.is_action_just_pressed("select"):
		unit_selector.start_pos = mouse_pos
		start_select_pos = mouse_pos
	if Input.is_action_just_released("select"):
		select_units()
	if Input.is_action_pressed("select"):
		unit_selector.mouse_pos = mouse_pos
		unit_selector.is_visible_local = true
	else:
		unit_selector.is_visible_local = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("wheel_down"):
		camera.fov = lerp(camera.fov, 75.0, 0.25)
	if event.is_action_pressed("wheel_up"):
		camera.fov = lerp(camera.fov, 05.0, 0.25)


func camera_movement(delta: float) -> void:
	var viewpost_size: Vector2 = get_viewport().size
	var origin: Vector3 = global_transform.origin
	var move_vector: = Vector3()
	
	if origin.x >= -62:
		if mouse_pos.x < MOVE_MARGIN:
			move_vector.x -= 1
	if origin.z >= -65:
		if mouse_pos.y < MOVE_MARGIN:
			move_vector.z -= 1
	if origin.x < 62:
		if mouse_pos.x > viewpost_size.x - MOVE_MARGIN:
			move_vector.x += 1
	if origin.x < 90:
		if mouse_pos.y > viewpost_size.y - MOVE_MARGIN:
			move_vector.z += 1
	
	move_vector = move_vector.rotated(Vector3(0, 1, 0), rad_to_deg(rotation.y))
	global_translate(move_vector * delta * MOVE_SPEED)


func mouse_raycast(collision_mask) -> Dictionary:
	var ray_start : Vector3 = camera.project_ray_origin(mouse_pos)
	var ray_end: Vector3 = ray_start + camera.project_ray_normal(mouse_pos) * ray_length
	var space_state = get_world_3d().direct_space_state
	var prqp: = PhysicsRayQueryParameters3D.new()
	
	prqp.from = ray_start
	prqp.to = ray_end
	prqp.collision_mask = collision_mask
	prqp.exclude = []
	return space_state.intersect_ray(prqp)


func get_unit_under_mouse() -> Node3D:
	var result_unit: Dictionary = mouse_raycast(2) # Physics layer 2 is for units
	if result_unit:
		print(result_unit)
	#var unit: Worker = result_unit["collider"]
	if result_unit and "team" in result_unit.collider and result_unit["collider"].team == team:
		var selected_unit =  result_unit.collider
		return selected_unit
	return null


func select_units() -> void:
	var main_unit = get_unit_under_mouse()
	if selected_units.size() != 0:
		old_selected_units = selected_units
	selected_units = []
	if mouse_pos.distance_squared_to(start_select_pos) < 16:
		if main_unit != null:
			selected_units.append(main_unit)
	else:
		selected_units = get_units_in_box(start_select_pos, mouse_pos)
	if selected_units.size() != 0:
		update_current_units(selected_units)
		units_selected.emit(selected_units)
	elif selected_units.size() == 0:
		selected_units = old_selected_units


func update_current_units(new_units) -> void:
	for unit in get_tree().get_nodes_in_group("units"):
		unit.deselect()
	for unit in new_units:
		unit.select()


func move_selected_untis() -> void: 
	var result = mouse_raycast(0b110)# 0b10111
	unit_position_index = 0
	if selected_units.size() > 0:
		if result.collider.is_in_group("surface"):
			for unit: Worker in selected_units:
				position_unit(unit, result)


func get_units_in_box(top_left: Vector2, bottom_right: Vector2) -> Array[Node3D]:
	if top_left.x > bottom_right.x:
		var temp = top_left.x
		top_left.x = bottom_right.x
		bottom_right.x = temp
	if top_left.y > bottom_right.y:
		var temp = top_left.y
		top_left.y = bottom_right.y
		bottom_right.y = temp
	
	var box = Rect2(top_left, bottom_right - top_left)
	
	var box_selcted_untis: Array[Node3D] = []
	
	for unit: Node3D in get_tree().get_nodes_in_group("units"):
		if unit.team == team and box.has_point(camera.unproject_position(unit.global_transform.origin)):
			if selected_units_limit != 0:
				if box_selcted_untis.size() <= selected_units_limit:
					box_selcted_untis.append(unit)
			else:
				box_selcted_untis.append(unit)
	return box_selcted_untis


func create_units_circle_position(target_pos: Vector3, units_num: int) -> Array[Vector3]:
	var positions_list: Array[Vector3] = []
	var radius: float = 1.0
	var center: Vector2 = Vector2(target_pos.x, target_pos.z)
	var max_units_in_circle: = units_in_circle
	var angle_step: = PI * 2 / max_units_in_circle
	var angle: float = 0
	var unit_count: int = 0
	for i in range(0, units_num):
		if (unit_count == max_units_in_circle):
			radius += 1.0
			unit_count = 0
			angle = 0
			max_units_in_circle *= 2
			angle_step = 2 * PI / max_units_in_circle
		var direction = Vector2(cos(angle), sin(angle))
		var pos = center + direction * radius
		var pos3d = Vector3(pos.x, 0, pos.y)
		positions_list.append(pos3d)
		unit_count += 1
		angle += angle_step
	return positions_list


func create_units_rect_position(target_pos: Vector3, units_num: int) -> Array[Vector3]:
	var line_position_list : Array[Vector3] = []
	var positions_list: Array[Vector3] = []
	var new_target_pos = target_pos
	var z_pos: = 1
	var x_pos: = 1
	@warning_ignore("integer_division")
	var num_of_lines = ceil(units_num/units_in_line)
	for i in units_in_line:
		line_position_list.append(new_target_pos)
		positions_list.append(new_target_pos)
		new_target_pos = Vector3(target_pos.x + x_pos, target_pos.y, target_pos.z)
		if i%2 == 1:
			x_pos -=1
		x_pos = -x_pos
	
	for i in num_of_lines:
		for k in units_in_line:
			var new_pos = Vector3(line_position_list[k].x, line_position_list[k].y, line_position_list[k].z + z_pos)
			positions_list.append(new_pos)
		if i%2 == 1:
			z_pos -= 1
		z_pos = -z_pos
	
	return positions_list


func position_unit(unit: Worker, result):
	target_position_list = create_units_rect_position(result.position, len(selected_units))
	unit.move_to(target_position_list[unit_position_index])
	unit_position_index += 1
