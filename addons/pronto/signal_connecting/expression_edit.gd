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
		resize()

@export var min_width = 80
@export var max_width = 260

func _ready():
	fake_a_godot_highlighter()

func fake_a_godot_highlighter():
	var s = G.at("_pronto_editor_plugin").get_editor_interface().get_editor_settings()
	var h = CodeHighlighter.new()
	h.number_color = s.get("text_editor/theme/highlighting/number_color")
	h.symbol_color = s.get("text_editor/theme/highlighting/symbol_color")
	h.function_color = s.get("text_editor/theme/highlighting/function_color")
	h.member_variable_color = s.get("text_editor/theme/highlighting/member_variable_color")
	
	var control_flow_keyword_color = s.get("text_editor/theme/highlighting/keyword_color")
	var keyword_color = s.get("text_editor/theme/highlighting/keyword_color")
	h.keyword_colors = {
		"break": control_flow_keyword_color,
		"continue": control_flow_keyword_color,
		"elif": control_flow_keyword_color,
		"else": control_flow_keyword_color,
		"if": control_flow_keyword_color,
		"for": control_flow_keyword_color,
		"match": control_flow_keyword_color,
		"pass": control_flow_keyword_color,
		"return": control_flow_keyword_color,
		"while": control_flow_keyword_color,
		# operators
		"and": keyword_color,
		"in": keyword_color,
		"not": keyword_color,
		"or": keyword_color,
		# types and values
		"false": keyword_color,
		"float": keyword_color,
		"int": keyword_color,
		"bool": keyword_color,
		"null": keyword_color,
		"PI": keyword_color,
		"TAU": keyword_color,
		"INF": keyword_color,
		"NAN": keyword_color,
		"self": keyword_color,
		"true": keyword_color,
		"void": keyword_color,
		# functions
		"as": keyword_color,
		"assert": keyword_color,
		"await": keyword_color,
		"breakpoint": keyword_color,
		"class": keyword_color,
		"class_name": keyword_color,
		"extends": keyword_color,
		"is": keyword_color,
		"func": keyword_color,
		"preload": keyword_color,
		"signal": keyword_color,
		"super": keyword_color,
		# var
		"const": keyword_color,
		"enum": keyword_color,
		"static": keyword_color,
		"var": keyword_color,
	}
	$Expression.syntax_highlighter = h

func get_a_godot_highlighter():
	# NOTE: causes crashes when saving scenes in the current form. Potentially because
	# we are sharing the instance between multiple editors  (which is not technically allowed)
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

func extra_width():
	return 100

func _on_expression_text_changed():
	if self != owner:
		resize()
	
	text_changed.emit()

func resize():
	var size = get_theme_default_font().get_multiline_string_size(text)
	custom_minimum_size = Vector2(clamp(size.x, min_width, max_width) + extra_width(), clamp(size.y, 32, 32 * 4))
	Utils.fix_minimum_size(self)
	reset_size()
