extends Node2D

var current_level_idx = -1
var current_level = null
const GameState = preload("res://GameState.gd")

var session_start_time
var current_game_state = GameState.MAIN_MENU

var gamejam_tex = preload("res://resources/sprites/gamejam.png")
var normal_font = preload("res://resources/fonts/main_font.tres")
var title_font = preload("res://resources/fonts/title.tres")

var EndGame = preload("res://EndGame.tscn")

#stuff to save

var levels_solved = {} #best pin count, whether the user got a special thing, etc
var play_time = 0 #milliseconds


const LEVELS = [
	preload("res://levels/tutorial_1.tscn"),
	preload("res://levels/tutorial_2.tscn"),
	preload("res://levels/tutorial_3.tscn"),
	preload("res://levels/tutorial_4.tscn"),
	preload("res://levels/level_1.tscn"),
	preload("res://levels/level_2.tscn"),
	preload("res://levels/level_3.tscn"),
	preload("res://levels/level_4.tscn"),
	preload("res://levels/level_5.tscn"),
	preload("res://levels/level_6.tscn"),
	preload("res://levels/level_7.tscn"),
	preload("res://levels/level_8.tscn"),
	preload("res://levels/level_9.tscn"),
	preload("res://levels/level_10.tscn"),
]
var NUM_LEVELS = LEVELS.size()

