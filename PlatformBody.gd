extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var pin_just_set = null
# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	pass # Replace with function body.

func _integrate_forces(state):
	print("integrating forces")
	if (pin_just_set):
		state.transform = pin_just_set
		pin_just_set = null
	else:
		pass
		state.integrate_forces()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
