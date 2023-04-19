extends Area2D

func _process(delta):
	if Input.is_action_just_pressed("ui_right"):
		move_right()
	if Input.is_action_just_pressed("ui_left"):
		move_left()
	if Input.is_action_just_pressed("ui_right"):
		move_up()
	if Input.is_action_just_pressed("ui_right"):
		move_down()
		
func move_right():
	position += Vector2(1, 0) * get_process_delta_time()
func move_left():
	position -= Vector2(1, 0) * get_process_delta_time()
func move_up():
	position += Vector2(1, 0) * get_process_delta_time()
func move_down():
	position += Vector2(1, 0) * get_process_delta_time()


