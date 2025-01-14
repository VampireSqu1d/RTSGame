extends Node


enum Team{RED, BLUE}

var team_colors : Dictionary = {
	Team.BLUE: preload("res://Assets/Materials/TeamBlueMat.tres"),
	Team.RED: preload("res://Assets/Materials/TeamRedMat.tres")
}
