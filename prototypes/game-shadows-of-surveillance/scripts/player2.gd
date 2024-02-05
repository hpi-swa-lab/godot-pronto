extends CharacterBody2D

const bullet_scene = preload("res://prototypes/game-shadows-of-surveillance/characters/bullet.tscn")
const SPEED = 200.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		

	# Get tehe input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
  
	if Input.is_action_just_pressed("shoot"): 
		shoot()
		
func die():
	queue_free()
	
func shoot():
	var b = bullet_scene.instantiate()
	var direction = (get_global_mouse_position() - global_position).normalized()
	b.setup(direction, $Marker2D.global_position)
	owner.add_child(b)
