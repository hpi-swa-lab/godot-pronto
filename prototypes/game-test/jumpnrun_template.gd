extends Node2D

var pressed = false

var key_map = {
	"function": Input.is_physical_key_pressed,
	"reset": KEY_SPACE
}

func _ready():
	pass

func restart_game():
	get_tree().reload_current_scene()
	
func _is_key_pressed(direction):
	var keys = key_map
	if (typeof(keys[direction]) == TYPE_ARRAY):
		return keys[direction].any(func(key): return keys["function"].call(key))
	else:
		return keys["function"].call(keys[direction])
		
		
func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	if _is_key_pressed("reset"):
		pressed = true
	else:
		if pressed == true:
			get_tree().reload_current_scene()
			pressed = false


func _on_clock_behavior_trap_trigger_elapsed():
	$Player/PointLight2D.set_enabled(true)
	$Player/PlatformerControllerBehavior.set_movement_enabled(true)	


func _on_audio_stream_player_trap_trigger_finished():
	$Player/PointLight2D.set_enabled(false)
	$"../SpikeRun".blackScreen_on()
	$"../SpikeRun".enable_camera()
	$Player/CameraPlayer.set_enabled(false)


func _on_trap_trigger_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	print("Area Entered")
	$Player/PlatformerControllerBehavior.set_movement_enabled(false)
	$"../TrapTrigger".queue_free()


func _on_health_bar_behavior_death():
	$"../SpikeRun"._on_health_bar_behavior_death()
	pass # Replace with function body.
