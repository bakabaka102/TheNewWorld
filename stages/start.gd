extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print_debug("delta value --- ", delta)
	pass


func _on_btn_start_pressed() -> void:
	get_tree().change_scene_to_file("res://stages/home.tscn")
	pass # Replace with function body.


func _on_btn_exit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.


func _on_btn_options_pressed() -> void:
	pass # Replace with function body.
