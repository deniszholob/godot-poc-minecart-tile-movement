extends RigidBody2D

# Define movement parameters
var acceleration = 500.0
var brake_force = 800.0
var max_speed = 200.0
var stop_threshold = 5.0

func _physics_process(delta):
	# Get the direction of the vehicle
	var direction = Vector2.UP if linear_velocity.y >= 0 else Vector2.DOWN

	# Apply throttle
	if Input.is_action_pressed("accelerate"):
		apply_force(direction * acceleration)

	# Apply brakes
	if Input.is_action_pressed("brake"):
		if linear_velocity.length() < stop_threshold:
			# If velocity is close to 0, apply acceleration in the opposite direction
			apply_force(direction * acceleration)
		else:
			# Apply brakes
			apply_force(-linear_velocity.normalized() * brake_force)

	# Check if velocity is close to 0
	if linear_velocity.length() < stop_threshold:
		linear_velocity = Vector2.ZERO
