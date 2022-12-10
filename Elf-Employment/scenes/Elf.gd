extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed: float = 1000
var clicked: bool = false
onready var navigator: NavigationAgent = $Navigator
onready var animator: AnimationPlayer = $Pivot/Elf/AnimationPlayer

var TEMP_VELOCITY = Vector3(0,0,0)
var TEMP_NEXT = Vector3(0,0,0)

var time_since_moving: float = 0
var timeout: float = 0.3

var is_reached: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().get_node("Ground").connect("report_intersection", self, "_on_report_intersection")
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
	
	var direction: Vector3 = next_path_position
	if not is_reached:
		self.look_at(direction, Vector3.UP)
	self.rotation_degrees.x = 0
	TEMP_NEXT = next_path_position
	
	navigator.set_velocity(new_velocity)
	
	time_since_moving += delta
	
func _on_velocity_computed(safe_velocity : Vector3):
	var velocity = safe_velocity
	
	self.move_and_slide(velocity)
	TEMP_VELOCITY = velocity
	animator.playback_speed = velocity.length() * 0.2
	if velocity.length() < 1 && time_since_moving >= timeout:
		animator.play("1_Idle")
		navigator.set_target_location(self.translation)
		is_reached = true
	
func _on_report_intersection(intersection_point: Vector3):
	clicked = true
	time_since_moving = 0
#	print(to_local(intersection_point))
#	var offset: Vector3 = self.global_translation - (intersection_point + Vector3(0, 2, 0))
#	self.global_transform.origin = Vector3(intersection_point)
#	)translation = self.to_local(
	navigator.set_target_location(intersection_point)
	navigator.get_next_location()
#	print("I am at: ", self.translation)
#	print("I want to go to: ", navigator.get_next_location())
	
#	print("Offset is: ", offset)
	
func _on_navigation_finished():
	clicked = false
#	print("I am at: ", self.translation)
#	print("I want to go to: ", navigator.get_next_location())
	
	animator.play("1_Idle")
#	print("Offset is: ", offset)
		

	

