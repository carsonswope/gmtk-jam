extends Node2D

const GameState = preload("res://GameState.gd")

var current_game_state

var moving_platform
var moving_platform_start_pos
var moving_platform_start_mouse_pos

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	$layout.pause_mode = PAUSE_MODE_STOP
	set_game_state(GameState.LEVEL_START)

func is_completed():
	return $layout/NextLevel.completed

func set_game_state(s):
	current_game_state = s
	if s == GameState.LEVEL_START:
		$layout.get_tree().paused = true
	elif s == GameState.LEVEL_PAUSED:
		$layout.get_tree().paused = true
	elif s == GameState.LEVEL_RUNNING:
		$layout.get_tree().paused = false

func clear_moving_platform():
	moving_platform = null
	moving_platform_start_pos = null
	moving_platform_start_mouse_pos = null

func _unhandled_input(e):
	# only concerned with mouse clicks..
	if not e is InputEventMouseButton:
		return
	# left mouse click!
	if e.button_index == BUTTON_LEFT and e.is_pressed():
		
		# if in game start mode, check to see if the click was on a container
		if current_game_state == GameState.LEVEL_START:
			# if not currently moving a platform, check to see if the click is on a platform
			if moving_platform == null:
				var platforms = get_tree().get_nodes_in_group("PlatformContainers")
				var mouse_position = get_viewport().get_mouse_position()
				clear_moving_platform()
				for p in platforms:
					if p.coords_in_platform(mouse_position):
						moving_platform = p
						moving_platform_start_pos = p.position
						moving_platform_start_mouse_pos = mouse_position
						return
			# currently moving a platform - snap platform to intented position
			else:
				var new_platform_position = moving_platform_start_pos + (get_viewport().get_mouse_position() - moving_platform_start_mouse_pos)
				moving_platform.position = new_platform_position
				clear_moving_platform()
	
	# right mouse click!
	elif e.button_index == BUTTON_RIGHT and e.is_pressed():
		# right click to 'reset' platform move	
		if current_game_state == GameState.LEVEL_START:
			if moving_platform:
				moving_platform.position = moving_platform_start_pos
				clear_moving_platform()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_game_state == GameState.LEVEL_START:
		if moving_platform:
			var mouse_pos = get_viewport().get_mouse_position()
			moving_platform.position = moving_platform_start_pos + (mouse_pos - moving_platform_start_mouse_pos)
