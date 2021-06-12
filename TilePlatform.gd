extends Node2D

const Tile = preload("res://Tile.tscn")

const EMPTY_TILE = ' '
const PLATFORM_TILE = 'x'

const TILE_SIZE = 40

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func initialize(shape, dynamic):
	
	if dynamic:
		$body.set_mode(0) # MODE_RIGID
	else:
		$body.set_mode(1) # MODE_STATIC

	#var tiles = []
	var tile_positions = []
	for r in range(shape.size()):
		for c in range(shape[r].length()):
			var tile_id = shape[r][c]
			if tile_id == EMPTY_TILE:
				pass

			elif tile_id == PLATFORM_TILE:
				var pos = Vector2(
					(TILE_SIZE/2) + (c*TILE_SIZE),
					(TILE_SIZE/2) + (r*TILE_SIZE))
				tile_positions.append(pos)
				var t = Tile.instance()
				var t_kids = t.get_children()
				for child in t_kids:
					t.remove_child(child)
					$body.add_child(child)
					child.position = pos
				# **delete t**
			else:
				print('unknown tile id ', tile_id)
				assert(false)
		
	# get where the center of gravity should be... is this the right calculation??
	var center_of_gravity = Vector2(0, 0)
	for p in tile_positions:
		center_of_gravity += p
	center_of_gravity /= tile_positions.size()
	
	for c in $body.get_children():
		c.position -= center_of_gravity

	$body.position += center_of_gravity


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#		pass
