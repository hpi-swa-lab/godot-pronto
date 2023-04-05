extends Node
class_name PState

func inc(prop: String, amount = 1):
	set_meta(prop, get_meta(prop) + amount)

func put(prop: String, value: Variant):
	set_meta(prop, value)

func at(prop: String):
	return get_meta(prop)
