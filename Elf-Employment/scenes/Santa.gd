extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var navigator: NavigationAgent = $Navigator
onready var animator: AnimationPlayer = $Pivot/Santa/AnimationPlayer

onready var talker = $Talker

var manager

# Movement
var time_since_moving: float = 0
var timeout: float = 0.3

var speed: float = 1000
var clicked: bool = false

var is_reached: bool = false

# Agitation
export var group_id: int

enum State{
	IDLE,
	SEARCHING,
	BACKUP,
	AGITATED
}

var state: int = State.IDLE
var agitated_timer: float = 0
var agitation_timeout: float = 3
var agitation_target = null

# Debates
var is_being_convinced: bool = false

var belief_level: float = 500

var persuasion_modifier: float = 0
var is_converted: bool = false
onready var progress = $HealthBar/Viewport/RadialProgressBar
var is_talking: bool = false



# Called when the node enters the scene tree for the first time.
func _ready():
	navigator.connect("navigation_finished", self, "_on_navigation_finished")
	navigator.connect("velocity_computed", self, "_on_velocity_computed")
	manager = get_node("/root/HerdManager")
	
	manager.connect("call_backup", self, "_on_call_backup")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_since_moving += delta
	
	if state == State.IDLE:
		agitation_target = null
	
	if state == State.SEARCHING:
		agitated_timer += delta
		if agitated_timer >= agitation_timeout:
			state = State.IDLE
	else:
		agitated_timer = 0
		
	if state == State.BACKUP:
		set_navigation(agitation_target)
	
	if state == State.AGITATED:
		set_navigation(agitation_target.global_translation)
		
	if is_being_convinced:
		belief_level -= 2 * delta * persuasion_modifier
	else: 
		belief_level += 4 * delta
		
	if belief_level > 500:
		belief_level = 500
	elif belief_level < 0:
		belief_level = 0
		if not is_converted:
			animator.clear_queue()
			animator.clear_caches()
			animator.play("Give_up")
			animator.playback_speed = 1
			animator.current_animation.repeat(0)
			animator.connect("animation_finished", self, "_on_conversion")
			is_converted = true
		
	progress.progress = belief_level/5
	
	if is_talking && not is_converted:
		animator.play("Attack")
		
	reevaluate_opponents()
	if persuasion_modifier < 1:
		is_being_convinced = false
		is_talking = false
	
func _physics_process(delta):
	if not clicked:
		return
	
	if not is_converted && is_talking:
		animator.play("Attack")
	elif not is_converted:
		animator.play("2_Walk") 
	else:
		return

	var movement_delta = speed * delta
	var next_path_position : Vector3 = navigator.get_next_location()
	
	var current_agent_position : Vector3 = global_transform.origin
	var new_velocity : Vector3 = (next_path_position - current_agent_position).normalized() * movement_delta
	
	var direction: Vector3 = next_path_position
	if not is_reached:
		self.look_at(direction, Vector3.UP)
	self.rotation_degrees.x = 0
	
	navigator.set_velocity(new_velocity)
	
func _on_velocity_computed(safe_velocity : Vector3):
	var velocity = safe_velocity
	
	self.move_and_slide(velocity)

	if not is_talking:
		animator.playback_speed = velocity.length() * 0.2
	if velocity.length() < 1 && time_since_moving >= timeout:
		animator.play("1_Idle")
		navigator.set_target_location(self.translation)
		is_reached = true
		
func _on_call_backup(new_position, new_group_id):
	if group_id == new_group_id:
		state = State.BACKUP
		agitation_target = new_position
		
	
func set_navigation(intersection_point: Vector3):
	clicked = true
	time_since_moving = 0

	navigator.set_target_location(intersection_point)
	navigator.get_next_location()

func _on_navigation_finished():
	clicked = false
	animator.play("1_Idle")

func _on_Detector_area_entered(area):
	if state == State.AGITATED:
		manager.emit_call_backup(area.get_parent().global_translation, group_id)
		return
	state = State.AGITATED
	agitation_target = area.get_parent()
	print(agitation_target)


func _on_Detector_area_exited(area):
	state = State.SEARCHING


func _on_Talker_area_entered(area):
	if (area.name == "Talker") && (area.get_parent().is_in_group("friendly")):
		print ("Friendly encountered by enemy")
		
#		var temp_modifier: float = 0
#		for i in talker.get_overlapping_areas():
#			if (area.name == "Talker") && i.get_parent().is_in_group("friendly"):
#				temp_modifier += 1
#
#		persuasion_modifier = temp_modifier
		reevaluate_opponents()
		
		is_being_convinced = true
		is_talking = true

func _on_Talker_area_exited(area):
	if (area.name == "Talker") && (area.get_parent().is_in_group("friendly")):
		print ("Friendly left enemy")
		
#		var temp_modifier: float = 0
#		var areas = talker.get_overlapping_areas()
#		for i in areas:
#			if (area.name == "Talker") && i.get_parent().is_in_group("friendly"):
#				temp_modifier += 1
#
#		persuasion_modifier = temp_modifier
		reevaluate_opponents()
		
		if persuasion_modifier < 1:
			is_being_convinced = false
			is_talking = false

func _on_conversion(anim_name: String):
#	var scene = load("res://scenes/Elf.tscn")
#	var player = scene.instance()
#	player.global_translation = self.global_translation
#	player.rotation = self.rotation
#	get_parent().add_child(player)
#	self.queue_free()
	animator.play("Given_up")
	talker.queue_free()

func reevaluate_opponents() -> void:
		var temp_modifier: float = 0
		var areas = talker.get_overlapping_areas()
		for i in areas:
			if (i.name == "Talker") && i.get_parent().is_in_group("friendly"):
				temp_modifier += 1

		persuasion_modifier = temp_modifier
