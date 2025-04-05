extends Control



func _on_online_coop_pressed() -> void:
	get_tree().change_scene_to_file("res://Menu Screen/host_selection.tscn")
	pass


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Menu Screen/options_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_local_coop_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/level1.tscn")
