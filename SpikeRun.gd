extends Node2D

var spikes_enabled: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$SpikeWallMap.material.set_light_mode(2)
	$TileMap.material.set_light_mode(2)
	$Torches/TileMap2.material.set_light_mode(2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if spikes_enabled:
		move_spikes()
	
func set_spikes_enabled(boolean: bool):
	spikes_enabled = boolean

func move_spikes():
	$SpikeWallMap/MoveBehavior.move_right_a_bit()
	
func enable_camera():
	$SpikeWallMap/Camera2D.set_enabled(true)
	
func disable_camera():
	$SpikeWallMap/Camera2D.set_enabled(false)

func blackScreen_on():
	$SpikeWallMap/Camera2D.turn_camera_black()

func _on_clock_behavior_trap_trigger_elapsed():
	set_spikes_enabled(true)
	$SpikeWallMap.set_visible(true)
	$SpikeWallMap/AudioStreamPlayer2DSpikes.play()
	$Torches/TileMap2.turn_on_lights()
	$SpikeWallMap/Camera2D.restore_camera_view()
