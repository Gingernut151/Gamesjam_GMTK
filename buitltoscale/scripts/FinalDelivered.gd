extends Node

var Finally = preload("res://ui/final_delivery/finaldelivered.tscn").instantiate()
var town = preload("res://maps/town/town_scene.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	print("collisions!")
	get_tree().change_scene_to_file("res://ui/final_delivery/finaldelivered.tscn")
	pass # Replace with function body.
