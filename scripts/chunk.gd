class_name Chunk extends StaticBody3D

enum Face {
	TOP,
	BOTTOM,
	FRONT,
	BACK,
	LEFT,
	RIGHT,
}

var voxels: Dictionary[Vector3, Color] = {}

var surface_array: Array = []
var vertices := PackedVector3Array()
var normals := PackedVector3Array()
var colors := PackedColorArray()

var cube_vertices: Array[Vector3] = []
var face_indexes: Dictionary[Face, Array] = {}
var face_normals: Dictionary[Face, Vector3] = {}
var face_colors: Dictionary[Face, Color] = {}

@export var material: Material
@onready var hitbox: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	surface_array.resize(Mesh.ARRAY_MAX)
	mesh_instance.mesh = ArrayMesh.new()

	if voxels.is_empty(): return

	commit_mesh()

func random_noise(noise: Noise, x: int, y: int) -> float:
	var noise_first = noise.get_noise_2d(x, y)
	var noise_double = noise.get_noise_2d(x * 2, y * 2) * 0.5
	var noise_fourth = noise.get_noise_2d(x * 4, y * 4) * 0.25
	var noise_calc = ((noise_first + noise_double + noise_fourth) / 1.75 + 1) / 2
	var noise_p = pow(noise_calc, 2.1)
	return noise_p

func generate_data(chunk_size: int, max_height: int, noise: Noise, block_colors: Array[Color]) -> void:
	var height_ratio: int = max_height / max(block_colors.size(), 1)
	var color_idx: int = int(position.y / height_ratio) if position.y > 0 else 0
	var chunk_color = block_colors.get(color_idx)

	for x in range(chunk_size):
		for z in range(chunk_size):
			var global_offset = Vector2(x + position.x, z  + position.z)
			var random = random_noise(noise, global_offset.x, global_offset.y)
			var height = max_height * random

			if height < position.y: continue

			var local_height = height - position.y

			for y in range(min(local_height, chunk_size)):
				voxels.set(Vector3(x, y, z), chunk_color)

func generate_mesh() -> void:
	for offset in voxels:
		var color = voxels[offset]

		for face in Face:
			if not has_neighbour(voxels, Face[face], offset):
				add_face(Face[face], offset, color)

func commit_mesh() -> void:
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_COLOR] = colors

	var mesh = mesh_instance.mesh

	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	mesh.surface_set_material(0, material)

	hitbox.shape = mesh.create_trimesh_shape()

func add_face(face: Face, offset: Vector3, color: Color) -> void:
	var indexes = face_indexes[face]

	for triangle in indexes:
		for index in triangle:
			vertices.append(cube_vertices[index] + offset)
			normals.append(face_normals[face])
			colors.append(color)

func has_neighbour(data: Dictionary[Vector3, Color], face: Face, offset: Vector3) -> bool:
	var neighbour_position = offset + face_normals[face]

	if data.has(neighbour_position): return true
	return false

func init_cube(size: float) -> void:
	var half_size: float = size / 2

	cube_vertices.append(Vector3(-half_size, -half_size, half_size))
	cube_vertices.append(Vector3(half_size, -half_size, half_size))
	cube_vertices.append(Vector3(half_size, -half_size, -half_size))
	cube_vertices.append(Vector3(-half_size, -half_size, -half_size))
	cube_vertices.append(Vector3(-half_size, half_size, half_size))
	cube_vertices.append(Vector3(half_size, half_size, half_size))
	cube_vertices.append(Vector3(half_size, half_size, -half_size))
	cube_vertices.append(Vector3(-half_size, half_size, -half_size))

	face_indexes.set(Face.FRONT, [[0, 4, 5], [0, 5, 1]])
	face_indexes.set(Face.BACK, [[2, 6 , 7], [2, 7, 3]])
	face_indexes.set(Face.LEFT, [[3, 7 ,4], [3, 4, 0]])
	face_indexes.set(Face.RIGHT, [[1, 5, 6], [1, 6, 2]])
	face_indexes.set(Face.TOP, [[4, 7, 6], [4, 6, 5]])
	face_indexes.set(Face.BOTTOM, [[3, 0, 1], [3, 1, 2]])

	face_normals.set(Face.FRONT, Vector3(0, 0, 1))
	face_normals.set(Face.BACK, Vector3(0, 0, -1))
	face_normals.set(Face.LEFT, Vector3(-1, 0, 0))
	face_normals.set(Face.RIGHT, Vector3(1, 0, 0))
	face_normals.set(Face.TOP, Vector3(0, 1, 0))
	face_normals.set(Face.BOTTOM, Vector3(0, -1, 0))

	face_colors.set(Face.FRONT, Color.RED)
	face_colors.set(Face.BACK, Color.CYAN)
	face_colors.set(Face.LEFT, Color.MAGENTA)
	face_colors.set(Face.RIGHT, Color.GREEN)
	face_colors.set(Face.TOP, Color.BLUE)
	face_colors.set(Face.BOTTOM, Color.YELLOW)
