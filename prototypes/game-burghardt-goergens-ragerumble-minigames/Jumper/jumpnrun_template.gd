extends Node2D

var pressed = false
var stereo := true
var effect  # See AudioEffect in docs
var recording  # See AudioStreamSample in docs
var mix_rate := 44100  # This is the default mix rate on recordings
var format := 1  # This equals to the default format: 16 bits
var key_map = {
	"function": Input.is_physical_key_pressed,
	"reset": KEY_SPACE
}

func _ready():
	$TileMap.material.set_light_mode(2)
	$TileMap2.material.set_light_mode(2)
	var idx = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(idx, 0)
	while true:
		_on_RecordButton_pressed()
		await get_tree().create_timer(0.1).timeout
		_on_RecordButton_pressed()
		_on_PlayButton_pressed()

func _on_RecordButton_pressed():
	if effect.is_recording_active():
		recording = effect.get_recording()
		effect.set_recording_active(false)
		recording.set_mix_rate(mix_rate)
		recording.set_format(format)
		recording.set_stereo(stereo)
	else:
		effect.set_recording_active(true)

func _on_PlayButton_pressed():
	var max_amplitude = 0
	var data = recording.get_data()
	const threshold = 5000
	# Iterate through each pair of bytes in the PackedByteArray
	for i in range(0, data.size(), 2):
	# Combine two bytes to create one 16-bit sample
		var sample = data[i] | (data[i+1] << 8)
	
	# Convert to signed 16-bit integer if necessary
		if sample >= 32768:
			sample -= 65536
	
	# Calculate absolute value for amplitude
		var amplitude = abs(sample)
		amplitude = max(0, amplitude - threshold)
		#if amplitude <= 200:
		#	amplitude = 0

	# Update max_amplitude if this sample's amplitude is greater
		if amplitude > max_amplitude:
			max_amplitude = amplitude
	var amplitude_percentage = roundi(100.0*max_amplitude/(32768 - threshold))
	var player = $Player/Recordinglabel
	if player == null:
		return
	player.setText("Amp: " + str(amplitude_percentage) +"%")
	$Player/PlatformerControllerBehavior.update_horizontal_velocity(250 + 250 * (max_amplitude / threshold))

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
			#get_tree().reload_current_scene()
			pressed = false
