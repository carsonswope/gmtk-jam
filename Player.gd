extends KinematicBody2D

var score : int = 0
var speed : int = 200
var jumpForce : int = 600
var gravity : int = 900
var floor_angle : float = PI/9.0;
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
	
	vel = move_and_slide(vel, Vector2.UP, false, 4, floor_angle, false)
	
	vel.y += gravity * delta
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			vel.y -= jumpForce
	var hit_wall = false
	var hit_floor = false
	if get_slide_count() > 0:
		var normal = Vector2(0.0,0.0)
		for i in range(0,get_slide_count()):
			var this_normal = get_slide_collision(i).normal
			if abs(asin(this_normal.cross(Vector2.UP))) / (this_normal.length() * Vector2.UP.length()) <= (floor_angle): #ignore steeper slopes
				hit_floor = true
				normal = normal + this_normal
			else:
				hit_wall = true
		if hit_floor:
			body.rotation = -asin(normal.cross(Vector2.UP) / (normal.length() * Vector2.UP.length()))
	else:
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
	hat.offset = Vector2(-10 if sprite.flip_h else 10, 0.0)
