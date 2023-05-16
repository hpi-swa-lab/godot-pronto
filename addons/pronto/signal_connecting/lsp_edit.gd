@tool
extends CodeEdit

var edited_script: Script:
	set(s):
		edited_script = s

func on_text_changed():
	LanguageClient.did_change(edited_script, text)

func _request_code_completion(force):
	print([get_caret_line(), get_caret_column()])
	LanguageClient.completion(edited_script, get_caret_line(), get_caret_column(), func (entries):
		for entry in entries:
			# print(entry)
			pass
			# add_code_completion_option(CodeEdit.KIND_MEMBER)
	)

func _enter_tree():
	if edited_script == null:
		await get_tree().process_frame
	assert(edited_script != null)
	LanguageClient.did_open(edited_script)
	LanguageClient.on_notification.connect(on_notification)

func _exit_tree():
	LanguageClient.did_close(edited_script)
	LanguageClient.on_notification.disconnect(on_notification)

func on_notification(notification):
	if (notification["method"] == 'textDocument/publishDiagnostics' and
		notification["params"]["uri"] == LanguageClient.script_path(edited_script)):
		print(notification["params"]["diagnostics"])
