extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("rotate_left"):
		print("pressing")
		self.rotate_x(30 * delta)
	
	if Input.is_action_pressed("rotate_right"):
		print("pressing")
		self.rotate_x(-30 * delta)
