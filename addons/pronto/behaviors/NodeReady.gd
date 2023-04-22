@tool
#thumb("PlayStart")
extends Behavior

signal nodeReady

func _ready():
	super._ready()
	await get_tree().process_frame
	nodeReady.emit()
