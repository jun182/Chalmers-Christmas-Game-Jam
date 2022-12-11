extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed: float = 1000
var clicked: bool = false

onready var navigator: NavigationAgent = $Navigator
onready var animator: AnimationPlayer = $Pivot/Elf/AnimationPlayer

var manager

var time_since_moving: float = 0
var timeout: float = 0.3

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

var is_reached: bool = false

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
		

func _physics_process(delta):
	if not clicked:
		return
		
	animator.play("2_Walk")

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

	animator.playback_speed = velocity.length() * 0.2
	if velocity.length() < 1 && time_since_moving >= timeout:
		animator.play("1_Idle")
		navigator.set_target_location(self.translation)
		is_reached = true
		
func _on_call_backup(new_position, new_group_id):
	if group_id == new_group_id:
		state = State.BACKUP
		agitation_target = new_position
	print("hylla")
		
	
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

