extends CharacterBody3D

#vars
var SPEED
var t_bob = 0.0
var picked_object
var pull_power = 4
var rotation_power = 0.5
var locked = false

#refs
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var hand = $Head/Camera3D/Hand
@onready var interaction = $Head/Camera3D/Interaction
@onready var joint = $Head/Camera3D/JoltGeneric6DOFJoint3D
@onready var static_body = $Head/Camera3D/StaticBody3D

#const
const BASE_FOV = 75.0
const FOV_CHANGE  = 1.5
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
const WALK_SPEED = 5.0
const SPRINT_SPEED = 7.5
const JUMP_VELOCITY = 4.5
const SENS = 0.003
const MW_SENS = 0.1



func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func pick_object():
	var collider = interaction.get_collider()
	if collider != null and collider is RigidBody3D:
		picked_object = collider
		joint.set_node_b(picked_object.get_path())
		
func drop_object():
	if picked_object != null:
		picked_object = null
		joint.set_node_b(joint.get_path())

func rotate_object(event):
	if picked_object != null:
		if event is InputEventMouseMotion:
			static_body.rotate_x(deg_to_rad(event.relative.y * rotation_power))
			static_body.rotate_y(deg_to_rad(event.relative.y * rotation_power))

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("lclick"):
		if picked_object == null:
			pick_object()
		elif picked_object != null:
			drop_object()
			
	if Input.is_action_pressed("rclick") && picked_object != null:
		locked = true
		rotate_object(event)
	else:
		locked = false
		
	if Input.is_action_just_pressed("mw_up"):
		hand.position -= Vector3(0,0,MW_SENS)
		
	if Input.is_action_pressed("mw_down"):
		hand.position += Vector3(0,0, MW_SENS)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && !locked:
		head.rotate_y(-event.relative.x * SENS)
		camera.rotate_x(-event.relative.y * SENS)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_pressed("sprint"):
		SPEED = SPRINT_SPEED
	else:
		SPEED = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backwards")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 7.0)
		velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 7.0)

	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE *  velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	move_and_slide()
	
	if picked_object != null:
		var a = picked_object.global_position
		var b = hand.global_position
		var c = a.distance_to(b)
		var calc = (a.direction_to(b)) * pull_power * c
		picked_object.set_linear_velocity(calc)

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time* BOB_FREQ / 2) * BOB_AMP
	return pos
