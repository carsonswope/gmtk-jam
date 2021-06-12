extends KinematicBody2D

var score : int = 0
var speed : int = 200
var jumpForce : int = 600
var gravity : int = 900

var vel : Vector2 = Vector2()

onready var sprite : AnimatedSprite = get_node("Sprite")
onready var hat : Sprite = get_node("Hat")
func _physics_process(delta):
	vel.x = 0
	
	if Input.is_action_pressed("move_left"):
		vel.x -= speed
	if Input.is_action_pressed("move_right"):
		vel.x += speed
	
	vel = move_and_slide(vel, Vector2.UP)
	
	vel.y += gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		vel.y -= jumpForce
	
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
