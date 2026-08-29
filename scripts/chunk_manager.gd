class_name ChunkManager extends Node


var chunk_loading_threads: Array[Thread] = []
var random_generator := FastNoiseLite.new()
var chunk_count: Vector3i
var chunk_class := preload("res://scenes/chunk.tscn")
var thread_split: Vector2i = Vector2i(1, 1)

@export var world_size := Vector3i(32, 32, 32)
@export var chunk_length: int = 16
@export var noise_seed: int = 0
@export var thread_count: int = 2
@export var terrain_colors: Array[Color] = [Color.RED]


func _ready() -> void:
	world_size = world_size - (world_size % chunk_length)
	noise_seed = noise_seed if noise_seed > 0 else randi()
	chunk_count = world_size / chunk_length
	thread_split = get_split(thread_count)

	random_generator.noise_type = FastNoiseLite.TYPE_SIMPLEX
	random_generator.frequency = 0.003
	random_generator.seed = noise_seed
	terrain_colors.reverse()

	var thread_idx: int = 0
	var world_area_covered := Vector3i.ZERO

	var base_x: int = world_size.x / thread_split.x
	var remainder_x: int = world_size.x % thread_split.x

	var base_z: int = world_size.z / thread_split.y
	var remainder_z: int = world_size.z % thread_split.y

	print(thread_split)
	print(chunk_count)

	for idx in range(thread_count):
		chunk_loading_threads.append(Thread.new())

	for axis_x in range(thread_split.x):
		var x: int = base_x + (1 if axis_x < remainder_x else 0)

		world_area_covered.z = 0

		for axis_y in range(thread_split.y):
			var z: int = base_z + (1 if axis_y < remainder_z else 0)
			var thread: Thread = chunk_loading_threads.get(thread_idx)
			var offset := world_area_covered
			var area := Vector3i(
					x - (x % chunk_length),
					0,
					z - (z % chunk_length)
			)

			var chunks := Vector3i(
					area.x / chunk_length,
					chunk_count.y,
					area.z / chunk_length,
			)

			thread.start(generate_chunks.bind(offset, chunks))
			world_area_covered.z += area.z
			thread_idx += 1

		world_area_covered.x += x

func _exit_tree() -> void:
	for thread in chunk_loading_threads:
		thread.wait_to_finish()

static func get_split(pieces: int) -> Vector2i:
	if pieces <= 0:
		pieces = 1

	var x := int(sqrt(pieces))

	while x > 1 and (pieces % x) != 0:
		x -= 1

	var y := pieces / x

	return Vector2i(x, y)

func generate_chunks(start_position: Vector3i, chunks_to_load: Vector3i) -> void:
	var total_chunks_to_load: int = chunks_to_load.x * chunks_to_load.y * chunks_to_load.z

	for pos_y in range(total_chunks_to_load):
		var pos_z: int = (pos_y / chunks_to_load.y) if chunks_to_load.y > 0 else 0
		var pos_x: int = (pos_z / chunks_to_load.z) if chunks_to_load.z > 0 else 0
		var position := Vector3i(
				pos_x % chunks_to_load.x,
				pos_y % chunks_to_load.y,
				pos_z % chunks_to_load.z,
		)

		var new_chunk: Chunk = chunk_class.instantiate()
		new_chunk.position = (position * chunk_length) + start_position

		generate_chunk_data(new_chunk)

func generate_chunk_data(chunk: Chunk) -> void:
	chunk.init_cube(1)
	chunk.generate_data(chunk_length, world_size.y, random_generator, terrain_colors)
	chunk.generate_mesh()
	call_deferred("add_child", chunk)
