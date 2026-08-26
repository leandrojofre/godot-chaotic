extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 9

@export var camera_sensitivity: float = 0.006
@export var flying: bool = false

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		if flying:
			velocity = Vector3.ZERO 
		else:
			velocity += get_gravity() * delta

	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("jump") and flying:
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("toggle_fly"):
		flying = !flying

	var speed = SPEED
	var input_dir := Input.get_vector("move_west", "move_east", "move_north", "move_south")
	var direction := (camera.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if Input.is_action_pressed("run"):
		speed = SPEED * 2

	if direction:
		if flying:
			velocity = direction * speed
		else:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var camera_rotation = event.relative * camera_sensitivity
		head.rotate_y(-camera_rotation.x)
		camera.rotate_x(-camera_rotation.y)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(90))
