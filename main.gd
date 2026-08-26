extends Node

var block_positions: Array[Vector3] = []

@export var world_size := Vector3i(5, 5, 5)
@export var terrain_colors: Array[Color]
@export_range(-1, 1, 0.1) var cut_off: float = 0.5

@onready var player: CharacterBody3D = $Player
@onready var terrain_mesh: MultiMeshInstance3D = $TerrainMesh


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	var total_world_size: int = world_size.x * world_size.y * world_size.z
	var random_generator := FastNoiseLite.new()

	for idx in total_world_size:
		var pos_z: int = idx / world_size.y if world_size.y > 0 else 0
		var pos_x: int = pos_z / world_size.z if world_size.z > 0 else 0
		var position := Vector3i(
				pos_x % world_size.x,
				idx % world_size.y,
				pos_z % world_size.z,
		)

		var random: float = random_generator.get_noise_3d(
				position.x,
				position.y,
				position.z,
		)

		if random > cut_off:
			block_positions.append(position)

	var multimesh = terrain_mesh.multimesh

	multimesh.instance_count = block_positions.size()

	for idx in multimesh.instance_count:
		multimesh.set_instance_transform(idx, Transform3D(Basis.IDENTITY, block_positions.get(idx)))
		multimesh.set_instance_color(idx, terrain_colors.pick_random())

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
