extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Hitbox_body_entered(collider) -> void:
	print("collision!")
	
	if collider.is_in_group("Player"):
		print("collision with player!")
		print(get_tree().current_scene.name)
		var new_scene = "res://levels/level_" + str(int(get_tree().current_scene.name)+1)+".tscn"
		print(new_scene)
		get_tree().change_scene(new_scene)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
