extends StaticBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


signal report_intersection
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#func _on_Ground_input_event(camera, event, position, normal, shape_idx):
#	print (position)

func _input_event(camera: Object, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int):

	if event is InputEventMouseButton:
		emit_signal("report_intersection", position)
