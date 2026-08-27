extends Node

func generate_terrain_data() -> void:
	var total_world_size: int = world_size.x * world_size.y * world_size.z

	for idx in range(total_world_size):
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

		if random > cut_off: block_positions.set(
				position * cube_size,
				terrain_colors.get(position.y % terrain_colors.size())
		)

func generate_terrain_mesh() -> void:
	generate_terrain_data()
	terrain_mesh.generate_mesh(block_positions, cube_size)

func generate_terrain_multi_mesh() -> void:
	generate_terrain_data()

	var multimesh = terrain_multi_mesh.multimesh

	multimesh.instance_count = block_positions.size()

	for idx in range(multimesh.instance_count):
		multimesh.set_instance_transform(idx, Transform3D(Basis.IDENTITY, block_positions.get(idx)))
		multimesh.set_instance_color(idx, terrain_colors.pick_random())
