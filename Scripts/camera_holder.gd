extends SpringArm3D



func _process(delta):
	var pan_axis = Input.get_action_strength("e") - Input.get_action_strength("q")
	
	rotation.y += pan_axis * Values.camera_pan_speed * delta
