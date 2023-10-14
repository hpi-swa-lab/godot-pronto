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
		var title = (get_parent().find_child("TitleInput", true) as TextEdit).text
		var description = (get_parent().find_child("DescriptionInput", true) as TextEdit).text
		var author_box = get_parent().find_child("Authors", true) as VBoxContainer
		
		var authors = ""
		for child in author_box.get_children():
			var author_name = child.get_child(1).text
			if not author_name.is_empty():
				authors += "\"" + author_name + "\", "
		if authors.is_empty():
			authors = "\"<Author>\""
		else:
			authors = authors.left(authors.length() - 2)
		
		content += "\n"
		content += "[node name=\"ExportBehavior\" type=\"Node2D\" parent=\".\"]\n"
		content += "position = Vector2(576, 324)\n"
		content += "script = ExtResource(\"1\")\n"
		
		if not title.is_empty():
			content += "title = \"" + title + "\"\n"
		
		content += "authors = PackedStringArray(" + authors + ")\n"
		
		if not description.is_empty():
			content += "description = \"" + description + "\"\n"

	scene.store_string(content)
	colored_print("Created new prototype scene!")

func stage_initial_changes(name):
	var output = []
	OS.execute("git", ["add", "."], output, true)
	colored_print(output[0])

func clicked():
	var name_input = get_parent().find_child("ProjectName", true) as TextEdit
	var export_box = get_parent().find_child("ExportOption", true) as CheckButton
	var stage_box = get_parent().find_child("StageBox", true) as CheckBox

	var name = name_input.text
	var create_export = export_box.button_pressed

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
	ProjectSettings.save()

	# Start game so a screenshot can be made.
	if create_export:
		editor_interface.play_custom_scene(scene_path)
		# wait for scene to be closed after taking screenshot
		while editor_interface.is_playing_scene():
			print("... Waiting for scene to be terminated")
			await get_tree().create_timer(0.5).timeout

	if stage_box.button_pressed:
		# Stage newly created prototype folder.
		stage_initial_changes(name)
		colored_print("Staged all initial changes!")
