extends Node

var states = ["level_start","level_running","level_paused","death"]
var current_state

func _ready():
	current_state = "level_start"
