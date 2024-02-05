extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const shootingCooldown = 2
const bullet_scene = preload("res://prototypes/game-shadows-of-surveillance/characters/droneBullet.tscn")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player
var shootingTimer = 0
var minimalHeightDiff = 100

func _ready():
	pass
	
func _physics_process(delta):
	player = get_parent().get_node("Player2")
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	if player:
		var heightDifference = player.position.y - position.y
		print(heightDifference)
		if heightDifference < minimalHeightDiff:
				velocity.y = -130
				minimalHeightDiff = 200
		else:
			minimalHeightDiff = 100
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
	if player:
		var distanceToPlayer = position.distance_to(player.position)
		if distanceToPlayer > 200:
			shootingTimer += delta
			if shootingTimer > shootingCooldown:
				shoot()
				shootingTimer = 0
				print("shoot")
	move_and_slide()

func shoot():
	var b = bullet_scene.instantiate()
	var direction = (player.global_position - global_position).normalized()
	b.setup(direction, $Marker2D.global_position)
	owner.add_child(b)
