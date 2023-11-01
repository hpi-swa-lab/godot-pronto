extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var exited = true

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

	move_and_slide()
	
func _ready():
	var enemy_x = randf_range(100, 1200) #all values are 100 away from boundary
	var enemy_y = randf_range(100, 500)
	set_global_position(Vector2(enemy_x, enemy_y))	


func _on_flicker_area_body_entered(body):
	#var flashlight = get_parent().get_node("jumpnrun_template/Player/Flashlight")
	#print(flashlight.energy)
	#var j = 1
	#for i in range (10, 4, -1):
		#print("probiere", j)
		#flashlight.energy = j
		#print("energy:" , flashlight.energy)
		#j -= 0.1
	#for i in range (10, 4, -1):
		#print("probiere", j)
		#flashlight.energy = j
		#print("energy:" , flashlight.energy)
		#j += 0.1
		get_parent().get_node("FlickerTimer").start(0.5)

func _on_flicker_area_body_exited(body):
	get_parent().get_node("FlickerTimer").stop()
	get_parent().get_node("jumpnrun_template/Player/Flashlight").energy = 1


func _on_flicker_timer_timeout():
	var flashlight = get_parent().get_node("jumpnrun_template/Player/Flashlight")
	var rand_amt := (randf())
	print(rand_amt)
	flashlight.energy = rand_amt
# Very flashy
#	if rand_amt < 0.50:
#		light.energy = 1
## More calm, but still flashy
	if rand_amt < 0.50:
		flashlight.energy = 1
	elif rand_amt > 0.75:
		flashlight.energy = 0.75
#	timer.start(rand_amt/rand_range(1,20))
	get_parent().get_node("FlickerTimer").start(rand_amt/20)
