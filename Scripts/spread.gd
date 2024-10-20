extends Area3D

@export var object_to_duplicate : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect the body_entered signal to handle collisions with CharacterBody3D
	connect("body_entered", Callable(self, "_on_body_entered"))

# Signal callback function that handles when a body enters the Area3D
func _on_body_entered(body):
	# Check if the body is a CharacterBody3D
	if body is CharacterBody3D:
		# Call a function to duplicate this object
		duplicate_object()

# Function to duplicate the object
func duplicate_object():
	# Check if the object to duplicate is set
	if object_to_duplicate:
		# Create a new instance of the object
		var new_instance = object_to_duplicate.instantiate()
		# Set the position of the new instance (for example, next to the original)
		new_instance.global_transform.origin = self.global_transform.origin + Vector3(2, 0, 0) # Adjust the position as needed
		# Add the new instance to the scene
		get_parent().add_child(new_instance)
