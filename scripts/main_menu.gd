extends Node2D



func _on_start_pressed() -> void:
	var st := get_node_or_null("/root/SceneTransition")
	if st != null and st.has_method("transition_to"):
		st.transition_to(
			"res://scenes/levels/3_part.tscn",
			PackedStringArray(),
			PackedStringArray(["res://assets/cutscene1.png"])
		)
	else:
		get_tree().change_scene_to_file("res://scenes/levels/3_part.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit() # Replace with function body.x
