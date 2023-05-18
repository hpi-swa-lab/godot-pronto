@tool
extends CodeEdit

signal on_errors(errors: String)

var edited_script: Resource:
	set(s):
		edited_script = s
		if not _opened:
			_did_open()

var _opened = false

func _ready():
	if self != owner:
		# make space for autocompletion popup
		focus_entered.connect(func (): custom_minimum_size.y = 200)
		focus_exited.connect(func ():
			custom_minimum_size.y = 0
			Utils.with(Utils.parent_that(self, func(p): return p is NodeToNodeConfigurator), func(p):
				if p != null: p.reset_size())
			cancel_code_completion())

func _last_character():
	return 

var completion_regex = null
func on_text_changed():
	LanguageClient.did_change(edited_script, text)
	
	var line = get_line(get_caret_line())
	if line.is_empty():
		return
	var char = line[max(get_caret_column() - 1, 0)]
	if completion_regex == null:
		completion_regex = RegEx.new()
		completion_regex.compile("[^A-Za-z0-9_]")
	if completion_regex.search(char) != null:
		request_code_completion()

func _request_code_completion(force):
	ConnectionScript.map_row_col(edited_script, get_caret_line(), get_caret_column(), func (row, col):
		LanguageClient.completion(edited_script, row, col, func (entries):
			for entry in entries:
				var insert = entry["insertText"]
				if insert.is_empty(): insert = entry["label"]
				add_code_completion_option(CodeEdit.KIND_MEMBER, Utils.ellipsize(entry["label"]), insert)
			update_code_completion_options(true)
		))

func _enter_tree():
	if not _opened and edited_script != null:
		_did_open()

func _exit_tree():
	if _opened:
		LanguageClient.did_close(edited_script)
		LanguageClient.on_notification.disconnect(on_notification)
		_opened = false

func _did_open():
	LanguageClient.did_open(edited_script)
	LanguageClient.on_notification.connect(on_notification)
	_opened = true

func on_notification(notification):
	if (notification["method"] == 'textDocument/publishDiagnostics' and
		notification["params"]["uri"] == LanguageClient.script_path(edited_script)):
		on_errors.emit("\n".join(notification["params"]["diagnostics"]
			.filter(show_diagnostic)
			.map(func (d): return d["message"])))

func show_diagnostic(d):
	return not (d["message"].begins_with("(STATIC_CALLED_ON_INSTANCE)") or
		d["message"].begins_with("(UNUSED_PARAMETER)"))
