extends Label

func _process(delta):
	text = "Seconds survived: " + str(int(Time.get_ticks_msec()/1000))
