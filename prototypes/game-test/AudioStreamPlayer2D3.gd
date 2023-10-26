extends AudioStreamPlayer2D

var is_playing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func play_if_not_playing():
	if is_playing == false:
		is_playing = true
		play(0.0)
	
func reset_play():
	is_playing = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
