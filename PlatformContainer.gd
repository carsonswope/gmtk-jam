extends Node2D

const TILE_SIZE = 40
#a string "0101" would describe a square curved on the top right and bottom right
const corners = ["1010","0000","0101",		
"1010","0000","0101"]
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var start_body_pos : Vector2
var start_tiles_pos : Vector2
var pin_locations = []

# Called when the node enters the scene tree for the first time.
func _ready():
	#look for child tiles and instantiate rigidbodies
	var center_of_gravity = Vector2(0, 0)
	for cell in $tiles.get_used_cells():
		print(cell)
		var id : int = $tiles.get_cell(cell.x,cell.y)
		add_colliders(cell.x,cell.y,id)
		center_of_gravity += Vector2(cell.x + 0.5, cell.y + 0.5) * TILE_SIZE
	center_of_gravity /= $tiles.get_used_cells().size()
	$body.position += center_of_gravity
	for c in $body.get_children():
		c.position -= center_of_gravity
	#center the tile transform on the center of gravity as well
	$tiles.set_custom_transform(Transform2D(Vector2(TILE_SIZE,0.0),Vector2(0.0,TILE_SIZE),-center_of_gravity))
	$tiles.position = $body.position
	$tiles.rotation = $body.rotation

func _process(delta):
	$tiles.position = $body.position
	$tiles.rotation = $body.rotation
		
func add_colliders(x : int, y : int, id : int):
	var base_pos = $body.position + Vector2(x + 0.5, y + 0.5) * TILE_SIZE
	var circle_shape = CircleShape2D.new()
	circle_shape.set_radius(TILE_SIZE/2.0)
	var circle_collision = CollisionShape2D.new()
	circle_collision.set_shape(circle_shape)
	circle_collision.position = base_pos
	$body.add_child(circle_collision)
	for i in range(0,4):
		if corners[id][i]=='0':
			var rect_pos = base_pos + Vector2(-10 if i%2 == 0 else 10, -10 if i < 2 else 10)
			var rect_shape = RectangleShape2D.new()
			rect_shape.set_extents(Vector2(TILE_SIZE/4.0,TILE_SIZE/4.0))
			var rect_collision = CollisionShape2D.new()
			rect_collision.set_shape(rect_shape)
			rect_collision.position = rect_pos
			$body.add_child(rect_collision)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
