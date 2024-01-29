extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const shootingCooldown = 3
const bullet_scene = preload("res://prototypes/game-shadows-of-surveillance/characters/droneBullet.tscn")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player
var shootingTimer = 0

func _ready():
	player = get_parent().get_node("Player2")
	print(player)

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
		
	if player:
		var distanceToPlayer = position.distance_to(player.position)
		print(distanceToPlayer)
		if distanceToPlayer > 200: 
			shootingTimer += delta
			if shootingTimer > shootingCooldown:
				shoot()
				shootingTimer = 0
	move_and_slide()

func shoot():
	var b = bullet_scene.instantiate()
	var direction = (get_global_mouse_position() - global_position).normalized()
	b.setup(direction, $Marker2D.global_position)
	owner.add_child(b)
