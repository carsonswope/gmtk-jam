extends KinematicBody2D

var score : int = 0
var speed : int = 200
var jumpForce : int = 600
var gravity : int = ProjectSettings.get_setting("physics/2d/default_gravity")
var floor_angle : float = PI/6.0;
var vel : Vector2 = Vector2()
var moving_right : bool = true
var jump_height : float = 30

onready var sprite : AnimatedSprite = get_node("FullBody/Sprite")
onready var hat : Sprite = get_node("FullBody/Hat")
onready var body: Node2D = get_node("FullBody")

func _ready():
	hat.offset = Vector2(-10 if sprite.flip_h else 10, 0.0)

func _physics_process(delta):
	vel.x = 0
	
	vel.x += speed if moving_right else -speed
	
	vel = move_and_slide(vel, Vector2.UP, false, 4, floor_angle, false)
	
	vel.y += gravity * delta
	
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
		if hit_wall:
			if (!hit_floor):
				normal = Vector2.UP
			var curr_move_angle = atan2(normal.y,normal.x) + (PI/2 if moving_right else -PI/2)
			var curr_move_vector = Vector2(sin(curr_move_angle),cos(curr_move_angle))
			if (!test_move(transform,(curr_move_vector*speed + Vector2.UP * jump_height)*delta)):
				var jump_vel = sqrt(2.0 / 3.0 * jump_height * 2.0 * gravity) # jump to twice the jump height
				#play jump sound
				vel.y = -jump_vel
			else:
				moving_right = !moving_right
	else:
		body.rotation = max(0,abs(body.rotation)-PI/30.0)*sign(body.rotation)
	
	if vel.x < 0:
		sprite.animation = "walk"
		sprite.playing = true
		sprite.flip_h = true
	elif vel.x > 0:
		sprite.animation = "walk"
		sprite.playing = true
		sprite.flip_h = false
	else:
		sprite.animation = "walk"
		sprite.playing = false
		sprite.frame = 3
	hat.offset = Vector2(-10 if sprite.flip_h else 10, 0.0)
