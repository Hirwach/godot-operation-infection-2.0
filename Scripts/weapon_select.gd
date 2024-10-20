extends Control
@onready var weapon_select: Control = $"."
@onready var canvas_layer: CanvasLayer = $CanvasLayer


func _process(delta: float) -> void:
	if Input.is_action_pressed("Chose Weapon"):
		CurrentWeapon()


func CurrentWeapon():
	Engine.time_scale = 0.1
	canvas_layer.visible = true

func _on_weapon_1_pressed() -> void:
	print("Weapon 1 selected")
	canvas_layer.visible = false
	Engine.time_scale = 1


func _on_weapon_2_pressed() -> void:
	print("Weapon 2 selected")
	canvas_layer.visible = false
	Engine.time_scale = 1


func _on_weapon_3_pressed() -> void:
	print("Weapon 3 selected")
	canvas_layer.visible = false
	Engine.time_scale = 1
