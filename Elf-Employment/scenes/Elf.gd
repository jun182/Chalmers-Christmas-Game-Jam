extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed: float = 1000
var clicked: bool = false
onready var navigator: NavigationAgent = $Navigator
onready var animator: AnimationPlayer = $Pivot/Elf/AnimationPlayer
onready var talker: Area = $Talker

var TEMP_VELOCITY = Vector3(0,0,0)
var TEMP_NEXT = Vector3(0,0,0)

var time_since_moving: float = 0
var timeout: float = 0.3

var is_reached: bool = false

# Debates
var is_being_convinced: bool = false

var belief_level: float = 100
var is_converted: bool = false
var persuasion_modifier: float = 0

var is_talking: bool = false

onready var progress = $HealthBar/Viewport/RadialProgressBar

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().get_node("Ground").connect("report_intersection", self, "_on_report_intersection")
	navigator.connect("navigation_finished", self, "_on_navigation_finished")
	navigator.connect("velocity_computed", self, "_on_velocity_computed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if is_being_convinced:
		belief_level -= 2 * delta * persuasion_modifier
	else: 
		belief_level += 4 * delta
		
	if belief_level > 100:
		belief_level = 100
	elif belief_level < 0:
		belief_level = 0
		if not is_converted:
			animator.play("4_Reconversion")
			animator.playback_speed = 1
			animator.current_animation.repeat(0)
			animator.connect("animation_finished", self, "_on_conversion")
			is_converted = true
		
	progress.progress = belief_level

func _physics_process(delta):
	if not clicked:
		return

	if is_talking: 
		animator.play("3_Talk")
	else:
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
		if not is_talking:
			animator.play("1_Idle")
		navigator.set_target_location(self.translation)
		is_reached = true
	
func _on_report_intersection(intersection_point: Vector3):
	clicked = true
	time_since_moving = 0
	navigator.set_target_location(intersection_point)
	navigator.get_next_location()

	
func _on_navigation_finished():
	clicked = false
#	print("I am at: ", self.translation)
#	print("I want to go to: ", navigator.get_next_location())
	if not is_talking:
		animator.play("1_Idle")
#	print("Offset is: ", offset)
		

func _on_Detector_area_entered(area):
	pass # Replace with function body.


func _on_Detector_area_exited(area):
	pass # Replace with function body.


func _on_Talker_area_entered(area):
	if (area.name == "Talker") && (area.get_parent().is_in_group("enemy")):
		print ("Friendly encountered by enemy")
		is_being_convinced = true
		
		var temp_modifier: float = 0
		for i in talker.get_overlapping_areas():
			if (area.name == "Talker") && i.get_parent().is_in_group("enemy"):
				temp_modifier += 1
			
		persuasion_modifier = temp_modifier
		is_talking = true

func _on_Talker_area_exited(area):
	if (area.name == "Talker") && (area.get_parent().is_in_group("enemy")):
		print ("Friendly left enemy")
		
		var temp_modifier: float = 0
		var areas = talker.get_overlapping_areas()
		for i in areas:
			if (area.name == "Talker") && i.get_parent().is_in_group("enemy"):
				temp_modifier += 1
			
		persuasion_modifier = temp_modifier
		
		if persuasion_modifier < 1:
			is_being_convinced = false
			is_talking = false
			
func _on_conversion(anim_name: String):
	self.queue_free()
