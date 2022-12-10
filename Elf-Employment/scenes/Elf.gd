extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed: float = 1000
var clicked: bool = false
onready var navigator: NavigationAgent = $Navigator
onready var animator: AnimationPlayer = $Pivot/Elf/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().get_node("Camera").get_node("RayCast").connect("report_intersection", self, "_on_report_intersection")
	navigator.connect("navigation_finished", self, "_on_navigation_finished")
	navigator.connect("velocity_computed", self, "_on_velocity_computed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if not clicked:
		return
		
#	var location = navigator.get_next_location()
#	var offset: Vector3 = location - self.translation
#	offset = offset.normalized()
#	self.translate(offset * (speed * delta))
	animator.play("2_Walk")

	var movement_delta = speed * delta
	var next_path_position : Vector3 = navigator.get_next_location()
	
	var current_agent_position : Vector3 = global_transform.origin
	var new_velocity : Vector3 = (next_path_position - current_agent_position).normalized() * movement_delta
	navigator.set_velocity(new_velocity)
	
func _on_velocity_computed(safe_velocity : Vector3):
	var velocity = safe_velocity
	
	animator.playback_speed * (velocity.length() * 1)
	animator.clear_caches()
	self.move_and_slide(velocity)
	if velocity.length() < 1:
		animator.play("1_Idle")
	
func _on_report_intersection(intersection_point: Vector3):
	clicked = true
#	print(to_local(intersection_point))
#	var offset: Vector3 = self.global_translation - (intersection_point + Vector3(0, 2, 0))
#	self.global_transform.origin = Vector3(intersection_point)
#	)translation = self.to_local(
	navigator.set_target_location(intersection_point)
	navigator.get_next_location()
	print("I am at: ", self.translation)
	print("I want to go to: ", navigator.get_next_location())
	
	var direction: Vector3 = navigator.get_final_location() - self.translation
	direction.x = 0
	self.look_at(direction, Vector3.UP)
#	print("Offset is: ", offset)
	
func _on_navigation_finished():
	clicked = false
	print("I am at: ", self.translation)
	print("I want to go to: ", navigator.get_next_location())
	
	animator.play("1_Idle")
#	print("Offset is: ", offset)
		

	

