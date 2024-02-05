extends CharacterBody2D

signal health_changed(health_value)
signal amp_changes(amp)
var health = 3
@onready var camera = $CameraPlayer
var stereo := true
var effect  # See AudioEffect in docs
var recording  # See AudioStreamSample in docs
var mix_rate := 44100  # This is the default mix rate on recordings
var format := 1  # This equals to the default format: 16 bits
@export var SPEED = 250.0
const JUMP_VELOCITY = 400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 800.0

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	print("here3")
	
func _ready():
	if not is_multiplayer_authority():
		print("lol")
		return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.make_current()
	print("here")
	var idx = AudioServer.get_bus_index("Record")
	AudioServer.add_bus_effect(idx, AudioEffectRecord.new(), 0)
	effect = AudioServer.get_bus_effect(idx, 0)
	while true:
		_on_RecordButton_pressed()
		await get_tree().create_timer(0.1).timeout
		_on_RecordButton_pressed()
		_on_PlayButton_pressed()

@rpc("any_peer")
func receive_damage():
	health -= 1
	if health <= 0:
		health = 3
		reset_player()
	health_changed.emit(health)

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
	var data = recording.get_data()
	const max_amplitude = 12000.0
	var amplitude = 0.0
	# Iterate through each pair of bytes in the PackedByteArray
	for i in range(0, data.size(), 2):
	# Combine two bytes to create one 16-bit sample
		var sample = data[i] | (data[i+1] << 8)
	
	# Convert to signed 16-bit integer if necessary
		if sample >= 32768:
			sample -= 65536
	
	# Calculate absolute value for amplitude
		amplitude = abs(sample)
		if amplitude <= 200.0:
			amplitude = 0.0
	#var amplitude_percentage = roundi(100.0*max_amplitude/(32768 - threshold))
	var amplitude_percentage = roundi(100.0* (amplitude / max_amplitude))
	amp_changes.emit("Amp: " + str(amplitude_percentage) +"%")
	SPEED = 250.0 + 250.0 * (amplitude / max_amplitude)

func reset_player():
	position = Vector2(128.0, 512.0)

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = -JUMP_VELOCITY
		
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		reset_player()
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.origin * Vector2(input_dir.x, 0)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
