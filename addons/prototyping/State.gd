extends Node
class_name PState

func inc(prop: String, amount = 1):
	set_meta(prop, get_meta(prop) + amount)
