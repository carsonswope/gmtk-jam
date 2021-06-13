extends Node

var main_music = load("res://resources/music/placeholder.wav")
var fx = {
	"place_pin":		
		[load("res://resources/music/Sound Design - Mastered oggs/Pin in pool/pinin1.ogg"),		
		load("res://resources/music/Sound Design - Mastered oggs/Pin in pool/pinin2.ogg"),		
		load("res://resources/music/Sound Design - Mastered oggs/Pin in pool/pinin3.ogg"),		
		load("res://resources/music/Sound Design - Mastered oggs/Pin in pool/pinin4.ogg"),		
		load("res://resources/music/Sound Design - Mastered oggs/Pin in pool/pinin5.ogg"),		
		load("res://resources/music/Sound Design - Mastered oggs/Pin in pool/pinin6.ogg")],
	"pickup_pin":		
		[load("res://resources/music/Sound Design - Mastered oggs/Pin out pool/pinout1.ogg"),		
		load("res://resources/music/Sound Design - Mastered oggs/Pin out pool/pinout2.ogg"),		
		load("res://resources/music/Sound Design - Mastered oggs/Pin out pool/pinout3.ogg"),		
		load("res://resources/music/Sound Design - Mastered oggs/Pin out pool/pinout4.ogg"),		
		load("res://resources/music/Sound Design - Mastered oggs/Pin out pool/pinout5.ogg"),		
		load("res://resources/music/Sound Design - Mastered oggs/Pin out pool/pinout6.ogg"),		]
}

var curr_fx = null
var rng = RandomNumberGenerator.new()
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
		if (!$FX.playing or curr_fx != fx_name):
			var pool = fx[fx_name]
			var stream = pool[rng.randi_range(0,pool.size()-1)]
			stream.loop = false
			$FX.stream = stream
			$FX.play()

func play_music(song = ""):
	if !$Music.playing:
		$Music.stream = main_music
		#$Music.play()
