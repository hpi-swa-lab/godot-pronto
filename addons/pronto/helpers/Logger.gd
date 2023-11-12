extends Node
class_name Logger

enum LEVEL{
	DEBUG,
	INFO,
	WARN,
	ERROR
}

var file = null
var logger_name = ""

func _init(filePath, custom_logger_name = ""):
	file = FileAccess.open(filePath, FileAccess.WRITE)
	print(FileAccess.get_open_error())
	logger_name = custom_logger_name

func log(text):
	log_with_lvl(text, "INFO")

func log_with_lvl(text, level):
	assert(file != null, "Instantiate a Logger(filePath) before using log(text)") 
	file.store_string(Time.get_datetime_string_from_system(false, true) + " [" + level + "] " + logger_name + " - " + text + "\n")
	
func close():
	file.close()	
	
