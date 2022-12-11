extends Camera


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#onready var ray: RayCast = $RayCast
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_pressed("move_up"):
		self.translation = self.translation + Vector3(1, 0, -1)
	if Input.is_action_pressed("move_down"):
		self.translation = self.translation + Vector3(-1, 0, 1)
	if Input.is_action_pressed("move_left"):
		self.translation = self.translation + Vector3(-1, 0, -1)
	if Input.is_action_pressed("move_right"):
		self.translation = self.translation + Vector3(1, 0, 1)
	
	pass
