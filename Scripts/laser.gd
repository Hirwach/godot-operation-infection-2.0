extends RayCast3D

@onready var beam_mesh = $BeamMesh
@onready var end_particles = $endParticles
@onready var beam_particles = $beamParticles


var tween : Tween
var beam_radius : float = 0.03


# Called when the node enters the scene tree for the first time.
#func _ready():
	#
	#await get_tree().create_timer(1.0).timeout
	#
	#laser_deactivate(0.5)
	#
	#await get_tree().create_timer(1.0).timeout
	#
	#laser_activate(0.5)
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var cast_point
	force_raycast_update()
	
	if is_colliding():
		cast_point = to_local(get_collision_point())
		
		beam_mesh.mesh.height = cast_point.y
		beam_mesh.position.y = cast_point.y/2
		
		end_particles.position.y = cast_point.y
		var particle_amount = snapped(abs(cast_point.y) * 50,1)
		
		if particle_amount > 1:
			beam_particles.amount = particle_amount
		else:
			beam_particles.amount = 1 
			
		beam_particles.process_material.set_emission_box_extents(
			Vector3(beam_mesh.mesh.top_radius,abs(cast_point.y)/2, beam_mesh.mesh.top_radius)
		)
		
func laser_activate(time: float):
	tween = get_tree().create_tween()
	visible = true
	beam_particles.emitting = true
	end_particles.emitting = true
	
	# Animate the beam size and particle properties
	tween.set_parallel(true)
	tween.tween_property(beam_mesh.mesh, "top_radius", beam_radius, time)
	tween.tween_property(beam_mesh.mesh, "bottom_radius", beam_radius, time)
	tween.tween_property(beam_particles.process_material, "scale_min", 0.0, time)
	tween.tween_property(end_particles.process_material, "scale_min", 0.0, time)
	await tween.finished
	

func laser_deactivate(time: float):
	tween = get_tree().create_tween()
	tween.set_parallel(true)
	
	# Animate the shrinking of the beam and stopping particle emission
	tween.tween_property(beam_mesh.mesh, "top_radius", beam_radius, time)
	tween.tween_property(beam_mesh.mesh, "bottom_radius", beam_radius, time)
	tween.tween_property(beam_particles.process_material, "scale_min", 0.0, time)
	tween.tween_property(end_particles.process_material, "scale_min", 0.0, time)
	await tween.finished
	visible = false
	beam_particles.emitting = false
	end_particles.emitting = false
	
	
	
