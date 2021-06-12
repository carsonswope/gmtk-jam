extends Node2D

const GameState = preload("res://GameState.gd")

const Pin = preload("res://Pin.tscn")

export var num_placeable_pins = 2

#var init_placed_pins_positions = []
var placed_pins = []
var placed_platform_positions = []

var current_game_state

var moving_platform = null
var moving_platform_idx
var moving_platform_start_pos
var moving_platform_start_mouse_pos


var placing_pin = false
var placing_pin_original_position = null
var placing_pin_init_position = null
var placing_pin_icon

var placed_pins_init_positions

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	$layout.pause_mode = PAUSE_MODE_STOP
	set_game_state(GameState.LEVEL_START)
	
	for p in get_tree().get_nodes_in_group("PlatformContainers"):
		placed_platform_positions.append(p.position)
		
	var pin = Pin.instance()
	placing_pin_icon = pin.get_node("icon")
	pin.remove_child(placing_pin_icon)
	add_child(placing_pin_icon)
	
	placing_pin_icon.position = Vector2(-20, -20)

func is_completed():
	return $layout/NextLevel.completed

func set_game_state(s):
	
	if s == GameState.LEVEL_START:
		$layout.get_tree().paused = true
	elif s == GameState.LEVEL_PAUSED:
		$layout.get_tree().paused = true
	elif s == GameState.LEVEL_RUNNING:
		#if placed_pins_init_positions == null:
		#	var placed_pins_init_positions = []
		#	for p in placed_pins:
		#		placed_pins_init_positions.append(p.initial_position)
		#	return placed_pins_init_positions
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

func get_initial_platform_placements():
	return placed_platform_positions

func get_initial_pin_placements():
	var ps = []
	for p in placed_pins:
		ps.append(p.initial_position)
	return ps

func place_platforms(positions):
	placed_platform_positions = positions.duplicate()
	var platforms = get_tree().get_nodes_in_group("PlatformContainers")
	assert(platforms.size() == placed_platform_positions.size())
	for i in range(positions.size()):
		platforms[i].position = positions[i]

func place_pins(positions):
	assert(positions.size() <= num_placeable_pins)
	assert(placed_pins.size() == 0)
	for p in positions:
		place_pin(p, p)

func place_pin(pos, initial_position=Vector2(0, 0)):
	var pin = Pin.instance()
	pin.position = pos
	pin.initial_position = initial_position
	add_child(pin)
	placed_pins.append(pin)
	placing_pin = false
	placing_pin_original_position = null


func pin_clicked(mouse_position):
	for i in range(placed_pins.size()):
		var pin = placed_pins[i]
		if sqrt((pin.position - mouse_position).dot(pin.position - mouse_position)) < 10:
			return i
	return -1

func _unhandled_input(e):
	# only concerned with mouse clicks..
	if not e is InputEventMouseButton:
		return
		
	var mouse_position = get_viewport().get_mouse_position()
	
	# left mouse click!
	if e.button_index == BUTTON_LEFT and e.is_pressed():

		# putting a pin down..
		if placing_pin:
			var init_position
			if current_game_state == GameState.LEVEL_START or not placing_pin_init_position:
				init_position = mouse_position
			else:
				init_position = placing_pin_init_position
			place_pin(mouse_position, init_position)
		
		# pickin a pin up..
		elif pin_clicked(mouse_position) > -1:
			var clicked_pin_idx = pin_clicked(mouse_position)
			placing_pin_original_position = placed_pins[clicked_pin_idx].position
			placing_pin_init_position = placed_pins[clicked_pin_idx].initial_position
			remove_child(placed_pins[clicked_pin_idx])
			placed_pins.remove(clicked_pin_idx)
			placing_pin = true

		# if in game start mode, check to see if the click was on a container
		elif current_game_state == GameState.LEVEL_START:
			# if not currently moving a platform, check to see if the click is on a platform
			if moving_platform == null:
				var i = 0
				var platforms = get_tree().get_nodes_in_group("PlatformContainers")
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
			# only reset pin back to original when level is still not moving
			if placing_pin_original_position and current_game_state == GameState.LEVEL_START:
				place_pin(placing_pin_original_position)
					
			else:
				placing_pin = false
			
			placing_pin_icon.position = Vector2(-20, -20)
			
		# right click to 'reset' platform move
		elif current_game_state == GameState.LEVEL_START:
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
