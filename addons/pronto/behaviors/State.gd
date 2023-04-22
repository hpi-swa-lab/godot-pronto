@tool
#thumb("CylinderMesh")
extends Behavior

### When enabled, add the value of all properties to the global G dictionary as well.
@export var global = false

signal changed(prop: String, value: Variant)

func _ready():
	super._ready()
	if global:
		for prop in get_meta_list():
			G.put(prop, get_meta(prop))

func inc(prop: String, amount = 1):
	var value = get_meta(prop) + amount
	put(prop, value)

func put(prop: String, value: Variant):
	set_meta(prop, value)
	if global:
		G.put(prop, value)
	changed.emit(prop, value)

func at(prop: String):
	return get_meta(prop)
