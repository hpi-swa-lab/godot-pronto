extends CharacterBody2D


@export var speed = 300.0
@export var health = 10
@export var player_bullet_scene: PackedScene
var max_health
var last_spawn = 0
var bullet_cooldown: float = 1
var cd_powerup_timer = Timer.new()
var cd_powerup_active = false

func _ready():
	cd_powerup_timer.one_shot = true
	cd_powerup_timer.timeout.connect(func(): cd_powerup_active = false)
	add_child(cd_powerup_timer)
	max_health = health
	_update_health_display()
	
	
func _process(delta):
	if Input.is_action_just_pressed("input_left_mouse"):
		if Time.get_ticks_msec() > last_spawn + (bullet_cooldown*1000) or cd_powerup_active:
			_spawn_bullet()
			last_spawn = Time.get_ticks_msec()

func _spawn_bullet():
	var bullet = player_bullet_scene.instantiate()
	bullet.position = position
	var direction = get_viewport().get_mouse_position() - position
	bullet.direction = direction
	bullet.rotation = position.angle_to_point(get_viewport().get_mouse_position())
	get_parent().add_child(bullet)

func _physics_process(delta):

	var direction := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	if direction.length() > 1.0:
		direction = direction.normalized()
	velocity = direction * speed
	if move_and_slide():
		_handle_collision()

func _handle_collision():
	var collision = get_last_slide_collision()
	if collision.get_collider() is CharacterBody2D:
		var other = collision.get_collider()
		damage(other.health)
		other.queue_free()

func _update_health_display():
	%PlayerHealthDisplay.text = str(health) + "/" + str(max_health)

func damage(amount: int):
	if health > amount:
		health = health - amount
		_update_health_display()
	else:
		%PlayerHealthDisplay.text = "You lost"
		get_child(0).queue_free()
		print("You have been eliminated")
		get_tree().paused = true

func heal(amount):
	if health + amount > max_health:
		health = max_health
	else:
		health = health + amount
	_update_health_display()

func activate_cooldown_powerup(duration):
	cd_powerup_timer.start(duration)
	cd_powerup_active = true
