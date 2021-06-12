extends KinematicBody2D

var score : int = 0
var speed : int = 200
var jumpForce : int = 600
var gravity : int = 900

var vel : Vector2 = Vector2()

onready var sprite : AnimatedSprite = get_node("FullBody/Sprite")
onready var hat : Sprite = get_node("FullBody/Hat")
onready var body: Node2D = get_node("FullBody")
func _physics_process(delta):
	vel.x = 0
	
	if Input.is_action_pressed("move_left"):
		vel.x -= speed
	if Input.is_action_pressed("move_right"):
		vel.x += speed
	
	vel = move_and_slide(vel, Vector2.UP, false, 4, PI/9.0, false)
	
	vel.y += gravity * delta
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			vel.y -= jumpForce
	if get_slide_count() > 0:
		var normal = Vector2(0.0,0.0)
		for i in range(0,get_slide_count()):
			normal = normal + get_slide_collision(i).normal
		body.rotation = -asin(normal.cross(Vector2.UP) / (normal.length() * Vector2.UP.length()))
	else:
		print(body.rotation * 180/ PI)
		body.rotation = max(0,abs(body.rotation)-PI/30.0)*sign(body.rotation)
	
	if vel.x < 0:
		sprite.animation = "walk"
		sprite.playing = true
		sprite.flip_h = true
		hat.offset = Vector2(-10,0)
	elif vel.x > 0:
		sprite.animation = "walk"
		sprite.playing = true
		sprite.flip_h = false
		hat.offset = Vector2(10,0)
	else:
		sprite.animation = "walk"
		sprite.playing = false
		sprite.frame = 3
