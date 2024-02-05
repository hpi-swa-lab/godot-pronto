extends Node

@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry
@onready var hud = $CanvasLayer/HUD
@onready var health_bar = $CanvasLayer/HUD/HealthBar

const Player = preload("res://prototypes/game-burghardt-goergens-ragerumble-minigames/Shooter/player.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		enet_peer.close()
		get_tree().change_scene_to_file("res://prototypes/game-burghardt-goergens-ragerumble-minigames/game-burghardt-goergens-ragerumble-minigames.tscn")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_host_button_pressed():
	main_menu.hide()
	hud.show()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())

func _on_join_button_pressed():
	main_menu.hide()
	hud.show()
	
	var address = address_entry.text
	if address_entry.text == "":
		address = "localhost"
		
	enet_peer.create_client(address, PORT)
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	
	add_child(player)
	if player.is_multiplayer_authority():
		player.health_changed.connect(update_health_bar)
		player.amp_changes.connect(set_amp_label)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func update_health_bar(health_value):
	health_bar.value = health_value

func set_amp_label(amp):
	$CanvasLayer/HUD/Recordinglabel.set_text(amp)

func _on_multiplayer_spawner_spawned(node):
	if node.is_multiplayer_authority():
		node.health_changed.connect(update_health_bar)
		node.amp_changes.connect(set_amp_label)
