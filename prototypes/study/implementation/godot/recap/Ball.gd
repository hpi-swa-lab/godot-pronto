extends CharacterBody2D
var stuck = true
var dir = Vector2.UP
@export var paddle: CharacterBody2D
@export var speed_limit = 1000
@export var speed = 500
@export var speed_up_factor = 1.05

func _physics_process(delta):
	if stuck:
		global_position.x = paddle.global_position.x
		if Input.is_key_pressed(KEY_SPACE):
			stuck = false
			velocity = Vector2(randf_range(-1,1), randf_range(-.1, -1)).normalized()
	else:
		var collision = move_and_collide(velocity * speed * delta)
		if (!collision):
			return
		velocity = velocity.bounce(collision.get_normal())
		if (collision.get_collider().name.contains("Brick")):
			collision.get_collider().queue_free()

func _on_area_bottom_body_entered(body):
	if body.name == self.name:
		call_deferred("_restart")
		
func _restart():
	get_tree().reload_current_scene()
