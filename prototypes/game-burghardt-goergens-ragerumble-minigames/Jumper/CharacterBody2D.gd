extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var playerpos = 0
var enemypos = 0
var player
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	player = get_tree().get_nodes_in_group("player")[0]
	if player == null:
		return
	playerpos = player.global_position.x
	enemypos = self.global_position.x
	if playerpos <= enemypos:
		velocity.x -= move_toward(velocity.x, playerpos, SPEED/3.0)
	else:
		velocity.x += move_toward(velocity.x, playerpos, SPEED/3.0)

	move_and_slide()
