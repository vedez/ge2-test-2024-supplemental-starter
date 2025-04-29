extends Node3D
# This script is attached to a Node3D — meaning it's working in 3D space.

# Exported variables (can edit from editor):
@export var num_tentacles: int = 8  # Number of tentacles
@export var tentacle_length: int = 20  # How many segments (boxes) per tentacle
@export var segment_length: float = 0.5  # Size of each box along the tentacle
@export var wave_speed: float = 2.0  # Speed of waving animation
@export var wave_frequency: float = 1.5  # How many wave bumps along each tentacle
@export var wave_amplitude: float = 0.5  # How much tentacles swing side to side

var tentacle_parts = []
# Array to store all tentacle parts (each tentacle is a list of cubes)

# Called when scene starts
func _ready():
	randomize()  # Randomizes things like colors (if needed)
	spawn_octopus()  # Create the octopus parts (sphere + tentacles)

# Function to create the octopus
func spawn_octopus():
	var body = CSGSphere3D.new()  # Create a new CSG sphere
	body.radius = 1.0  # Set sphere size
	body.material = create_transparent_material()  # Make the sphere transparent
	add_child(body)  # Add the sphere to the scene as a child

	# Loop through and create each tentacle
	for i in range(num_tentacles):
		var angle = (TAU / num_tentacles) * i  # Spread tentacles evenly around 360°
		var tentacle = []  # Create a new list for this tentacle
		
		var base_node = Node3D.new()  # Create a node to rotate the whole tentacle
		base_node.rotation.y = angle  # Rotate the tentacle around Y-axis
		add_child(base_node)  # Add it to the scene

		# Create all the cubes/segments for this tentacle
		for j in range(tentacle_length):
			var box = CSGBox3D.new()  # Create a new box segment
			box.size = Vector3(0.4, 0.4, segment_length)  # Set the box size (narrow box)

			var color_hue = float(j) / tentacle_length  # Calculate color along rainbow
			box.material = create_rainbow_material(color_hue)  # Apply a colorful material

			base_node.add_child(box)  # Attach the box to the tentacle base
			tentacle.append(box)  # Store the box in this tentacle list

		tentacle_parts.append(tentacle)  # Add this whole tentacle to the parts array

# Called every frame (for animation)
func _process(delta):
	animate_octopus(delta)  # Update tentacle movement every frame

# Function to animate tentacle waving
func animate_octopus(delta):
	var time = Time.get_ticks_msec() / 1000.0  # Get the current time in seconds

	# Animate every tentacle
	for tentacle in tentacle_parts:
		for i in range(tentacle.size()):
			var box = tentacle[i]  # Get the box segment
			var wave_offset = time * wave_speed + i * 0.4  # Phase shift for nice ripple
			var offset = sin(wave_offset * wave_frequency) * wave_amplitude  # Sine wave calculation

			# NEW: Position boxes starting close to center
			var distance = i * segment_length  # Distance from center
			var height = -i * segment_length * 0.3  # Slight downward curve as tentacle extends

			# Set the box's position
			box.transform.origin = Vector3(
				offset,   # Move sideways (X) with sine wave
				height,   # Move downward (Y) slightly
				distance  # Move outward (Z) along the tentacle
			)

			box.rotation.x = offset * 0.5  # Slightly rotate box based on wave

# Function to create colorful material based on hue
func create_rainbow_material(hue: float) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()  # Create a new material
	mat.albedo_color = Color.from_hsv(hue, 1.0, 1.0)  # Set color using HSV to get rainbow
	return mat  # Return the material

# Function to create a transparent white material for the body
func create_transparent_material() -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()  # Create new material
	mat.albedo_color = Color(1, 1, 1, 0.1)  # White color with 10% opacity
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA  # Enable alpha transparency
	mat.flags_transparent = true  # Flag material as transparent
	return mat  # Return the transparent material
