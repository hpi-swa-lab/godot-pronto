extends Area2D

var direction: Vector2
@export var speed = 400

func _ready():
	self.body_entered.connect(_handle_collision)
	%ExitNotifier.screen_exited.connect(_handle_exit_screen)
	
func _physics_process(delta):
	if direction:
		position = position + (direction.normalized() * speed * delta)
	
func _handle_collision(other):
	if not other.name.contains("Player"):
		other.queue_free()
		self.queue_free()

func _handle_exit_screen():
	self.queue_free()
