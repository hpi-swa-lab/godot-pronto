extends Node

@export var method: String

func invoke(obj):
	obj.call(method)
