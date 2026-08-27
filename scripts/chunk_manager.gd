class_name ChunkManager extends Node


var random_generator := FastNoiseLite.new()
var chunk_size: Vector3i
var chunk_class := preload("res://scenes/chunk.tscn")

@export var world_size := Vector3i(5, 5, 5)
@export var chunk_length: int = 16
@export var noise_seed: int = 0
@export var terrain_colors: Array[Color] = [Color.RED]


func _ready() -> void:
	random_generator.noise_type = FastNoiseLite.TYPE_SIMPLEX
	random_generator.frequency = 0.003
	random_generator.seed = noise_seed

	chunk_size = world_size / chunk_length

	generate_chunks()

func generate_chunks() -> void:
	var total_chunks = chunk_size.x * chunk_size.y * chunk_size.z

	for pos_y in range(total_chunks):
		var pos_z: int = pos_y / chunk_size.y if chunk_size.y > 0 else 0
		var pos_x: int = pos_z / chunk_size.z if chunk_size.z > 0 else 0
		var position := Vector3i(
				pos_x % chunk_size.x,
				pos_y % chunk_size.y,
				pos_z % chunk_size.z,
		)

		var new_chunk = chunk_class.instantiate()
		new_chunk.position = position * chunk_length

		add_child(new_chunk)
		generate_chunk_data(new_chunk)

func generate_chunk_data(chunk: Chunk) -> void:
	chunk.generate_data(chunk_length, world_size.y, random_generator, terrain_colors)
	chunk.generate_mesh()
