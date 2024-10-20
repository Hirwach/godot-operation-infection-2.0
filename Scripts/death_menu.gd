extends Control
@onready var canvas_layer: CanvasLayer = $CanvasLayer


func _on_restart_pressed() -> void:
	canvas_layer.visible = false
	Engine.time_scale = 1
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_player_player_death() -> void:
	Engine.time_scale = 0.05
	canvas_layer.visible = true
