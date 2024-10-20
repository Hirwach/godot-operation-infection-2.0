extends CharacterBody3D
signal PlayerDeath

@onready var bullet_cooldown = $BulletCooldown
@onready var infection_countdown = $InfectionCountdown
@onready var molotov_countdown = $MolotovCountdown

enum Weapons {gun, infection, molotov}

var current_weapon : Weapons = Weapons.gun

const INFECTED_BULLET = preload("res://Scenes/infected_bullet.tscn")
const Molotov = preload("res://Scenes/molotov.tscn")

var move_direction : Vector3 = Vector3.ZERO
var look_direction : Vector3 = Vector3.ZERO

var target_rotation : float = 0
var target_lean : float = 0

@onready var head = $Head
@onready var spring_arm_3d = $SpringArm3D

var health : int = 100

const PLAYER_BULLET = preload("res://Scenes/player_bullet.tscn")
@onready var l = $Head/Shooters/L
@onready var r = $Head/Shooters/R
@onready var l_front = $Head/Shooters/L/L_front
@onready var r_front = $Head/Shooters/R/R_front
@onready var m = $Head/Shooters/M
@onready var m_front = $Head/Shooters/M/M_front


var phase_two_started : bool = false


var can_shoot_bullets : bool = false
var can_shoot_infection : bool = false
var can_shoot_molotov : bool = false

func can_shoot_bull():
	can_shoot_bullets = true
	can_shoot_infection = false
	can_shoot_molotov = false
	
func can_shoot_infect():
	can_shoot_bullets = false
	can_shoot_infection = true
	can_shoot_molotov = false
	
func can_shoot_molo():
	can_shoot_bullets = false
	can_shoot_infection = false
	can_shoot_molotov = true

func _ready():
	axis_lock_linear_y = true
	
	SignalManager.phase_two_started.connect(phase_deux_started)
	


func _process(delta):
	
	set_move_direction()
	
	set_look_direction()
	
	
	process_movement(delta)
	
	process_attack()
	
	pan_camera(delta)
	
	look_around(delta)
	
	
	move_and_slide()


func next_weapon():
	if current_weapon == Weapons.gun : current_weapon = Weapons.infection
	elif current_weapon == Weapons.infection : current_weapon = Weapons.molotov
	else : current_weapon = Weapons.gun


func process_attack():
	
	
	if Input.is_action_just_pressed("Attack"):
		perform_stealth_kill()
	
	
	if not phase_two_started:
		return
	
	if Input.is_action_just_pressed("switch") : next_weapon()
	
	if Input.is_action_pressed("Shoot1"):
		if current_weapon == Weapons.gun : shoot_bullet()
		elif current_weapon == Weapons.infection : shoot_infection()
		elif current_weapon == Weapons.molotov : shoot_molotov()
	
	pass



func set_look_direction():
	var look_axis = Vector2(Input.get_action_strength("right_look") - Input.get_action_strength("left_look"),
	Input.get_action_strength("down_look") - Input.get_action_strength("up_look"))
	
	look_direction = Vector3( look_axis.x, 0, look_axis.y)
	
	look_direction = look_direction.rotated(Vector3.UP, spring_arm_3d.rotation.y).normalized()
	
	look_direction.y = 0



func phase_deux_started():
	phase_two_started = true

	

func shoot_molotov():
	
	if not can_shoot_molotov:
		return
	
	var mo = Molotov.instantiate()
	
	get_tree().root.add_child(mo)
	
	mo.global_position = m.global_position
	mo.setup(m.global_position.direction_to(m_front.global_position))
	
	can_shoot_molotov = false
	molotov_countdown.start()



func perform_stealth_kill():
	var enemies_in_radius = get_enemies_in_radius(Values.stealth_kill_radius)
	if enemies_in_radius != null:
		for enemy in enemies_in_radius:
			if enemy.current_state == enemy.States.patrol or enemy.current_state == enemy.States.search:
				enemy.die()



func shoot_infection():
	if not can_shoot_infection:
		return
	
	var inf = INFECTED_BULLET.instantiate()
	
	get_tree().root.add_child(inf)
	
	inf.global_position = m.global_position
	inf.setup(m.global_position.direction_to(m_front.global_position))
	
	can_shoot_infection = false
	infection_countdown.start()


func shoot_bullet():
	
	if not can_shoot_bullets:
		return
	
	var bl = PLAYER_BULLET.instantiate()
	var br = PLAYER_BULLET.instantiate()
	
	get_tree().root.add_child(bl)
	get_tree().root.add_child(br)
	
	bl.global_position = l.global_position
	br.global_position = r.global_position
	
	bl.setup(l.global_position.direction_to(l_front.global_position))
	br.setup(r.global_position.direction_to(r_front.global_position))
	
	can_shoot_bullets = false
	bullet_cooldown.start()
	
	


func set_move_direction():
	var move_axis = Vector2(Input.get_action_strength("right") - Input.get_action_strength("left"),
	Input.get_action_strength("down") - Input.get_action_strength("up"))
	
	move_direction = Vector3( move_axis.x, 0, move_axis.y)
	
	move_direction = move_direction.rotated(Vector3.UP, spring_arm_3d.rotation.y).normalized()
	
	move_direction.y = 0



func get_enemies_in_radius(radius : float) -> Array[Node3D] :
	var enemies = get_tree().get_nodes_in_group("Enemy")
	var enemies_in_radius : Array[Node3D] = []
	
	for enemy in enemies:
		if (enemy.global_position - global_position).length() <= radius:
			enemies_in_radius.append(enemy)
	
	return enemies_in_radius



func take_damage(value : int):
	health -= value
	SignalManager.new_player_health.emit(health)
	if health <= 0:
		PlayerDeath.emit()



func process_movement(delta : float):
	
	
	velocity = move_direction * Values.player_speed * delta



func pan_camera(delta : float):
	var pan_axis = Input.get_action_strength("e") - Input.get_action_strength("q")
	
	spring_arm_3d.rotation.y += pan_axis * Values.camera_pan_speed * delta


func look_around(delta : float):
	
	if look_direction != Vector3.ZERO :
		target_rotation = Vector2(look_direction.x, -look_direction.z).angle()
		if move_direction == Vector3.ZERO : target_lean = 0
	
	elif move_direction != Vector3.ZERO :
		target_rotation = Vector2(move_direction.x, -move_direction.z).angle()
		target_lean = deg_to_rad(Values.lean_value)
	else : target_lean = 0
	
	head.rotation.y = rotate_toward(head.rotation.y, target_rotation, Values.rotate_speed * delta)
	head.rotation.z = rotate_toward(head.rotation.z, target_lean, Values.lean_speed * delta)



func _on_bullet_cooldown_timeout():
	can_shoot_bullets = true


func _on_infection_countdown_timeout():
	can_shoot_infection = true


func _on_molotov_countdown_timeout():
	can_shoot_molotov = true
