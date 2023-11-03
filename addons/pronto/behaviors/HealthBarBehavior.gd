@tool
#thumb("Heart")
extends Behavior
class_name HealthBarBehavior

## The HealthBarBehavior is a [class Behavior] that
## adds a health system to characters/objects. 
##
## It communicates the current live and the death via the signals
## [signal HealthBehavior.changed] and [signal HealthBehavior.death].

## Emitted when the health value is changed.
signal changed(health)

## Emitted when the health value drops to zero or below.
signal death()

## The maximum health value.
@export var max: int = 100:
	set(v):
		max = v
		if Engine.is_editor_hint() and is_active_scene():
			# If in editor scene set current to max when changed.
			current = max
		queue_redraw()

## The current health value (cannot exceed max).
@export var current: int = 100:
	set(v):
		current = max(0, min(v, max))
		queue_redraw()
		changed.emit(current)
		if current == 0: death.emit()

## The size of the displayed healthbar.
@export var healthbar_size = Vector2(50, 5):
	set(v):
		healthbar_size = v
		queue_redraw()

## This enum defines how the label is supposed to be displayed.
enum LABEL {
	None,       ## No label is shown.
	Health,     ## label shown as '{current}'.
	Fraction,   ## label show as '{current}/{max}'.
	Percentage, ## label shown as '{100*current/max} %'.
}

## The style for displaying the current health as text inside the healthbar.
@export var label: LABEL = LABEL.Health:
	set(v):
		label = v
		queue_redraw()

## Color options for the healthbar.
@export_category("Color")

## The background color of the healthbar.
@export var background_color = Color("#40404080"):
	set(v):
		background_color = v
		queue_redraw()

## The text color of the healthbar.	
@export var text_color = Color.WHITE:
	set(v):
		text_color = v
		queue_redraw()

# We use this as the default since we need to configure it in _init()
var _default_progress_gradient = Gradient.new()

## The progress_gradient is used for coloring the HealthBar according to the current health.
## The current color is chosen according to the value of [code]current/max[/code].
@export var progress_gradient: Gradient = _default_progress_gradient.duplicate():
	set(gradient):
		# On reset, gradient will be null, in which case we want to duplicte the default gradient
		if (gradient != null):
			progress_gradient = gradient
		else:
			progress_gradient = _default_progress_gradient.duplicate()
		progress_gradient.changed.connect(queue_redraw)
		queue_redraw()

@export_category("Invulnerability")

## If invulnerable the player cannot take damage via the [code]damage()[/code] method. [br]
## However, [code]set_health()[/code] will still work!
@export var invulnerable = false:
	set(v):
		invulnerable = v
		queue_redraw()

## If [i]false[/i], the player will not heal with [code]heal()[/code] or [code]heal_full()[/code] when invulnerable. [br]
## If [i]true[/i], the player will heal as usual even when he is invulnerable.
@export var allow_healing_when_invulnerable = false


@export var invulnerability_color = Color.GOLDENROD:
	set(color):
		invulnerability_color = color
		queue_redraw()

## The height and width of the health bar
var size: Vector2:
	get:
		return healthbar_size

func _init():
	# Setup the default gradient for usage
	_default_progress_gradient.set_colors([])
	_default_progress_gradient.add_point(0, Color.RED)
	_default_progress_gradient.add_point(0.5, Color.YELLOW)
	_default_progress_gradient.add_point(1, Color.LIME_GREEN)
	progress_gradient = _default_progress_gradient.duplicate()


## Reduces the current health value by the given [code]amount[/code].
func damage(amount):
	if (invulnerable): return
	var shake_amount = 10.0
	var camera = get_parent().get_node("Camera2D")
	camera.set_offset(Vector2(randf_range(-1.0,1.0) * shake_amount, randf_range(-1.0, 1.0) * shake_amount))
	
	set_health(current - amount)

## Increases the current health value by the given [code]amount[/code].
func heal(amount):
	if (invulnerable and not allow_healing_when_invulnerable): return
	set_health(current + amount)

## Sets the current health value to max.
func heal_full():
	if (invulnerable and not allow_healing_when_invulnerable): return
	set_health(max)

## Sets the current health value to the given [code]value[/code].
func set_health(value):
	current = value

func show_icon():
	return false
	
func _get_text():
	match label:
		LABEL.None:
			return ""
		LABEL.Health:
			return str(current)
		LABEL.Fraction:
			return str(current) + "/" + str(max)
		LABEL.Percentage:
			return str(100*current/max) + " %"
			
func _get_color():
	return progress_gradient.sample(float(current)/max)

func _draw():
	super._draw()
	
	if (invulnerable):
		draw_rect(Rect2((healthbar_size + Vector2(1, 1)) / -2, healthbar_size + Vector2(1, 1)), invulnerability_color, false, 0.5)
	draw_rect(Rect2(healthbar_size / -2, healthbar_size), background_color, true)
	var inner_size = healthbar_size - Vector2(2, 2)
	draw_rect(Rect2(inner_size / -2, inner_size * Vector2(current/float(max), 1)), _get_color(), true)
	
	# draw health as text
	var label = _get_text()
	var font = ThemeDB.fallback_font
	var height = inner_size.y
	var text_height = min(height, healthbar_size.x / label.length() * 1.8)
	var text_width = font.get_multiline_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, text_height)
	draw_string(font, Vector2(-text_width.x/2, text_height/2.5),
			label,
			HORIZONTAL_ALIGNMENT_LEFT, -1, text_height, text_color);

func handles():
	return [
		Handles.SetPropHandle.new(
			(transform * healthbar_size - position) / 2,
			Utils.icon_from_theme("EditorHandle", self),
			self,
			"healthbar_size",
			func (coord): return (floor(coord * 2) * transform.translated(-position)).clamp(Vector2(1, 1), Vector2(10000, 10000)))
	]
