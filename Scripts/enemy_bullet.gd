extends Area3D


var move_direction : Vector3 = Vector3.ZERO


func setup(dir : Vector3):
	
	
	move_direction = Vector3(dir.x, 0, dir.z).normalized()
	
	look_at(global_position + move_direction)


func _process(delta):
	global_position += move_direction * delta * Values.bullet_speed_enemy






func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage(Values.bullet_enemy_damage)
	
	
	queue_free()


func _on_timer_timeout():
	queue_free()
