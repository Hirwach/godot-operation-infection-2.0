extends Control
@onready var weapon_select: Control = $"."
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var player: CharacterBody3D = $".."


func _process(delta: float) -> void:
	if Input.is_action_pressed("Chose Weapon"):
		CurrentWeapon()


func CurrentWeapon():
	Engine.time_scale = 0.1
	canvas_layer.visible = true

func _on_weapon_1_pressed() -> void:
	player.can_shoot_bull()
	canvas_layer.visible = false
	Engine.time_scale = 1


func _on_weapon_2_pressed() -> void:
	player.can_shoot_infect()
	canvas_layer.visible = false
	Engine.time_scale = 1


func _on_weapon_3_pressed() -> void:
	player.can_shoot_molo()
	canvas_layer.visible = false
	Engine.time_scale = 1
