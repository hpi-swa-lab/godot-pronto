class_name ExecResult
extends RefCounted


var error
var value:
	get:
		assert(error == null, "Cannot get value of error result.")
		return value
	set(new_value):
		value = new_value


static func from_error(error) -> ExecResult:
	var result := ExecResult.new()
	result.error = error
	return result


static func from_value(value) -> ExecResult:
	var result := ExecResult.new()
	result.value = value
	return result


func is_error() -> bool:
	return error != null
