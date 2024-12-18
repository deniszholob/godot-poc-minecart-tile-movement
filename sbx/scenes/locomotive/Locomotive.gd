extends CharacterBody2D

enum MOVE_STATE {
	STOPPED,
	FORWARD,
	BACKWARD,
}
# Constants
const ACCELERATION:int = 10  # Acceleration rate
const BRAKE: int = ACCELERATION * 5  # Brake rate
const SLOWDOWN: int = ACCELERATION / 2  # Slowdown rate
const TURN_SPEED = 0.1  # Turning speed
const CLOSE_ENOUGH = 0.1  # Close enough value to consider velocity as zero
const TOP_SPEED: int = 5

@export var stateLabel: Label
@export var velocityLabel: Label
@export var acceleration_label: Label
@export var indended_acceleration_label: Label

# Variables
var acceleration: int = 0
# Direction the front of the actor is facing (can point up but move down for example), change on turns
var direction: Vector2 = Vector2.RIGHT
var state: MOVE_STATE = MOVE_STATE.STOPPED


func _physics_process(delta: float):
	velocityLabel.text = str(velocity)
	acceleration_label.text = str(acceleration)

	match state:
		MOVE_STATE.STOPPED:
			stateLabel.text = str('STOPPED')
			print('STOPPED', state)
			on_state_stopped()
		MOVE_STATE.FORWARD:
			stateLabel.text = str('FORWARD')
			print('FORWARD', state)
			on_state_forward(delta)
		MOVE_STATE.BACKWARD:
			print('BACKWARD', state)
			stateLabel.text = str('BACKWARD')
			on_state_backward(delta)


	### Handle turning
	#if Input.is_action_pressed("turn_left"):
		#direction = direction.rotated(TURN_SPEED)
	#elif Input.is_action_pressed("turn_right"):
		#direction = direction.rotated(-TURN_SPEED)
#
	## Stop at the end of the rail
	#if is_at_end_of_rail():
		#velocity = Vector2.ZERO
		#state = MOVE_STATE.STOPPED


	# Move the locomotive
	move_and_collide(velocity)


func on_state_stopped() -> void:
	acceleration = 0
	#print('on_state_stopped', Input.is_action_pressed("accelerate"), Input.is_action_pressed("brake"))
	if Input.is_action_pressed("accelerate"):
		state = MOVE_STATE.FORWARD
		print('on_state_stopped change state: FORWARD', state)

	if Input.is_action_pressed("brake"):
		print('on_state_stopped change state: BACKWARD', state)
		state = MOVE_STATE.BACKWARD


func on_state_forward(delta: float) -> void:
	var intended_acceleration: int = 0
	if Input.is_action_pressed("accelerate"):
		intended_acceleration = ACCELERATION
	elif Input.is_action_pressed("brake"):
		intended_acceleration = -BRAKE

	indended_acceleration_label.text = str(intended_acceleration)

	if(intended_acceleration == 0 and velocity.length() != 0):
		acceleration = -SLOWDOWN
	else:
		acceleration = intended_acceleration

	velocity += direction * acceleration * delta
	if(velocity.x > TOP_SPEED): velocity.x = TOP_SPEED
	if(velocity.x < -TOP_SPEED): velocity.x = -TOP_SPEED
	if(velocity.y > TOP_SPEED): velocity.y = TOP_SPEED
	if(velocity.y < -TOP_SPEED): velocity.y = -TOP_SPEED
	# Make velocity exactly zero if it's close to zero
	if (velocity.length() < CLOSE_ENOUGH):
		velocity = Vector2.ZERO
		state = MOVE_STATE.STOPPED

func on_state_backward(delta: float) -> void:
	var intended_acceleration: int = 0
	if Input.is_action_pressed("accelerate"):
		intended_acceleration = BRAKE
	elif Input.is_action_pressed("brake"):
		intended_acceleration = -ACCELERATION

	indended_acceleration_label.text = str(intended_acceleration)

	if(intended_acceleration == 0 and velocity.length() != 0):
		acceleration = SLOWDOWN
	else:
		acceleration = intended_acceleration

	velocity += direction * acceleration * delta
	if(velocity.x > TOP_SPEED): velocity.x = TOP_SPEED
	if(velocity.x < -TOP_SPEED): velocity.x = -TOP_SPEED
	if(velocity.y > TOP_SPEED): velocity.y = TOP_SPEED
	if(velocity.y < -TOP_SPEED): velocity.y = -TOP_SPEED
	# Make velocity exactly zero if it's close to zero
	if (velocity.length() < CLOSE_ENOUGH):
		velocity = Vector2.ZERO
		state = MOVE_STATE.STOPPED
