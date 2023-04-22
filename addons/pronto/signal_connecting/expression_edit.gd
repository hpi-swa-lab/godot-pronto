@tool
extends HBoxContainer

@export var argument_names: Array = []
@export var return_value: bool = true

var text: String:
	get:
		return $Expression.text
	set(v):
		$Expression.text = v

func _ready():
	$OpenFile.icon = Utils.icon_from_theme("DebugSkipBreakpointsOff", self)

func open_file():
	var script = ConnectionsList.script_for_eval($Expression.text, argument_names, return_value)
	var interface = G.at("_pronto_editor_plugin").get_editor_interface()
	interface.edit_script(script)
	interface.set_main_screen_editor("Script")

func grab_focus():
	$Expression.grab_focus()
