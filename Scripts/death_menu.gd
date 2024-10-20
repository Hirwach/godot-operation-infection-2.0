extends Control
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var animated_sprite: AnimatedSprite2D = $CanvasLayer/VBoxContainer2/Quit/AnimatedSprite2D
@onready var restartsprite: AnimatedSprite2D = $CanvasLayer/VBoxContainer/Restart/AnimatedSprite2D


func _on_restart_pressed() -> void:
	canvas_layer.visible = false
	Engine.time_scale = 1
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_player_player_death() -> void:
	Engine.time_scale = 0.05
	canvas_layer.visible = true


func _on_quit_mouse_entered() -> void:
	animated_sprite.play("hover")

func _on_quit_mouse_exited() -> void:
	animated_sprite.play("default")


func _on_restart_mouse_entered() -> void:
	restartsprite.play("hover")

func _on_restart_mouse_exited() -> void:
	restartsprite.play("default")
