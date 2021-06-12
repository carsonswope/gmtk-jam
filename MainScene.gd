extends Node2D

var current_level_idx = -1
var current_level = null

const GameState = preload("res://GameState.gd")

var current_game_state = GameState.LEVEL_START

const LEVELS = [
	preload("res://levels/level_1.tscn"),
	preload("res://levels/level_2.tscn"),
]

func init_level(level_idx):
	if current_level:
		remove_child(current_level)
	current_level_idx = level_idx
	current_level = LEVELS[current_level_idx].instance()

	add_child(current_level)
	current_game_state = GameState.LEVEL_START
	current_level.set_game_state(current_game_state)

	


func _ready():
	MusicController.play_music()

	$gui_root/play_pause_button.connect("button_up", self, "play_pause_click")
	$gui_root/reset_button.connect("button_up", self, "reset_click")

	init_level(1)
	
func play_pause_click():
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

func reset_click():
	init_level(current_level_idx)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if current_level != null:
		# this null check shouldn't be necessary 
		#var next_level_node = current_level.get_node("NextLevel")
		if current_level.is_completed():
			var next_level_idx = current_level_idx + 1
			if next_level_idx >= LEVELS.size():
				# but really, got to make an end-state
				print('game over ! you win !')
			else:
				print('advanced to next level!')
				init_level(next_level_idx)
	
	$gui_root/reset_button.disabled = current_game_state == GameState.LEVEL_START
	
	$gui_root/level_label.set_text('Current level: ' + str(current_level_idx))
	if current_game_state == GameState.LEVEL_START or current_game_state == GameState.LEVEL_PAUSED:
		$gui_root/play_pause_button.set_text('>')
	elif current_game_state == GameState.LEVEL_RUNNING:
		$gui_root/play_pause_button.set_text('||')
	else:
		print('huh?')
