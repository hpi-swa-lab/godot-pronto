@tool
extends Behavior
#thumb("CameraAttributes")
class_name CameraShake

# Adapted from https://kidscancode.org/godot_recipes/3.x/2d/screen_shake/

@export var decay = 0.8
@export var max_offset = Vector2(100, 75)
@export var max_roll = 0.1

var trauma = 0.0
var noise_y = 0.0
var noise = FastNoiseLite.new()

func _ready():
	if not Engine.is_editor_hint():
		noise.frequency = 0.3
		noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
		get_parent().ignore_rotation = false

func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)

func _process(delta):
	if trauma:
		var amount = pow(trauma, 2)
		noise_y += 1
		# FIXME rotation seems somehow off -- maybe the range of the noise is not quite centered?
		get_parent().rotation = max_roll * amount * n(1)
		get_parent().offset = max_offset * amount * Vector2(n(2), n(3))
		trauma = max(trauma - decay * delta, 0)

func n(factor: float):
	return noise.get_noise_2d(noise.seed * factor, noise_y)
