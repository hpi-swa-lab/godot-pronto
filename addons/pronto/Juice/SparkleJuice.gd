@tool
#thumb("Timer")
extends Behavior
class_name SparkleJuice

## If true, particles are being emitted
@export var emitting = true:
	set(v):
		emitting = v
		_particles.set_emitting(v)

## Size of the rectangle in which the sparkles are spawned
@export var spawn_extent = Vector2(20,20):
	set(v):
		var sparkles_per_unit = sparkle_count/ (_particles.emission_rect_extents.x * _particles.emission_rect_extents.y)
		sparkle_count = max(min(sparkles_per_unit * v.x * v.y, 100),0)
		spawn_extent = v
		_particles.emission_rect_extents = spawn_extent

## Number of particles emitted in one emission cycle. In other words: the maximum amount of simultaniously rendered Sparkles
@export_range(1,100) var sparkle_count = 6:
	set(v):
		sparkle_count = v
		_particles.amount = v

## How rapidly particles in an emission cycle are emitted. If greater than 0, there will be a gap in emissions before the next cycle begins.
@export_range(0,1, 0.1) var sparkle_explosivness = 0.7:
	set(v):
		sparkle_explosivness = v
		_particles.explosiveness = v

## Controls the size of the sparkles
@export_range(0,20, 0.5) var sparkle_scale = 1.0:
	set(v):
		sparkle_scale = v
		_particles.scale_amount_min = v
		_particles.scale_amount_max = v * 5

@export var sparkle_texture = load("res://images/shine.png"):
	set(v):
		sparkle_texture = v
		_particles.texture = v

## Main sparkle color
@export var sparkle_color = Color("ffff4c"):
	set(v):
		_particles.color_ramp.set_color(1,v)
		_particles.color_ramp.set_color(2,v)
		sparkle_color = v

## Highlight sparkle color
@export var sparkle_highlight_color = Color("ffffff"):
	set(v):
		_particles.color_ramp.set_color(0,v)
		_particles.color_ramp.set_color(3,v)
		sparkle_highlight_color = v


var _particles: CPUParticles2D:
	get:
		if not _particles:
			_particles = preload("res://addons/pronto/Juice/sparkle.tscn").instantiate()
			add_child(_particles)
		return _particles

func _process(delta):
	super._process(delta)
	if spawn_extent != _particles.emission_rect_extents:
		_particles.emission_rect_extents = spawn_extent


func _ready():
	_particles.color_ramp = _particles.color_ramp.duplicate()
	_particles.texture = _particles.texture.duplicate()
	_particles.scale_amount_curve = _particles.scale_amount_curve.duplicate()

func handles():
	return [
		Handles.SetPropHandle.new(
			(transform * spawn_extent - position),
			Utils.icon_from_theme("EditorHandle", self),
			self,
			"spawn_extent",
			func (coord): return (floor(coord) * transform.translated(-position)).clamp(Vector2(1, 1), Vector2(10000, 10000)))
	]
