extends Control


@onready var health = $CanvasLayer/VBoxContainer/Health
@onready var enemies_left = $CanvasLayer/VBoxContainer/EnemiesLeft


var enemy_count : int = 0


func _ready():
	
	enemy_count = get_tree().get_nodes_in_group("Enemy").size()
	
	SignalManager.on_enemy_killed_phase_one.connect(on_enemy_killed_phase_one)
	SignalManager.new_player_health.connect(update_health)
	
	health.text = "Health : " + str(get_tree().get_first_node_in_group("Player").health)
	enemies_left.text = "Enemies left : " + str(enemy_count)


func on_enemy_killed_phase_one():
	
	
	enemy_count -= 1
	enemies_left.text = "Enemies left : " + str(enemy_count)
	
	if enemy_count <= 0:
		SignalManager.phase_two_started.emit()
	


func update_health(n : int):
	health.text = "Health : " + str(n)
