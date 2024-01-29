extends Area2D
var speed = 501
var dir
var muzzle

# Called when the node enters the scene tree for the first time.
func _ready():
	self.global_position = muzzle
	global_rotation = dir.angle()

func setup(direction, muzzlePos):
	dir = direction
	muzzle = muzzlePos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += dir * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.queue_free()
	if !body.is_in_group("enemy"):
		queue_free()
