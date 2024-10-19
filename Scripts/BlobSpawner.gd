extends Marker3D

@onready var timer = $Timer

var phase_two_started : bool = false

const BLOB_PHASE_2 = preload("res://Scenes/blob_phase_2.tscn")


func _ready():
	SignalManager.phase_two_started.connect(phase_deux_started)



func phase_deux_started():
	phase_two_started = true




func spawn_blob():
	var b = BLOB_PHASE_2.instantiate()
	get_tree().root.add_child(b)
	b.global_position = global_position + Vector3(0,1,0)


func _on_timer_timeout():
	if phase_two_started and get_tree().get_nodes_in_group("Enemy").size() <= Values.max_enemies:
		spawn_blob()
	
	timer.wait_time = randf_range(Values.min_spawn_time, Values.max_spawn_time)
	timer.start()
