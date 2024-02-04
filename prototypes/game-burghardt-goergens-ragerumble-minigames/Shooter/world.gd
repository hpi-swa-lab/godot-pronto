extends Node

@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry
@onready var hud = $CanvasLayer/HUD
@onready var health_bar = $CanvasLayer/HUD/HealthBar
var stereo := true
var effect  # See AudioEffect in docs
var recording  # See AudioStreamSample in docs
var mix_rate := 44100  # This is the default mix rate on recordings
var format := 1  # This equals to the default format: 16 bits

const Player = preload("res://prototypes/game-burghardt-goergens-ragerumble-minigames/Shooter/player.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().change_scene_to_file("res://prototypes/game-burghardt-goergens-ragerumble-minigames/game-burghardt-goergens-ragerumble-minigames.tscn")

func _on_host_button_pressed():
	main_menu.hide()
	hud.show()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())
	var idx = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(idx, 0)
	
	#upnp_setup()
	while true:
		_on_RecordButton_pressed()
		await get_tree().create_timer(0.1).timeout
		_on_RecordButton_pressed()
		_on_PlayButton_pressed()

func _on_join_button_pressed():
	main_menu.hide()
	hud.show()
	
	enet_peer.create_client(address_entry.text, PORT)
	multiplayer.multiplayer_peer = enet_peer
	while true:
		_on_RecordButton_pressed()
		await get_tree().create_timer(0.1).timeout
		_on_RecordButton_pressed()
		_on_PlayButton_pressed()

func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
	if player.is_multiplayer_authority():
		player.health_changed.connect(update_health_bar)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func update_health_bar(health_value):
	health_bar.value = health_value

func _on_multiplayer_spawner_spawned(node):
	if node.is_multiplayer_authority():
		node.health_changed.connect(update_health_bar)

func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
	
	print("Success! Join Address: %s" % upnp.query_external_address())


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
	var playerlabel = $CanvasLayer/HUD/Recordinglabel
	var playerchar = get_tree().get_nodes_in_group("player")[0]
	#if playerlabel == null:
#		return
	playerlabel.setText("Amp: " + str(amplitude_percentage) +"%")
	playerchar.SPEED = 10.0 + 10.0 * (max_amplitude / threshold)
