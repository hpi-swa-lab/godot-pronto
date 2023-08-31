@tool
extends EditorPlugin

var dock # A class member to hold the dock during the plugin lifecycle

func _enter_tree():
	add_autoload_singleton("PromptoManager", "res://addons/prompto/prompto_manager.gd")
	call_deferred('register_panel')

func _ready():
	get_pompto_manager().setup_editor_settings(get_editor_interface().get_editor_settings())

func get_pompto_manager():
	return get_node("/root/PromptoManager")

func register_panel():
	var prompto_manager = get_pompto_manager()

	# Initialization of the plugin goes here
	# First load the dock scene and instance it:
	_set_scene(prompto_manager.session_store.logged_in())
	prompto_manager.session_store.changed.connect(_set_scene)
	
# Triggerd if session state changed
func _set_scene(logged_in):
	print("Scene changed.")
	
	if dock:
		#remove_control_from_container(EditorPlugin.CONTAINER_PROJECT_SETTING_TAB_RIGHT, dock)
		remove_control_from_docks(dock)
		dock.free()
		
	if logged_in:
		dock = preload("res://addons/prompto/chat/chat.tscn").instantiate() 
	else:
		dock = preload("res://addons/prompto/login.tscn").instantiate()
	
	add_control_to_dock(DOCK_SLOT_RIGHT_UR, dock)
	
func _exit_tree():
	# Clean-up of the plugin goes here
	# Remove the scene from the docks:
	await remove_autoload_singleton("PromptoManager")
	if dock:
		remove_control_from_docks(dock) # Remove the dock
		dock.free() # Erase the control from the memory
