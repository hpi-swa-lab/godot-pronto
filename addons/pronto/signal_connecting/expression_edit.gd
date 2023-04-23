@tool
extends HBoxContainer

signal text_changed()

@export var argument_names: Array = []
@export var return_value: bool = true
@export var placeholder_text: String:
	get: return $Expression.placeholder_text
	set(v):
		# https://github.com/godotengine/godot-proposals/issues/325#issuecomment-845668412
		if not is_inside_tree(): await ready
		$Expression.placeholder_text = v
@export var text: String:
	get: return $Expression.text
	set(v):
		# https://github.com/godotengine/godot-proposals/issues/325#issuecomment-845668412
		if not is_inside_tree(): await ready
		$Expression.text = v

func _ready():
	$OpenFile.icon = Utils.icon_from_theme("DebugSkipBreakpointsOff", self)
	get_a_godot_highlighter()

func get_a_godot_highlighter():
	# GDScriptHighlighter is a private cpp class. We can obtain an instance however.
	var se = G.at("_pronto_editor_plugin").get_editor_interface().get_script_editor()
	if not se.get_open_script_editors().is_empty():
		var s = se.get_open_script_editors()[0].get_base_editor().syntax_highlighter
		$Expression.syntax_highlighter = s

func open_file():
	var script = ConnectionsList.script_for_eval($Expression.text, argument_names, return_value)
	var interface = G.at("_pronto_editor_plugin").get_editor_interface()
	interface.edit_script(script)
	interface.set_main_screen_editor("Script")

func grab_focus():
	$Expression.grab_focus()

func _on_expression_text_changed():
	text_changed.emit()
