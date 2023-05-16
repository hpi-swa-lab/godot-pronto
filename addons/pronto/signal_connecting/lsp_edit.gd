@tool
extends CodeEdit

var language_client: LanguageClient
var edited_script: Script:
	set(s):
		edited_script = s
		language_client.did_open(s)

func _ready():
	text_changed.connect(on_text_changed)

func on_text_changed():
	edited_script.source_code = text
	language_client.did_change(edited_script)

func _request_code_completion(force):
	print([get_caret_line(), get_caret_column()])
	language_client.completion(edited_script, get_caret_line(), get_caret_column(), func (entries):
		for entry in entries:
			# print(entry)
			pass
			# add_code_completion_option(CodeEdit.KIND_MEMBER)
	)
