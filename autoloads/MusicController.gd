extends Node

var music = {
	"bigbad": load("res://resources/music/Mastered OST Oggs/bigbad_80.ogg"),
	"birth": load("res://resources/music/Mastered OST Oggs/birthofalargeboy_80.ogg"),
	"danger": load("res://resources/music/Mastered OST Oggs/danger_131.ogg"),
	"eight": load("res://resources/music/Mastered OST Oggs/eight.ogg"),
	"exploration": load("res://resources/music/Mastered OST Oggs/exploration_106.ogg"),
	"percolating": load("res://resources/music/Mastered OST Oggs/percolating_80.ogg"),
	"specialzone": load("res://resources/music/Mastered OST Oggs/specialzone_80.ogg"),
	"theboard": load("res://resources/music/Mastered OST Oggs/theboard_80.ogg"),
}
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
		load("res://resources/music/Sound Design - Mastered oggs/Pin out pool/pinout6.ogg"),		],
	"walk_sound":		
		[load("res://resources/music/Sound Design - Mastered oggs/Crackles pool/crackles1.ogg"),		
		load("res://resources/music/Sound Design - Mastered oggs/Crackles pool/crackles2.ogg"),		
		load("res://resources/music/Sound Design - Mastered oggs/Crackles pool/crackles3.ogg")],
	"click_sound":
		[load("res://resources/music/Sound Design - Mastered oggs/Click pool/click1.ogg"),		
		load("res://resources/music/Sound Design - Mastered oggs/Click pool/click2.ogg"),		
		load("res://resources/music/Sound Design - Mastered oggs/Click pool/click3.ogg"),		]
}

var curr_fx = null
var curr_song = null
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
			curr_fx = fx_name
			var pool = fx[fx_name]
			var stream = pool[rng.randi_range(0,pool.size()-1)]
			stream.loop = false
			$FX.stream = stream
			$FX.play()

func stop_fx(fx_name = ""):
	if curr_fx == fx_name:
		$FX.stop()

func play_music(song = ""):
	if !$Music.playing or song != curr_song:
		if song in music:
			$Music.stream = music[song]
			$Music.stream.loop = true
			$Music.play()
