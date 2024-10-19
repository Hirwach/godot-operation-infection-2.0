extends CharacterBody3D


@onready var head = $Head
@onready var shooter = $Head/Shooter
@onready var ray_cast_3d = $RayCast3D
@onready var nav_agent = $NavigationAgent3D
@onready var attack_timer = $AttackTimer
const BLOB_SPHERE_001 = preload("res://Models/blob_infected.tres")

const ENEMY_BULLET = preload("res://Scenes/enemy_bullet.tscn")
const PLAYER_BULLET = preload("res://Scenes/player_bullet.tscn")



var offset = 1

var player_ref

var can_shoot : bool = false

@onready var infect_timer = $InfectTimer

var infected : bool = false


func _ready():
	player_ref = get_tree().get_first_node_in_group("Player")
	
	axis_lock_linear_y = true


func _process(delta):
	
	if player_in_fov() : can_shoot = true
	else : can_shoot = false
	
	
	update_target_location()
	
	calculate_velocity(delta)
	
	look_at_target(delta)
	
	move_and_slide()
	
	


func calculate_velocity(delta : float):
	
	if nav_agent.is_target_reached():
		velocity = Vector3.ZERO
		return
	
	var next_location = nav_agent.get_next_path_position()
	var new_vel = (next_location - global_position).normalized() * delta * Values.enemy_speed
	new_vel.y = 0
	
	velocity = new_vel


func look_at_target(delta : float):
	var direction_to_target =  velocity.normalized()
	var rotation_vector = Vector2(-direction_to_target.z, -direction_to_target.x)
	head.rotation.y = rotate_toward(head.rotation.y, rotation_vector.angle(), Values.rotate_speed * delta)




func update_target_location():
	
	if infected:
		nav_agent.target_position = get_closest_enemy().global_position
		return
	
	nav_agent.target_position = player_ref.global_position


func player_in_fov() -> bool :
	
	ray_cast_3d.look_at(player_ref.global_position + Vector3.UP * offset)
	
	if not infected : ray_cast_3d.look_at(player_ref.global_position + Vector3.UP * offset)
	else : ray_cast_3d.look_at(get_closest_enemy().global_position)
	
	if ray_cast_3d.get_collider() != null :
		if ray_cast_3d.get_collider().is_in_group("Player") and not infected:
			return true
		elif ray_cast_3d.get_collider().is_in_group("Enemy") and infected:
			return true
	
	return false



func get_closest_enemy() -> Node3D :
	var enemies = get_tree().get_nodes_in_group("Enemy")
	
	var nearest_enemy : Node3D
	
	for enemy in enemies:
		if enemy != self:
			if nearest_enemy == null : nearest_enemy = enemy
			else :
				if global_position.distance_to(enemy.global_position) < global_position.distance_to(nearest_enemy.global_position):
					nearest_enemy = enemy
		
	
	return nearest_enemy


func infect():
	
	
	
	collision_layer = 32
	
	infected = true
	
	head.mesh = BLOB_SPHERE_001
	
	infect_timer.start()



func die():
	queue_free()


func shoot():
	
	var new_b = ENEMY_BULLET.instantiate()
	get_tree().root.add_child(new_b)
	new_b.global_position = shooter.global_position
	new_b.setup(global_position.direction_to(shooter.global_position))


func shoot_inf():
	
	var new_b = PLAYER_BULLET.instantiate()
	get_tree().root.add_child(new_b)
	new_b.global_position = shooter.global_position
	new_b.setup(global_position.direction_to(shooter.global_position))



func _on_attack_timer_timeout():
	
	if global_position.distance_to(player_ref.global_position) <= Values.blob_max_range and not infected:
		player_ref.take_damage(Values.blob_damage)
	
	elif can_shoot:
		if infected : shoot_inf()
		else : shoot()
	
	
	if infected: attack_timer.wait_time = 1
	else : attack_timer.wait_time = randf_range(Values.blob_min_attack_time, Values.blob_max_attack_time)
	
	attack_timer.start()





func _on_infect_timer_timeout():
	die()
