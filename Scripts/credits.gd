extends Control
@onready var animated_sprite_2d: AnimatedSprite2D = $CanvasLayer/VBoxContainer/Back/AnimatedSprite2D


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_back_mouse_entered() -> void:
	animated_sprite_2d.play("hover")
	
func _on_back_mouse_exited() -> void:
	animated_sprite_2d.play("default")
