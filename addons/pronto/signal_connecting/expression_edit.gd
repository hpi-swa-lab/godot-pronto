@tool
extends VBoxContainer

signal text_changed()
signal blur()

## Set to direct that this editor should override the argument_names of the
## given script. If false, the argument_names will be taken from the script.
var control_argument_names = true

@export var return_value = true
@export var argument_names: Array = []:
	set(v):
		if edit_script != null and "argument_names" in edit_script and control_argument_names:
			edit_script.argument_names = v
		argument_names = v
	get:
		if control_argument_names:
			return argument_names
		else:
			return edit_script.argument_names
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
		if control_argument_names:
			edit_script.argument_names = argument_names
		# https://github.com/godotengine/godot-proposals/issues/325#issuecomment-845668412
		if not is_inside_tree(): await ready
		%Expression.text = edit_script.source_code
		%Expression.edited_script = edit_script
		update_editable()
		resize()
var text: String:
	get: return %Expression.text

@export var default_text : String = '<none>':
	set(v):
		default_text = v
		update_editable()

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

# Can be set to override the default minimum size.
var dragged_minimum_size = null

func update_editable():
	%Reset.visible = default_text != '<none>' and %Expression.text != default_text
	if not edit_script: return
	var path = edit_script.nested_script.resource_path
	var is_open = G.at("_pronto_editor_plugin").get_editor_interface().get_script_editor().get_open_scripts().any(func (s): return s.resource_path == path)
	if %Expression.visible != is_open: return
	%Expression.visible = not is_open
	%OpenFile.flat = not is_open
	%OpenFile.text = "Click to edit" if is_open else ""
	%OpenFile.tooltip_text = "Script is opened and may only be edited in the script editor until closed, otherwise your changes are overriden on save." if is_open else "Open script in the full editor."
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
	if (event is InputEventKey and
		event.pressed and
		not event.is_echo() and
		event.keycode == KEY_TAB and
		%Expression.text.count("\n") < 1 and
		%Expression.get_code_completion_selected_index() < 0):
		var focus
		if event.shift_pressed:
			focus = %Expression.find_prev_valid_focus()
		else:
			focus = %Expression.find_next_valid_focus()
		get_viewport().set_input_as_handled()
		if focus: focus.grab_focus()

func _process(d):
	update_editable()

func _ready():
	if owner != self:
		fake_a_godot_highlighter()
		resize()
		%Expression.code_completion_prefixes = [".", ",", "(", "=", "$", "@", "\"", "\'"]

func fake_a_godot_highlighter():
	if G.at("_pronto_editor_plugin") == null:
		return
	var s = G.at("_pronto_editor_plugin").get_editor_interface().get_editor_settings()
	var h = CodeHighlighter.new()
	h.color_regions = {
		"\"": s.get("text_editor/theme/highlighting/string_color"),
		"'": s.get("text_editor/theme/highlighting/string_color")
	}
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

func _on_expression_text_changed():
	resize()
	text_changed.emit()
	%MissingReturnWarning.visible = return_value and %Expression.text.count('\n') > 0 and %Expression.text.count('return ') == 0
	%Expression.on_text_changed()
	%Reset.visible = default_text != '<none>' and %Expression.text != default_text

func _on_expression_focus_exited():
	blur.emit()

func resize():
	if self == owner:
		return
	# BEWARE! We're fighting against the windmills of Godot's layout system here which
	# is pretty much a blackbox to us. Discover the uncertainties and strangenesses
	# of the layout system by logging the node's size over the turn of frames (which
	# seem to act as layout passes). Maybe our own _process() methods that override
	# some layout properties are to blame as well. But hey, it (kinda) works!
	# PS: If it ain't broke, don't fix it.
	custom_minimum_size = dragged_minimum_size if dragged_minimum_size else Vector2(0, 43)
	if dragged_minimum_size == null:
		# resize to text
		const pseudo_cursor = "|"
		var text_size := get_theme_default_font().get_multiline_string_size(%Expression.text + pseudo_cursor)
		const max_lines = 8
		const line_height = 32
		const spacing = 11
		custom_minimum_size.y = clamp(text_size.y + spacing, line_height, line_height * max_lines) \
			+ randf() # yeah, seriously. if the height does not change, the width collapses.
	else:
		custom_minimum_size.x = max(custom_minimum_size.x, \
			320)  # what's the original minimum width (not the custom one)?
	Utils.fix_minimum_size(self)
	reset_size()
	var nodeToNodeConfigurator = Utils.parent_that(self, func(n): return n is NodeToNodeConfigurator)
	if nodeToNodeConfigurator != null:
		nodeToNodeConfigurator.reset_size()

func _on_expression_on_errors(errors):
	self.errors = errors

func _on_reset_pressed():
	if default_text != '<none>':
		%Expression.text = default_text
		_on_expression_text_changed()
