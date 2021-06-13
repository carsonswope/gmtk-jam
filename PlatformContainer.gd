extends Node2D

const TILE_SIZE = 40
#a string "0101" would describe a square curved on the top right and bottom right
const corners = ["1010","0000","0101",		
"1010","0000","0101",		
"1100","0000","0011",		
"1100","0000","0011",		
"1000","0100","0010","0001","0000","0000","0000","0000","0000",		
"1000","0100","0010","0001","0000","0000","0000","0000","0000"]
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var start_body_pos : Vector2
var start_tiles_pos : Vector2
var pin_locations = []

var initial_position
var initial_rotation

# Called when the node enters the scene tree for the first time.
func _ready():
	#look for child tiles and instantiate rigidbodies
	var center_of_gravity = Vector2(0, 0)
	for cell in $tiles.get_used_cells():
		var id : int = $tiles.get_cell(cell.x,cell.y)
		add_colliders(cell.x,cell.y,id)
		center_of_gravity += Vector2(cell.x + 0.5, cell.y + 0.5) * TILE_SIZE
	center_of_gravity /= $tiles.get_used_cells().size()
	$body.position += center_of_gravity
	for c in $body.get_children():
		c.position -= center_of_gravity
	#center the tile transform on the center of gravity as well
	$tiles.set_custom_transform(Transform2D(Vector2(TILE_SIZE,0.0),Vector2(0.0,TILE_SIZE),-center_of_gravity))
	initial_position = $body.position
	initial_rotation = $body.rotation
	$tiles.position = $body.position
	$tiles.rotation = $body.rotation
	update_label_if_exists()

func update_label_if_exists():
	var label_node = get_node_or_null("Label")
	if (label_node != null):
		var unit_x = Vector2(cos($body.rotation),sin($body.rotation))
		var unit_y = Vector2(-sin($body.rotation),cos($body.rotation))
		label_node.rect_position = $body.position - label_node.rect_size.x/2 * unit_x - label_node.rect_size.y/2 * unit_y
		label_node.rect_rotation = $body.rotation_degrees

func _physics_process(delta):
	$tiles.position = $body.position
	$tiles.rotation = $body.rotation
	update_label_if_exists()
		
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

# i.e. see if pin at cord would pin up the platform
func coords_in_hole(pos):
	for cell in $tiles.get_used_cells():
		var id = $tiles.get_cell(cell.x, cell.y)
		if id in [0,1,2,6,7,8,12,13,14,15,16,17,18,19,20]: # these are types of tiles with holes in them
			var base_pos = $body.position
			var unit_x = Vector2(cos($body.rotation),sin($body.rotation))
			var unit_y = Vector2(-sin($body.rotation),cos($body.rotation))
			var tile_origin = base_pos - (initial_position.x * unit_x + initial_position.y * unit_y)
			var pre_transform = (Vector2(cell.x + 0.5, cell.y + 0.5) * TILE_SIZE)
			var cell_center = position + tile_origin + (pre_transform.x * unit_x + pre_transform.y * unit_y)
			var diff = cell_center - pos
			if sqrt(diff.dot(diff)) < 10:
				return cell_center
	return null
	
func coords_in_platform(mouse_position):
	var mouse_circle = CircleShape2D.new()
	mouse_circle.set_radius(2)
	for c in $body.get_children():
		if c.shape.collide(c.transform,mouse_circle,Transform2D(0.0,position + $body.position-mouse_position)):
			return true
	return false

func would_overlap_with_other_pin_in_position(pin, pos):
	var pin_circle = CircleShape2D.new()
	pin_circle.set_radius(11)
	for c in $body.get_children():
		if c.shape.collide(c.transform.translated(position + $body.position),pin_circle,Transform2D(0.0, pin.position)):
			return true
	return false

func would_overlap_with_other_cell_pos_in_position(cell_pos, pos):
	var cell_shape = RectangleShape2D.new()
	cell_shape.set_extents(Vector2(3, 3))
	for c in $body.get_children():
		if c.shape.collide(c.transform.translated(position + $body.position),cell_shape,Transform2D(0.0, cell_pos)):
			return true
	return false

func would_overlap_with_other_platform_in_position(other, pos):
	for c in $body.get_children():
		var c_tf = c.transform.translated(pos + $body.position)
		var o_b = other.get_node("body")
		for o_c in o_b.get_children():
			var oc_tf = o_c.transform.translated(other.position + o_b.position)
			if c.shape.collide(c_tf, o_c.shape, oc_tf):
				return true
	return false
