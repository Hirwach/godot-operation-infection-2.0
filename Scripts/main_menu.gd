extends Control
@onready var start_sprite: AnimatedSprite2D = $VBoxContainer/START/StartSprite
@onready var credit_sprite: AnimatedSprite2D = $VBoxContainer3/CREDITS/CreditSprite


func _on_start_pressed() -> void:
	start_sprite.play("click")			#Needs a timer i think
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_credits_pressed() -> void:
	print("credits")


func _on_how_to_play_pressed() -> void:
	print("How to play")


func _on_start_mouse_entered() -> void:
	start_sprite.play("hover")

func _on_start_mouse_exited() -> void:
	start_sprite.play("default")


func _on_credits_mouse_entered() -> void:
	credit_sprite.play("hover")

func _on_credits_mouse_exited() -> void:
	credit_sprite.play("default")
