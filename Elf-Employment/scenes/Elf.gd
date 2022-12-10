extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed: float = 10
var clicked: bool = false
onready var navigator: NavigationAgent = $Navigator

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().get_node("Camera").get_node("RayCast").connect("report_intersection", self, "_on_report_intersection")
	navigator.connect("navigation_finished", self, "_on_navigation_finished")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not clicked:
		return
#	if Input.is_action_just_released("mouse_click"):
#		self.position = get_viewport().get_global_mouse_position()
#	print(self.translation)
#	print(navigator.get_next_location())
	var location = navigator.get_next_location()
	var offset: Vector3 = location - self.translation
#	offset.y = 0
	offset = offset.normalized()
	
#	print("I am at: ", self.translation)
#	print("I want to go to: ", navigator.get_next_location())
#	print("Offset is: ", offset)
	self.translate(offset * (speed * delta))
	
func _on_report_intersection(intersection_point: Vector3):
	clicked = true
#	print(to_local(intersection_point))
#	var offset: Vector3 = self.global_translation - (intersection_point + Vector3(0, 2, 0))
#	self.global_transform.origin = Vector3(intersection_point)
#	)translation = self.to_local(
	navigator.set_target_location(intersection_point)
	navigator.get_next_location()
	
func _on_navigation_finished():
	clicked = false
		

	

