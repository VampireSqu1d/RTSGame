extends Node

enum Unit{WORKER, WARRIOR}
enum Building{MAIN}
enum Team{RED, BLUE}

var team_colors : Dictionary = {
	Team.BLUE: preload("res://Assets/Materials/TeamBlueMat.tres"),
	Team.RED: preload("res://Assets/Materials/TeamRedMat.tres")
}


const main_building_scene: PackedScene = preload("res://Scenes/main_building.tscn")
const unit_building_scene: PackedScene = preload("res://Scenes/unit_building.tscn")
const worker_scene: PackedScene = preload("res://Scenes/worker.tscn")
const warrior_scene: PackedScene = preload("res://Scenes/warrior.tscn" )
