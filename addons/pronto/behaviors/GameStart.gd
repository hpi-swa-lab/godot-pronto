@tool
#thumb("PlayStart")
extends Behavior

signal gameStart

func _ready():
	super._ready()
	await get_tree().process_frame
	gameStart.emit()
