extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal call_backup

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func emit_call_backup(newPosition: Vector3, group_id: int):
	emit_signal("call_backup", newPosition, group_id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
