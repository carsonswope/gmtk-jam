extends Sprite

export var completed = false

func _on_Hitbox_body_entered(collider) -> void:
	print("collision!")
	if collider.is_in_group("Player"):
		print("collision with player!")		
		completed = true
