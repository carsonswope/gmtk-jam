extends Node2D

const TilePlatform = preload("res://TilePlatform.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	MusicController.play_music()
	
	var p0 = TilePlatform.instance()
	add_child(p0)
	var p0_shape = [
		'xx  ',
		'x   ',
		'xxxx'
	]
	p0.initialize(p0_shape, true)
	p0.position.y = 0
	p0.position.x = 0
	
	var p1 = TilePlatform.instance()
	add_child(p1)	
	var p1_shape = [
		' xx ',
		'  x ',
		'xxxx'
	]
	p1.initialize(p1_shape, false)
	p1.position.y = 350
	p1.position.x = 200


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
