extends PanelContainer


@export var cam: Camera2D
var offset = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	offset = cam.global_position - global_position 
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	global_position = cam.global_position - offset
