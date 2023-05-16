@tool
extends VBoxContainer

signal text_changed()
signal blur()

@export var return_value = true
@export var argument_names: Array = []:
	set(v):
		if edit_script != null and "argument_names" in edit_script:
			edit_script.argument_names = v
		argument_names = v
@export var placeholder_text: String:
	get: return %Expression.placeholder_text
	set(v):
		# https://github.com/godotengine/godot-proposals/issues/325#issuecomment-845668412
		if not is_inside_tree(): await ready
		%Expression.placeholder_text = v
@export var edit_script: Resource:
	get: return edit_script
	set(v):
		assert(v != null, "Must provide a script to expression_edit")
		if v == edit_script: return
		edit_script = v
		edit_script.argument_names = argument_names
		# https://github.com/godotengine/godot-proposals/issues/325#issuecomment-845668412
		if not is_inside_tree(): await ready
		
		var is_open = G.at("_pronto_editor_plugin").get_editor_interface().get_script_editor().get_open_scripts().any(func (s): return s.resource_path == edit_script.nested_script.resource_path)
		%Expression.visible = not is_open
		%OpenFile.flat = not is_open
		%OpenFile.text = "Click to edit" if is_open else ""
		%OpenFile.tooltip_text = "Script is opened and may only be edited in the script editor until closed, otherwise your changes are overriden on save." if is_open else "Open script in the full editor."
		%Expression.text = v.source_code
		%Expression.edited_script = v
		resize()
var text: String:
	get: return %Expression.text

@export var min_width = 80
@export var max_width = 260
@export var errors = "":
	set(e):
		if e == null or e.is_empty():
			%Errors.visible = false
		else:
			%Errors.text = e
			%Errors.visible = true
		resize()

func updated_script(from: Node, signal_name: String):
	apply_changes(from, signal_name)
	return edit_script

func apply_changes(from: Node = null, signal_name: String = ""):
	edit_script.source_code = %Expression.text
	edit_script.reload()
	edit_script.emit_changed()

func _input(event):
	if not %Expression.has_focus():
		return
	if event is InputEventKey and event.pressed and not event.is_echo() and event.keycode == KEY_TAB and %Expression.text.count("\n") < 1:
		var focus
		if event.shift_pressed:
			focus = %Expression.find_prev_valid_focus()
		else:
			focus = %Expression.find_next_valid_focus()
		get_viewport().set_input_as_handled()
		if focus: focus.grab_focus()

func _ready():
	if owner != self:
		fake_a_godot_highlighter()
		resize()

func fake_a_godot_highlighter():
	if G.at("_pronto_editor_plugin") == null:
		return
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
	%Expression.syntax_highlighter = h

func get_a_godot_highlighter():
	# NOTE: causes crashes when saving scenes in the current form. Potentially because
	# we are sharing the instance between multiple editors  (which is not technically allowed)
	# GDScriptHighlighter is a private cpp class. We can obtain an instance however.
	var se = G.at("_pronto_editor_plugin").get_editor_interface().get_script_editor()
	if not se.get_open_script_editors().is_empty():
		var s = se.get_open_script_editors()[0].get_base_editor().syntax_highlighter
		%Expression.syntax_highlighter = s

func open_file():
	var interface = G.at("_pronto_editor_plugin").get_editor_interface()
	interface.edit_script(edit_script.nested_script)
	interface.set_main_screen_editor("Script")

func grab_focus():
	%Expression.grab_focus()

func extra_width():
	return 100

func _on_expression_text_changed():
	resize()
	text_changed.emit()
	%MissingReturnWarning.visible = return_value and %Expression.text.count('\n') > 0 and %Expression.text.count('return ') == 0
	%Expression.on_text_changed()

func _on_expression_focus_exited():
	blur.emit()

func resize():
	if self == owner:
		return
	if size_flags_horizontal == SIZE_FILL or size_flags_horizontal == SIZE_EXPAND_FILL:
		custom_minimum_size = Vector2(0, 43)
		Utils.fix_minimum_size(self)
	else:
		var size = get_theme_default_font().get_multiline_string_size(%Expression.text)
		custom_minimum_size = Vector2(clamp(size.x, min_width, max_width) + extra_width(), clamp(size.y, 32, 32 * 4))
		Utils.fix_minimum_size(self)
		reset_size()

func _on_expression_on_errors(errors):
	self.errors = errors
