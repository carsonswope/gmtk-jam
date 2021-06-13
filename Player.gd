extends KinematicBody2D

var score : int = 0
var speed : int = 180
var jumpForce : int = 600
var gravity : int = ProjectSettings.get_setting("physics/2d/default_gravity")
var floor_angle : float = PI/4.0;
var vel : Vector2 = Vector2()
var moving_right : bool = true
var jump_height : float = 40

var time_til_next_jump = null
onready var sprite : AnimatedSprite = get_node("FullBody/Sprite")
onready var hat : Sprite = get_node("FullBody/Hat")
onready var body: Node2D = get_node("FullBody")

func _ready():
	hat.offset = Vector2(-10 if sprite.flip_h else 10, 0.0)

func _physics_process(delta):
	if time_til_next_jump:
		time_til_next_jump -= delta
		if time_til_next_jump <0:
			time_til_next_jump = null
	
	vel.x = 0
	
	vel.x += speed if moving_right else -speed
	
	vel = move_and_slide(vel, Vector2.UP, false, 4, floor_angle, false)
	
	vel.y += gravity * delta
	
	var hit_wall = false
	var hit_floor = false
	if get_slide_count() > 0:
		var normal = Vector2(0.0,0.0)
		for i in range(0,get_slide_count()):
			var this_collision = get_slide_collision(i)
			var this_normal = this_collision.normal
			if (this_collision.collider.get_parent().is_in_group("PlatformContainers")):
				var offset = this_collision.position - this_collision.collider.position
				this_collision.collider.apply_impulse(offset, -this_normal * 20)
			
			if abs(asin(this_normal.cross(Vector2.UP))) / (this_normal.length() * Vector2.UP.length()) <= (floor_angle): #ignore steeper slopes
				hit_floor = true
				normal = normal + this_normal
			else:
				hit_wall = true
		if hit_floor:
			body.rotation = -asin(normal.cross(Vector2.UP) / (normal.length() * Vector2.UP.length()))
		if hit_wall:
			normal = Vector2.UP
			var curr_move_angle = atan2(normal.y,normal.x) + (PI/2 if moving_right else -PI/2)
			var curr_move_vector = Vector2(cos(curr_move_angle),sin(curr_move_angle))
			var jump_vel = sqrt(4.0 / 3.0 * jump_height * gravity)
			print (jump_vel)
			var jump_vector = Vector2(curr_move_vector.x*speed * jump_vel/gravity,-jump_vel).normalized()*40
			print (jump_vector)
			if (!time_til_next_jump and !test_move(Transform2D(0.0,position + jump_vector),Vector2(0,0),false)):
				time_til_next_jump = 0.5
				#play jump sound
				print ("jumping")
				vel.y = -jump_vel
			else:
				moving_right = !moving_right
	else:
		body.rotation = max(0,abs(body.rotation)-PI/30.0)*sign(body.rotation)
	
	if vel.x < 0:
		sprite.animation = "walk"
		sprite.playing = true
	elif vel.x > 0:
		sprite.animation = "walk"
		sprite.playing = true
	else:
		sprite.animation = "walk"
		sprite.playing = false
		sprite.frame = 3
	hat.offset = Vector2(-10 if sprite.flip_h else 10, 0.0)
	sprite.flip_h = !moving_right
