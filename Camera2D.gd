extends Camera2D

@onready var black_overlay = $"../../Black"

func _ready():
	set_limit_drawing_enabled(true)
	black_overlay.custom_minimum_size = get_viewport_rect().size
	black_overlay.set_visible(false)

# Call this method to turn the camera view black
func turn_camera_black():
	black_overlay.set_visible(true)

# Call this method to restore the camera view
func restore_camera_view():
	black_overlay.set_visible(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func increase_zoom(value = 0.1):
	zoom += zoom * value
	position += Vector2(-60.0, 60.0)
