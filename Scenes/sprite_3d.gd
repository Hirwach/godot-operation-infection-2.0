extends Sprite3D

@onready var new_texture = load("res://Sprites/virus_faces/v_mask_green.png")
# Called when the 


func _ready() -> void:
	%Sprite3D.texture = new_texture# Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
