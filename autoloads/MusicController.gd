extends Node

var main_music = load("res://resources/music/placeholder.wav")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func play_music():
	if !$Music.playing:
		$Music.stream = main_music
		$Music.play()
