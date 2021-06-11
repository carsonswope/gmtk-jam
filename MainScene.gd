extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	
	var p0 = preload("res://TilePlatform.tscn").instance()
	var p0_shape = [
		'xx  ',
		'x   ',
		'xxxx'
	]
	p0.initialize(p0_shape, false)
	p0.position.y = 350
	p0.position.x = 100
	add_child(p0)
	
	var p1 = preload("res://TilePlatform.tscn").instance()
	var p1_shape = [
		' xx ',
		'  x ',
		'xxxx'
	]
	p1.initialize(p1_shape, true)
	p1.position.y = 150
	p1.position.x = 600
	add_child(p1)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
