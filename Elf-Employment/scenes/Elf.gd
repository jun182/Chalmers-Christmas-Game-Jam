extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().get_node("Camera").get_node("RayCast").connect("report_intersection", self, "_on_report_intersection")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if Input.is_action_just_released("mouse_click"):
#		self.position = get_viewport().get_global_mouse_position()
	pass
	
func _on_report_intersection(intersection_point: Vector3):
#	print(to_local(intersection_point))
#	var offset: Vector3 = self.global_translation - (intersection_point + Vector3(0, 2, 0))
	self.global_transform.origin = Vector3(intersection_point)
#	)translation = self.to_local(

		

	

