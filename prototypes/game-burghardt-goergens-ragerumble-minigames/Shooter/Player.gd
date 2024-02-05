extends CharacterBody3D

signal health_changed(health_value)
signal amp_changes(amp)
signal kills_changed(kills_value)

@onready var camera = $Camera3D
@onready var anim_player = $AnimationPlayer
@onready var muzzle_flash = $Camera3D/Pistol/MuzzleFlash
@onready var raycast = $Camera3D/RayCast3D
var stereo := true
var effect  # See AudioEffect in docs
var recording  # See AudioStreamSample in docs
var mix_rate := 44100  # This is the default mix rate on recordings
var format := 1  # This equals to the default format: 16 bits
var health = 3
var kills = 0

@export var SPEED = 10.0
const JUMP_VELOCITY = 10.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 20.0

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority(): return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	print("here")
	var idx = AudioServer.get_bus_index("Record")
	AudioServer.add_bus_effect(idx, AudioEffectRecord.new(), 0)
	effect = AudioServer.get_bus_effect(idx, 0)
	while true:
		_on_RecordButton_pressed()
		await get_tree().create_timer(0.1).timeout
		_on_RecordButton_pressed()
		_on_PlayButton_pressed()

func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	if Input.is_action_just_pressed("shoot") \
			and anim_player.current_animation != "shoot":
		play_shoot_effects.rpc()
		if raycast.is_colliding():
			var hit_player = raycast.get_collider()
			hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if anim_player.current_animation == "shoot":
		pass
	elif input_dir != Vector2.ZERO and is_on_floor():
		anim_player.play("move")
	else:
		anim_player.play("idle")

	move_and_slide()

@rpc("call_local")
func play_shoot_effects():
	anim_player.stop()
	anim_player.play("shoot")
	muzzle_flash.restart()
	muzzle_flash.emitting = true

@rpc("any_peer")
func receive_damage():
	health -= 1
	if health <= 0:
		var sender = multiplayer.get_remote_sender_id()
		var enemy = get_parent().get_node_or_null(str(sender))
		enemy.set_kills.rpc_id(sender)
		health = 3
		position = Vector3.ZERO
	health_changed.emit(health)

@rpc("any_peer")
func set_kills():
	kills += 1
	kills_changed.emit("Kills: " + str(kills))

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "shoot":
		anim_player.play("idle")


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

	# Update max_amplitude if this sample's amplitude is greater
		if amplitude > max_amplitude:
			max_amplitude = amplitude
	var amplitude_percentage = roundi(100.0*max_amplitude/(32768 - threshold))
	amp_changes.emit("Amp: " + str(amplitude_percentage) +"%")
	SPEED = 10.0 + 10.0 * (max_amplitude / threshold)
