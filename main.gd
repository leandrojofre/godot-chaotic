extends Node

@onready var chunk_manager: ChunkManager = $ChunkManager
@onready var seed_label: Label = $Seed

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	seed_label.text = "Seed: " + str(chunk_manager.noise_seed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _on_seed_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("pointer_interact"):
		print(chunk_manager.noise_seed)
		DisplayServer.clipboard_set(str(chunk_manager.noise_seed))
