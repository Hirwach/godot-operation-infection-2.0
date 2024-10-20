extends MeshInstance3D

const BOOM = preload("res://Scenes/boom.tscn")
var t : float = 0

var movement_direction : Vector3 = Vector3.ZERO


func setup(dir : Vector3):
	movement_direction = Vector3(dir.x, Values.molotov_up_dir, dir.z).normalized()
	
	look_at(global_position + movement_direction)


func _process(delta):
	
	t += delta
	
	movement_direction.y -= t * Values.molotov_gravity
	
	var new_pos = Vector3.ZERO
	
	new_pos.x = movement_direction.x * Values.molotov_speed * delta
	new_pos.z = movement_direction.z * Values.molotov_speed * delta
	new_pos.y = movement_direction.y * Values.molotov_speed * delta
	
	global_position = global_position + movement_direction * Values.molotov_speed * delta - Vector3(0,(0.5 * Values.molotov_gravity**2),0)
	
	if global_position.y <= 0 :
		boom()
	


func boom():
	
	var enemies = get_tree().get_nodes_in_group("Enemy")
	
	for enemy in enemies:
		if global_position.distance_to(enemy.global_position) <= Values.molotov_range:
			enemy.die()
	
	var b = BOOM.instantiate()
	
	get_tree().root.add_child(b)
	
	b.global_position = global_position
	
	queue_free()
