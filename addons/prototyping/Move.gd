extends Node

@export var speed = 1.0

func move_left():
	get_parent().position += Vector2(-speed * get_process_delta_time(), 0)

func move_right():
	get_parent().position += Vector2(speed * get_process_delta_time(), 0)

func move_down():
	get_parent().position += Vector2(0, speed * get_process_delta_time())
