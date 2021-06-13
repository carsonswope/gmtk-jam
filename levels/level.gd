extends Node2D

const GameState = preload("res://GameState.gd")

const Pin = preload("res://Pin.tscn")
const PinMoving = preload("res://PinMoving.tscn")


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
		
	placing_pin_icon = PinMoving.instance()
	add_child(placing_pin_icon)
	placing_pin_icon.position = Vector2(-100, -100)
	placing_pin_icon.z_index = 10
	

func is_completed():
	return $layout/NextLevel.completed

func set_game_state(s):
	
	if s == GameState.LEVEL_START:
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

func get_initial_platform_placements():
	return placed_platform_positions

func get_initial_pin_placements():
	var ps = []
	for p in placed_pins:
		if p.initial_position != Vector2(-1, -1):
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

func place_pin(pos, initial_position=Vector2(-1, -1)):
	
	# need to see if the pin is on a hole!
	var joint_setup = null
	for p in get_platforms():
		var hole_coords = p.coords_in_hole(pos)
		if hole_coords:
			if initial_position == pos:
				initial_position = hole_coords
			pos = hole_coords
			joint_setup = [p, hole_coords]
			
	if joint_setup == null:
		for p in get_platforms():
			for mod in [Vector2(0,0),Vector2(-10,0),Vector2(10,0),Vector2(0,-10),Vector2(0,10)]:
				if p.coords_in_platform(pos + mod):
					return -1

	var pin = Pin.instance()
	pin.position = pos
	pin.initial_position = initial_position
	add_child(pin)
	placed_pins.append(pin)
	placing_pin = false
	placing_pin_original_position = null
	placing_pin_icon.position = Vector2(-100, -100)

	if joint_setup:
		var pin_body = placed_pins[-1]
		var platform_body = joint_setup[0].get_node("body")
		var hole_coords = joint_setup[1]
		
		var j = PinJoint2D.new()
		j.add_to_group("joints")
		j.position = hole_coords
		j.node_a = pin_body.get_path()
		j.node_b = platform_body.get_path()
		j.disable_collision = true
		add_child(j)
	
	return 0


func pin_clicked(mouse_position):
	for i in range(placed_pins.size()):
		var pin = placed_pins[i]
		if sqrt((pin.position - mouse_position).dot(pin.position - mouse_position)) < 10:
			return i
	return -1

func get_platforms():
	return get_tree().get_nodes_in_group("PlatformContainers")

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
			if current_game_state == GameState.LEVEL_START:
				init_position = mouse_position
			elif not placing_pin_init_position:
				init_position = Vector2(-1, -1)
			else:
				init_position = placing_pin_init_position
			if place_pin(mouse_position, init_position) == -1:
				# placement failed, 
				# only reset pin back to original when level is still not moving
				if placing_pin_original_position and current_game_state == GameState.LEVEL_START:
					place_pin(placing_pin_original_position, placing_pin_original_position)
				else:
					placing_pin = false
				placing_pin_icon.position = Vector2(-100, -100)
		
		# pickin a pin up..
		elif moving_platform == null and pin_clicked(mouse_position) > -1:
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
				var platforms = get_platforms()
				clear_moving_platform()
				for p in platforms:
					if p.coords_in_platform(mouse_position):
						# can't move a platform that already is part of a joint
						if not has_joint(p):
							moving_platform_idx = i
							moving_platform = p
							moving_platform_start_pos = p.position
							moving_platform_start_mouse_pos = mouse_position
							return
					i += 1

			# currently moving a platform - snap platform to intented position
			else:
				var new_platform_position = moving_platform_start_pos + (get_viewport().get_mouse_position() - moving_platform_start_mouse_pos)
				
				# well, would it overlap any existing platforms?
				var platforms = get_platforms()
				var ineligible = false
				for p in platforms:
					if p != moving_platform:
						if moving_platform.would_overlap_with_other_platform_in_position(p, new_platform_position):
							ineligible = true
							break
				
				# no, okay then, would it overlap any existing pins?
				if not ineligible:
					for p in placed_pins:
						if moving_platform.would_overlap_with_other_pin_in_position(p, new_platform_position):
							ineligible = true
							break
				
				# no, okay the, would it overlap the terrain?
				if not ineligible:
					var terrain = $layout/Terrain/Terrain
					#terrain.
					#terrain.get_
					for cell in terrain.get_used_cells():
						#var id = terrain.get_cell(cell.x, cell.y)
						#print(id)
						var cell_pos = terrain.map_to_world(cell) + Vector2(20, 20)
						#var cell_pos = Vector2(cell.x + 0.5, cell.y + 0.5) * 40 # TILE_SIZE :)
						if moving_platform.would_overlap_with_other_cell_pos_in_position(cell_pos, new_platform_position):
							ineligible = true
							break
						#var id = terrain.get_cell(cell.x, cell.y)
				
				if ineligible:
					moving_platform.position = moving_platform_start_pos
				else:
					moving_platform.position = new_platform_position
					placed_platform_positions[moving_platform_idx] = new_platform_position

				clear_moving_platform()
				return
	
	# right mouse click! reset/cancel the stuff
	elif e.button_index == BUTTON_RIGHT and e.is_pressed():
		# reset pin placement..
		if placing_pin:
			# only reset pin back to original when level is still not moving
			if placing_pin_original_position and current_game_state == GameState.LEVEL_START:
				place_pin(placing_pin_original_position, placing_pin_original_position)
			else:
				placing_pin = false
			placing_pin_icon.position = Vector2(-100, -100)

		# right click to 'reset' platform move
		elif current_game_state == GameState.LEVEL_START:
			if moving_platform:
				moving_platform.position = moving_platform_start_pos
				clear_moving_platform()

func has_joint(p):
	var joints = get_tree().get_nodes_in_group("joints")
	for j in joints:
		var p_path = p.get_node("body").get_path()
		var j_path = j.node_b
		if j_path == p_path:
			return true
	return false
	#get_tree().get_nodes_in_group("PlatformContainers")

# durr.. just some lazy garbage collection instead of actually keeping track of joints
func prune_joints():
	var joints = get_tree().get_nodes_in_group("joints")
	for j in joints:
		var pin_path = j.node_a
		var pin = get_node_or_null(pin_path)
		if not pin:
			remove_child(j)

func pin_eligible(pos):
	for p in get_platforms():
		var hole_coords = p.coords_in_hole(pos)
		if hole_coords:
			return hole_coords
			
	for p in get_platforms():
		for mod in [Vector2(0,0),Vector2(-10,0),Vector2(10,0),Vector2(0,-10),Vector2(0,10)]:
			if p.coords_in_platform(pos + mod):
				return null
	
	return pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	prune_joints()
	
	if placing_pin:
		var placing_pin_pos = get_viewport().get_mouse_position()
		var eligible = pin_eligible(placing_pin_pos)
		placing_pin_icon.position = eligible if eligible else placing_pin_pos
		placing_pin_icon.get_child(1).modulate = Color(1,1,1,0.4) if eligible else Color(1,0,0,0.2)
	
	if current_game_state == GameState.LEVEL_START:
		if moving_platform:
			var mouse_pos = get_viewport().get_mouse_position()
			moving_platform.position = moving_platform_start_pos + (mouse_pos - moving_platform_start_mouse_pos)
