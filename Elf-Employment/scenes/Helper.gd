extends ImmediateGeometry


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	clear()
	drawline(get_parent().get_node("Player2").global_translation, to_global(get_parent().get_node("Player2").TEMP_NEXT))

func drawline(a: Vector3, b: Vector3):
	begin(Mesh.PRIMITIVE_LINES)
	set_color(Color.black)
	add_vertex(a)
	add_vertex(b)
	end()
