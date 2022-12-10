extends RayCast


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var ray_length: float = 100.0
var camera: Camera

onready var line = $Helper

signal report_intersection

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_parent()

func _input(event):
   # Mouse in viewport coordinates.
	if event is InputEventMouseButton && event.is_pressed():
		
		
#		var newOrigin: Vector3 = Vector3(event.position.x, cam.translation.y, event.position.y)
		print(event.position)
		var newOrigin: Vector3 = camera.project_ray_origin(event.position)
		print(newOrigin)
		var newDestination: Vector3 = newOrigin + camera.project_ray_normal(event.position) * ray_length
		print(newDestination)

		self.global_transform.origin = newOrigin
		self.cast_to = newDestination
#		print("Collision at: ", get_collision_point())
		print(is_colliding())
		if (is_colliding()):
			emit_signal("report_intersection", get_collision_point())
			print(get_collider())
#		print("emitted")
		

	pass
