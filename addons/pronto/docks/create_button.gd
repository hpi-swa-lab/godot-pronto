@tool
extends Button

func _enter_tree():
	pressed.connect(clicked)
	
func colored_print(msg, color="green"):
	print_rich("[color=" + color + "]", msg)
	
func create_new_branch(name):
	# Fetch origin master.
	var fetch_output = []
	OS.execute("git", ["fetch", "origin", "master"], fetch_output, true)
	colored_print(fetch_output[0])
	
	# Create new branch from origin/master.
	var branch_output = []
	OS.execute("git", ["checkout", "-b", name, "origin/master"], branch_output, true)
	colored_print(branch_output[0])
	
	# Create prototype folder.
	var dir = DirAccess.open("res://prototypes")
	dir.make_dir(name)

func create_scene(name, create_export):
	var scene = FileAccess.open("res://prototypes/" + name + "/" + name + ".tscn", FileAccess.WRITE)
	var uid = ResourceUID.create_id()
	var content = "[gd_scene " + ("load_steps=2 " if create_export else "") \
	 + "format=3 " + "uid=\"uid://" + str(uid) + "\"]\n\n"
	
	if create_export:
		content += "[ext_resource type=\"Script\" path=\"res://addons/pronto/behaviors/ExportBehavior.gd\" id=\"1\"]\n\n"
	
	content += "[node name=\"Node2D\" type=\"Node2D\"]\n"
	
	if create_export:
		content += "\n"
		content += "[node name=\"ExportBehavior\" type=\"Node2D\" parent=\".\"]\n"
		content += "position = Vector2(576, 324)\n"
		content += "script = ExtResource(\"1\")\n"
		content += "authors = PackedStringArray(\"<Author>\")\n"
	
	scene.store_string(content)
	colored_print("Created new prototype scene!")

func stage_initial_changes(name):
	var output = []
	OS.execute("git", ["add", "prototypes/" + name], output, true)
	colored_print(output[0])

func clicked():
	var name_input = get_parent().find_child("Name", true) as TextEdit
	var check_box = get_parent().find_child("CheckBox", true) as CheckBox

	var name = name_input.text
	var create_export = check_box.button_pressed

	if name.is_empty():
		push_warning("Please chose a name for your prototype!")
		return

	var dir = DirAccess.open("res://prototypes")
	if dir.dir_exists(name):
		push_warning("A prototype with the same name already exists!")
		return

	create_new_branch(name)
	create_scene(name, create_export)

	# Open the newly created scene in editor.
	var editor_interface = G.at("_pronto_editor_plugin").get_editor_interface() as EditorInterface
	var scene_path = "res://prototypes/" + name + "/" + name + ".tscn"
	editor_interface.open_scene_from_path(scene_path)

	# Set scene as main scene
	ProjectSettings.set_setting("application/run/main_scene", scene_path)
	
	# Start game so a screenshot can be made.
	if create_export:
		editor_interface.play_custom_scene(scene_path)
		OS.delay_msec(1500) # wait for screenshot to be completed
	# Stage newly created prototype folder.
	stage_initial_changes(name)

