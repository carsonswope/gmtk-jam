extends Node2D

const TILE_SIZE = 40
#a string "0101" would describe a square curved on the top right and bottom right
const corners = ["1010","0000","0101",		
"1010","0000","0101"]
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var pin_locations = []

# Called when the node enters the scene tree for the first time.
func _ready():
	#look for child tiles and instantiate rigidbodies
	for cell in $tiles.get_used_cells():
		print(cell)
		var id : int = $tiles.get_cell(cell.x,cell.y)
		add_colliders(cell.x,cell.y,id)

func add_colliders(x : int, y : int, id : int):
	var base_pos = get_parent().position
	var circle_shape = CircleShape2D.new()
	circle_shape.set_radius(20.0)
	var circle_collision = CollisionShape2D.new()
	circle_collision.set_shape(circle_shape)
	circle_collision.position = base_pos + Vector2(x+0.5,y+0.5)*TILE_SIZE
	$body.add_child(circle_collision)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
