class_name ChunkManager extends Node


var loading_threads: Array[Thread] = [
	Thread.new(),
	Thread.new(),
	Thread.new(),
	Thread.new(),
]

var random_generator := FastNoiseLite.new()
var chunk_size: Vector3i
var chunk_class := preload("res://scenes/chunk.tscn")

@export var world_size := Vector3i(32, 32, 32)
@export var chunk_length: int = 16
@export var noise_seed: int = 0
@export var thread_split: int = 2
@export var terrain_colors: Array[Color] = [Color.RED]


func _ready() -> void:
	random_generator.noise_type = FastNoiseLite.TYPE_SIMPLEX
	random_generator.frequency = 0.003
	random_generator.seed = noise_seed

	chunk_size = world_size / chunk_length

	loading_threads[0].start(generate_chunks.bind(Vector3i(0, 0, 0)))
	loading_threads[1].start(generate_chunks.bind(Vector3i(world_size.x / thread_split, 0, 0)))
	loading_threads[2].start(generate_chunks.bind(Vector3i(0, 0, world_size.z / thread_split)))
	loading_threads[3].start(generate_chunks.bind(Vector3i(world_size.x / thread_split, 0, world_size.z / thread_split)))

func _exit_tree() -> void:
	for thread in loading_threads:
		thread.wait_to_finish()

func generate_chunks(start_position: Vector3i) -> void:
	var chunks = chunk_size / thread_split
	chunks.y = chunk_size.y

	var total_chunks = chunks.x * chunks.y * chunks.z

	for pos_y in range(total_chunks):
		var pos_z: int = (pos_y / chunks.y) if chunks.y > 0 else 0
		var pos_x: int = (pos_z / chunks.z) if chunks.z > 0 else 0
		var position := Vector3i(
				pos_x % chunks.x,
				pos_y % chunks.y,
				pos_z % chunks.z,
		)

		var new_chunk = chunk_class.instantiate()
		new_chunk.position = (position * chunk_length) + start_position

		generate_chunk_data(new_chunk)

func generate_chunk_data(chunk: Chunk) -> void:
	chunk.init_cube(1)
	chunk.generate_data(chunk_length, world_size.y, random_generator, terrain_colors)
	chunk.generate_mesh()
	call_deferred("add_child", chunk)
