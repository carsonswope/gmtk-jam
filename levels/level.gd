extends Node2D

const GameState = preload("res://GameState.gd")

const Pin = preload("res://Pin.tscn")

export var num_placeable_pins = 2

var player_initial_position

var init_placed_pins = []
var placed_pins = []
var placed_platform_positions = []

var current_game_state

var moving_platform = null
var moving_platform_idx
var moving_platform_start_pos
var moving_platform_start_mouse_pos

var placing_pin = null
var placing_pin_icon = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	$layout.pause_mode = PAUSE_MODE_STOP
	set_game_state(GameState.LEVEL_START)
	
	for p in get_tree().get_nodes_in_group("PlatformContainers"):
		placed_platform_positions.append(p.position)
		
	player_initial_position = $layout/Player.position

func is_completed():
	return $layout/NextLevel.completed

func set_game_state(s):
	
	if s == GameState.LEVEL_START:
		# reset to initial conditions!
		#if placed_platform_positions.size():
		#	var i = 0
		#	for p in get_tree().get_nodes_in_group("PlatformContainers"):
		#		p.position = placed_platform_positions[i]
		#		i += 1
			#print('hi')
		
			
		if current_game_state == GameState.LEVEL_RUNNING:
			
			$layout/Player.position = player_initial_position
			
			if placed_platform_positions.size():
				var i = 0
				for p in get_tree().get_nodes_in_group("PlatformContainers"):
					p.position = Vector2(0, 0)
					p.get_node("body").position = p.initial_position
					p.get_node("body").rotation = p.initial_rotation
					p.get_node("body").linear_velocity = placed_platform_positions[i]
					p.get_node("body").angular_velocity = 0
					
					p.get_node("tiles").position = p.initial_position
					p.get_node("tiles").rotation = p.initial_rotation
					
					i += 1
				print('hi')
		$layout.get_tree().paused = true
	elif s == GameState.LEVEL_PAUSED:
		$layout.get_tree().paused = true
	elif s == GameState.LEVEL_RUNNING:
		$layout.get_tree().paused = false
	current_game_state = s

func player_out_of_bounds():
	return $layout/Player.position.y > 1000

func clear_moving_platform():
	moving_platform = null
	moving_platform_idx = null
	moving_platform_start_pos = null
	moving_platform_start_mouse_pos = null

func num_unplaced_pins():
	return num_placeable_pins - placed_pins.size()

func place_new_pin():
	if placing_pin:
		return
	
	placing_pin = Pin.instance()
	placing_pin_icon = placing_pin.get_node("icon")
	placing_pin.remove_child(placing_pin_icon)
	add_child(placing_pin_icon)

func _unhandled_input(e):
	# only concerned with mouse clicks..
	if not e is InputEventMouseButton:
		return
	# left mouse click!
	if e.button_index == BUTTON_LEFT and e.is_pressed():

		if placing_pin:
			remove_child(placing_pin_icon)
			placing_pin.add_child(placing_pin_icon)
			placing_pin.position = placing_pin_icon.position
			placing_pin_icon.position = Vector2(0, 0)
			add_child(placing_pin)
			placed_pins.append(placing_pin)
			placing_pin = null
			placing_pin_icon = null
		
		# if in game start mode, check to see if the click was on a container
		elif current_game_state == GameState.LEVEL_START:
			# if not currently moving a platform, check to see if the click is on a platform
			if moving_platform == null:
				var i = 0
				var platforms = get_tree().get_nodes_in_group("PlatformContainers")
				var mouse_position = get_viewport().get_mouse_position()
				clear_moving_platform()
				for p in platforms:
					if p.coords_in_platform(mouse_position):
						moving_platform_idx = i
						moving_platform = p
						moving_platform_start_pos = p.position
						moving_platform_start_mouse_pos = mouse_position
						return
					i += 1

			# currently moving a platform - snap platform to intented position
			else:
				var new_platform_position = moving_platform_start_pos + (get_viewport().get_mouse_position() - moving_platform_start_mouse_pos)
				moving_platform.position = new_platform_position
				#p_idx = get_tree().get_nodes_in_group("PlatformContainers").
				placed_platform_positions[moving_platform_idx] = new_platform_position
				clear_moving_platform()
	
	# right mouse click! reset/cancel the stuff
	elif e.button_index == BUTTON_RIGHT and e.is_pressed():
		# reset pin placement..
		if placing_pin:
			placing_pin = null
			remove_child(placing_pin_icon)
			placing_pin_icon = null
			
		# right click to 'reset' platform move
		if current_game_state == GameState.LEVEL_START:
			if moving_platform:
				moving_platform.position = moving_platform_start_pos
				clear_moving_platform()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if placing_pin:
		placing_pin_icon.position = get_viewport().get_mouse_position()
	
	if current_game_state == GameState.LEVEL_START:
		if moving_platform:
			var mouse_pos = get_viewport().get_mouse_position()
			moving_platform.position = moving_platform_start_pos + (mouse_pos - moving_platform_start_mouse_pos)
