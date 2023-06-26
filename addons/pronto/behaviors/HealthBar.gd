@tool
#thumb("Heart")
extends Behavior
class_name HealthBar

signal changed(health)
signal death()

@export var current: int = 100:
	set(v):
		current = max(0, min(v, max))
		queue_redraw()
		changed.emit(current)
		if current == 0: death.emit()

@export var max: int = 100:
	set(v):
		max = v
		current = max
		queue_redraw()

@export var healthbar_size = Vector2(50, 5):
	set(v):
		healthbar_size = v
		queue_redraw()
		
enum LABEL { None, Health, Fraction, Percentage }
@export var label: LABEL = LABEL.Health:
	set(v):
		label = v
		queue_redraw()

@export_category("Color")

@export var background_color = Color("#39393971"):
	set(v):
		background_color = v
		queue_redraw()
		
@export var text_color = Color.WHITE:
	set(v):
		text_color = v
		queue_redraw()

# the progress_colors are evenly distributed in the order they are defined over the health range
@export var progress_colors: PackedColorArray = [
	Color.RED, Color.RED, Color.YELLOW, Color.YELLOW, Color.YELLOW, 
	Color.LIME_GREEN,  Color.LIME_GREEN,  Color.LIME_GREEN,  Color.LIME_GREEN,  
	Color.LIME_GREEN
]:
	set(v):
		progress_colors = v
		queue_redraw()

var size: Vector2:
	get:
		return healthbar_size
	
func damage(amount):
	set_health(current - amount)
	
func heal(amount):
	set_health(current + amount)

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
	var color_index  = max(0, min(progress_colors.size() * (current/float(max)), progress_colors.size()-1))
	return progress_colors[color_index]

func _draw():
	super._draw()
	
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
