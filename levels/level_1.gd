extends Node2D

const TilePlatform = preload("res://TilePlatform.tscn")

export var complete = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#MusicController.play_music()
	
	var p0 = TilePlatform.instance()
	add_child(p0)
	var p0_shape = [
		'xxxxxxxx',
	]
	p0.initialize(p0_shape, true)
	p0.position.y = 50
	p0.position.x = 300


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
