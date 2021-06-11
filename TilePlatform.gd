extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const EMPTY_TILE = ' '
const PLATFORM_TILE = 'x'

const TILE_SIZE = 64

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func initialize(shape, dynamic):

	var tiles = []
	for r in range(shape.size()):
		for c in range(shape[r].length()):
			var tile_id = shape[r][c]
			if tile_id == EMPTY_TILE:
				pass
			elif tile_id == PLATFORM_TILE:
				if dynamic:
					var t = preload("res://TileDynamic.tscn").instance()
					t.position.x = (TILE_SIZE/2) + (c*TILE_SIZE)
					t.position.y = (TILE_SIZE/2) + (r*TILE_SIZE)
					add_child(t)
					tiles.append(t)
				else:
					var t = preload("res://Tile.tscn").instance()
					t.position.x = (TILE_SIZE/2) + (c*TILE_SIZE)
					t.position.y = (TILE_SIZE/2) + (r*TILE_SIZE)
					add_child(t)
					tiles.append(t)
				if dynamic and tiles.size() >= 2:
					var t0 = tiles[-1]
					var t1 = tiles[-2]
					
					""""
					var j = Generic6DOFJoint.new()
					j.set_node_a(t0)
					j.set_node_b(t1)
					j.linear_limit_x.enabled = true
					j.linear_limit_x.lower_distance = 0
					j.linear_limit_x.upper_distance = 0
					j.linear_limit_y.enabled = true
					j.linear_limit_y.lower_distance = 0
					j.linear_limit_y.upper_distance = 0
					j.linear_limit_z.enabled = true
					j.linear_limit_z.lower_distance = 0
					j.linear_limit_z.upper_distance = 0
					
					add_child(j)
					"""
					print('hi')
			else:
				print('unknown tile id ', tile_id)
				assert(false)

	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
