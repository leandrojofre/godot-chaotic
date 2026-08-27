extends MeshInstance3D

enum Face {
	TOP,
	BOTTOM,
	FRONT,
	BACK,
	LEFT,
	RIGHT,
}

var surface_array: Array = []
var vertices := PackedVector3Array()
var normals := PackedVector3Array()
var colors := PackedColorArray()

var cube_vertices: Array[Vector3] = []
var face_indexes: Dictionary[Face, Array] = {}
var face_normals: Dictionary[Face, Vector3] = {}
var face_colors: Dictionary[Face, Color] = {}

@export var material: Material
@onready var hitbox: CollisionShape3D = $StaticBody3D/CollisionShape3D


func generate_mesh(data: Dictionary[Vector3, Color], cube_size: int = 1) -> void:
	surface_array.resize(Mesh.ARRAY_MAX)

	init_cube(cube_size)

	for offset in data:
		var color = data[offset]

		for face in Face:
			if not has_neighbour(data, Face[face], offset):
				add_face(Face[face], offset, color)

	commit_mesh()

func commit_mesh() -> void:
	surface_array[Mesh.ARRAY_VERTEX] = vertices
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_COLOR] = colors

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
