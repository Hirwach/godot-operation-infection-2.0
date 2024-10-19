extends Area3D

var movement_direction : Vector3 = Vector3.ZERO

func setup(dir : Vector3):
	movement_direction = Vector3(dir.x, 0, dir.z).normalized()
	
	look_at(global_position + movement_direction)



func _process(delta):
	
	global_position += movement_direction * Values.bullet_speed_player * delta
	



func _on_body_entered(body):
	if body.is_in_group("Enemy"):
		body.infect()
	
	queue_free()
