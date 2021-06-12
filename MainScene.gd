extends Node2D

#const TilePlatform = preload("res://TilePlatform.tscn")

var current_level_idx = -1
var current_level = null

enum GameState {
	LEVEL_START = 0,
	LEVEL_RUNNING = 1,
	LEVEL_PAUSED = 2,
	DEATH = 3,
}

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
	get_tree().paused = true


func _ready():
	MusicController.play_music()

	$gui_root/play_pause_button.connect("button_down", self, "play_pause_click")

	init_level(0)
	
func play_pause_click():
	if current_game_state == GameState.LEVEL_START:
		# clicked play button to begin the simulation!
		current_game_state = GameState.LEVEL_RUNNING
		get_tree().paused = false
	elif current_game_state == GameState.LEVEL_RUNNING:
		# clicked pause button to pause the simulation
		current_game_state = GameState.LEVEL_START
		get_tree().paused = true
	else:
		print('hi')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if current_level != null:
		# this null check shouldn't be necessary 
		assert(current_level.get_node("NextLevel") != null)
		if current_level.get_node("NextLevel").completed:
			var next_level_idx = current_level_idx + 1
			if next_level_idx >= LEVELS.size():
				# but really, got to make an end-state
				print('game over ! you win !')
			else:
				print('advanced to next level!')
				init_level(next_level_idx)
	
	$gui_root/level_label.set_text('Current level: ' + str(current_level_idx))
	if current_game_state == GameState.LEVEL_START:
		$gui_root/play_pause_button.set_text('>')
	elif current_game_state == GameState.LEVEL_RUNNING:
		$gui_root/play_pause_button.set_text('||')
