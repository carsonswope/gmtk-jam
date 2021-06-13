extends Sprite

export var completed = false

func _ready():
	var num_levels = get_tree().get_current_scene().NUM_LEVELS
	var current_level = get_tree().get_current_scene().current_level_idx
	var est = floor(sqrt(num_levels))
	var choice = int(est)
	var best = num_levels % int(est)
	if best != 0:
		for guess in [int(est-1),int(est+1)]:
			if guess == 1:
				continue
			var remainder = num_levels % guess
			if remainder == 0:
				choice = guess
				break
			elif remainder > best:
				best = num_levels % guess
				choice = guess
	var rows = int(ceil(float(num_levels)/float(choice)))
	var texResolution = texture.get_size()
	var y = ceil(float(current_level / choice))
	var y_size = texResolution.y / float(rows)
	var y_start = (y)*y_size
	var remainder = float(num_levels % ((rows-1) * choice))
	var cols = ((float(choice) if (best == 0 or y < rows-1) else remainder))
	print(cols)
	var x_size = texResolution.x / cols
	var x_start = (current_level % choice) * x_size
	region_rect = Rect2(Vector2(x_start,y_start),Vector2(x_size,y_size))
	scale = Vector2(40/y_size,40/y_size)
	for child in get_children():
		if child is Sprite:
			child.scale = child.scale / scale

func _on_Hitbox_body_entered(collider) -> void:
	print("collision!")
	if collider.is_in_group("Player"):
		print("collision with player!")		
		completed = true
