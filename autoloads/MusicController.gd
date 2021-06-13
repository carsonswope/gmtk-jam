extends Node

var main_music = load("res://resources/music/placeholder.wav")
var fx = {
	"place_pin": load("res://resources/music/Sound Design/Game Sounds/Screwing Sounds/screwin2.wav"),
	"pickup_pin": load("res://resources/music/Sound Design/Game Sounds/Screwing Sounds/screwin3.wav")
}
	
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum tracks {
	SONG_1,
	SONG_2
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func play_fx(fx_name = ""):
	if fx_name in fx:
		$FX.stream = fx[fx_name]
		$FX.play()

func play_music(song = ""):
	if !$Music.playing:
		$Music.stream = main_music
		#$Music.play()
