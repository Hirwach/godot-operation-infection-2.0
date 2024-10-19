extends CharacterBody3D





enum States {patrol, chase, search, infected}

const ENEMY_BULLET = preload("res://Scenes/enemy_bullet.tscn")
const PLAYER_BULLET = preload("res://Scenes/player_bullet.tscn")
@onready var shooter = $Head/Shooter

const BLOB_SPHERE_001 = preload("res://Models/blob_infected.tres")

var current_state : States = States.patrol
@onready var icon = $Head/Sprite3D2

@onready var head = $Head

@export var wp_node : Node3D
@onready var ray_cast_3d = $RayCast3D
var waypoints : Array
var current_wp : int = 0

@onready var attack_timer = $AttackTimer

@onready var nav_agent = $NavigationAgent3D

var player_ref

@onready var infect_timer = $InfectTimer


var offset = 1


func _ready():
	
	waypoints = wp_node.get_children() as Array[Marker3D]
	
	set_current_state(States.patrol)
	update_target_location(waypoints[current_wp].position)
	
	
	axis_lock_linear_y = true
	
	player_ref = get_tree().get_first_node_in_group("Player")


func _process(delta):
	
	
	calculate_velocity(delta)
	
	look_at_target(delta)
	
	process_states()
	
	
	
	move_and_slide()


func calculate_velocity(delta : float):
	var next_location = nav_agent.get_next_path_position()
	var new_vel = (next_location - global_position).normalized() * delta * Values.enemy_speed
	new_vel.y = 0
	
	velocity = new_vel


func look_at_target(delta : float):
	var direction_to_target =  velocity.normalized()
	var rotation_vector = Vector2(-direction_to_target.z, -direction_to_target.x)
	head.rotation.y = rotate_toward(head.rotation.y, rotation_vector.angle(), Values.rotate_speed * delta)



func update_target_location(location : Vector3):
	nav_agent.target_position = location



func player_in_fov() -> bool :
	
	ray_cast_3d.look_at(player_ref.global_position + Vector3.UP * offset)
	var ray_rot = ray_cast_3d.global_rotation_degrees.y
	var blob_rot = head.global_rotation_degrees.y
	
	var angle_to_player = wrapf(ray_rot - blob_rot, -180, 180)
	
	if angle_to_player >= -Values.blob_fov_angle and angle_to_player <= Values.blob_fov_angle :
		if ray_cast_3d.get_collider() != null :
			if ray_cast_3d.get_collider().is_in_group("Player"):
				return true
	
	return false



func process_states():
	
	if current_state == States.infected:
		if get_closest_enemy() == null:
			die()
			return
		update_target_location(get_closest_enemy().global_position)
	
	if current_state == States.patrol :
		if nav_agent.is_target_reached():
			next_waypoint()
			update_target_location(waypoints[current_wp].global_position)
		
		
		if player_in_fov():
			set_current_state(States.chase)
		
	
	elif current_state == States.chase :
		if player_in_fov():
			update_target_location(player_ref.global_position)
		else : set_current_state(States.search)
	
	elif current_state == States.search :
		if not player_in_fov() and nav_agent.is_target_reached():
			set_current_state(States.patrol)
		elif player_in_fov():
			set_current_state(States.chase)
	
	
	
	pass



func attack():
	
	if current_state == States.infected:
		
		shoot_friendly_bullets()
		
		return
	
	elif current_state == States.chase :
	
		var distance_to_player = (player_ref.global_position - global_position).length()
	
		if distance_to_player <= Values.blob_short_attack_range:
			player_ref.take_damage(Values.blob_damage)
		else : shoot()
	
	pass



func shoot_friendly_bullets():
	var new_b = PLAYER_BULLET.instantiate()
	get_tree().root.add_child(new_b)
	new_b.global_position = shooter.global_position
	new_b.setup(global_position.direction_to(shooter.global_position))


func shoot():
	var new_b = ENEMY_BULLET.instantiate()
	get_tree().root.add_child(new_b)
	new_b.global_position = shooter.global_position
	new_b.setup(global_position.direction_to(shooter.global_position))



func next_waypoint():
	current_wp += 1
	if current_wp >= waypoints.size():
		current_wp = 0


func die():
	SignalManager.on_enemy_killed_phase_one.emit()
	queue_free()



func infect():
	
	collision_layer = 32
	
	current_state = States.infected
	
	head.mesh = BLOB_SPHERE_001
	
	infect_timer.start()



func set_current_state(new_state : States):
	current_state = new_state
	
	match new_state:
		States.patrol : icon.modulate = Color.WHITE
		States.chase : icon.modulate = Color.RED
		States.search : icon.modulate = Color.YELLOW
	



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



func _on_attack_timer_timeout():
	if current_state == States.chase : attack_timer.wait_time = randf_range(Values.blob_min_attack_time, Values.blob_max_attack_time)
	if current_state == States.infected : attack_timer.wait_time = Values.infected_shoot_frequency
	if current_state == States.chase or current_state == States.infected:
		attack()
	
	attack_timer.start()


func _on_infect_timer_timeout():
	die()
