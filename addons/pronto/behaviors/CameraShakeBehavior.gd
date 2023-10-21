@tool
extends Behavior
#thumb("CameraAttributes")
class_name CameraShakeBehavior

## The CameraShakeBehavior is a [class Behavior] that applies a shreen shake to the
## camera. This allows to add a rapid movement of the camera in small steps for a short amount of time
##
## The functionality was adapted from https://kidscancode.org/godot_recipes/3.x/2d/screen_shake/

## Determines how quickly the shake stops. Values must lie in [0, 1].
## [code]0[/code] means it will never stop and [code]1[/code] will stop
## it instantly.
@export var decay = 0.8

## The maximum horizontal and vertical shake in pixels
@export var max_offset = Vector2(100, 75)

## The maximum rotation in radiants
@export var max_roll = 0.1

## The current shake strength
var trauma = 0.0

var noise_y = 0.0
var noise = FastNoiseLite.new()

func _ready():
	super._ready()
	if not get_parent() is Camera2D:
		push_error("Parent has to be of type Camera2D.")
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


func _get_configuration_warnings():
	if not get_parent() is Camera2D:
		return ["Parent has to be of type Camera2D."]
	return ""