func load_save():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.
	save_game.open("user://savegame.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		var line_data = parse_json(save_game.get_line())
		for i in line_data.keys():
			if i == "levels_solved":
				levels_solved = line_data[i]
				print(levels_solved)
			elif i == "play_time":
				play_time = line_data[i]
	save_game.close()

func save_game():
	print("saving game before quitting")
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	save_game.store_line(to_json({"levels_solved" : levels_solved}))
	save_game.store_line(to_json({"play_time" : (play_time + OS.get_ticks_msec() - session_start_time)}))
	save_game.close()

func init_level(level_idx):
	if current_level:
		remove_child(current_level)
	current_level_idx = level_idx
	current_level = LEVELS[current_level_idx].instance()

	add_child(current_level)
	current_game_state = GameState.LEVEL_START
	current_level.set_game_state(current_game_state)
	toggle_game_gui_visibility(true)
	return true

func reset_save():
	levels_solved = {}
	for i in NUM_LEVELS:
		levels_solved[String(i)] = [false,-1]
	session_start_time = OS.get_ticks_msec()
	play_time = 0

func _ready():
	MusicController.play_music()
	$gui_root/play_pause_button.connect("button_up", self, "play_pause_click")
	$gui_root/reset_button.connect("button_up", self, "reset_click")
	$gui_root/new_pin_button.connect("button_up", self, "new_pin_click")
	#reset_save()
	$gui_root/reset_soft_button.connect("button_up", self, "reset_soft_click")
	$gui_root/quit_button.connect("button_up", self, "return_to_main_menu")
	load_save()
	session_start_time = OS.get_ticks_msec()
	init_main_menu()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_game()
		get_tree().quit() # default behavior
	
func play_pause_click():
	MusicController.play_fx("click_sound")
	if current_game_state == GameState.LEVEL_START or current_game_state == GameState.LEVEL_PAUSED:
		# clicked play button to begin the simulation!
		current_game_state = GameState.LEVEL_RUNNING
		current_level.set_game_state(current_game_state)
	elif current_game_state == GameState.LEVEL_RUNNING:
		# clicked pause button to pause the simulation
		current_game_state = GameState.LEVEL_PAUSED
		current_level.set_game_state(current_game_state)
	else:
		print('hi')

func toggle_game_gui_visibility(visible : bool):
	for item in [$gui_root/level_label,$gui_root/new_pin_button,		
	$gui_root/play_pause_button, $gui_root/reset_button,		
	$gui_root/reset_soft_button, $gui_root/new_pin_counter,		
	$gui_root/quit_button]:
		item.visible = visible

func init_main_menu():
	toggle_game_gui_visibility(false)
	var est = floor(sqrt(NUM_LEVELS))
	var choice = int(est)
	var best = NUM_LEVELS % int(est)
	if best != 0:
		for guess in [int(est-1),int(est+1)]:
			if guess == 1:
				continue
			var remainder = NUM_LEVELS % guess
			if remainder == 0:
				choice = guess
				break
			elif remainder > best:
				best = NUM_LEVELS % guess
				choice = guess
	var rows = int(ceil(float(NUM_LEVELS)/float(choice)))
	var projectResolution=OS.get_window_size()
	for i in NUM_LEVELS:
		var level_button = Button.new()
		level_button.text = String(i+1)
		var y = ceil(float(i / choice))
		var y_portion = (y+1)/float(rows+1)
		var remainder = float(NUM_LEVELS % ((rows-1) * choice))
		print(remainder)
		var x_portion = float(i % choice + 1) /((float(choice) if (best == 0 or y < rows-1) else remainder)+1) 
		level_button.margin_left = projectResolution.x * x_portion
		level_button.margin_top = projectResolution.y * y_portion
		level_button.add_font_override("font",normal_font)
		level_button.disabled = false if (i==0 or OS.is_debug_build()) else !levels_solved[String(i-1)][0]
		level_button.connect("button_up", self, "_on_level_click", [i])
		$menu_gui_root.add_child(level_button)
	var game_title = Label.new()
	game_title.text = "Corkboard"
	game_title.add_font_override("font",title_font)
	$menu_gui_root.add_child(game_title)	
		

func _on_level_click(lvl_idx):
	if (init_level(lvl_idx)):
		MusicController.play_fx("click_sound")
		for child in $menu_gui_root.get_children():
			$menu_gui_root.remove_child(child)

func return_to_main_menu():
	MusicController.play_fx("click_sound")
	if current_level:
		remove_child(current_level)
		current_level = null
		current_level_idx = -1
	current_game_state = GameState.MAIN_MENU
	init_main_menu()

func reset_click():
	MusicController.play_fx("click_sound")
	init_level(current_level_idx)

func reset_soft_click():
	MusicController.play_fx("click_sound")
	# reset
	var platform_placements = current_level.get_initial_platform_placements()
	var pin_placements = current_level.get_initial_pin_placements()
	init_level(current_level_idx)
	current_level.place_platforms(platform_placements)
	current_level.place_pins(pin_placements)

func new_pin_click():
	MusicController.play_fx("click_sound")
	current_level.placing_pin = true

func show_end_game():
	
	if current_level:
		remove_child(current_level)
	current_level = null
	current_level_idx = -1
	toggle_game_gui_visibility(false)
	current_game_state = GameState.CREDITS
	var end_game = EndGame.instance()
	add_child(end_game)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_game_state == GameState.MAIN_MENU or current_game_state == GameState.CREDITS:
		return
	if current_level != null:
		if current_level.player_out_of_bounds():
			# reset
			var platform_placements = current_level.get_initial_platform_placements()
			var pin_placements = current_level.get_initial_pin_placements()
			init_level(current_level_idx)
			current_level.place_platforms(platform_placements)
			current_level.place_pins(pin_placements)
		# this null check shouldn't be necessary 
		#var next_level_node = current_level.get_node("NextLevel")
		elif current_level.is_completed():
			levels_solved[String(current_level_idx)] = [true,1]
			save_game()
			var next_level_idx = current_level_idx + 1
			if next_level_idx >= LEVELS.size():
				show_end_game()
				return
			else:
				print('advanced to next level!')
				init_level(next_level_idx)
	
		var num_unplaced_pins = current_level.num_unplaced_pins()
		$gui_root/new_pin_button.disabled = num_unplaced_pins == 0
		$gui_root/new_pin_counter.set_text('x(' + str(num_unplaced_pins) +')')
		
		$gui_root/reset_soft_button.disabled = current_game_state == GameState.LEVEL_START

		$gui_root/level_label.set_text('Level ' + str(current_level_idx+1))
		if current_game_state == GameState.LEVEL_START or current_game_state == GameState.LEVEL_PAUSED:
			$gui_root/play_pause_button.set_text('play')
		elif current_game_state == GameState.LEVEL_RUNNING:
			$gui_root/play_pause_button.set_text('pause')
		else:
			print('huh?')
