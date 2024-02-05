extends Area2D

const TARGET_Y = 865
const SPAWN_Y = 516
const DIST_TO_TARGET = TARGET_Y - SPAWN_Y

const LEFT_LANE_SPAWN = Vector2(1254, SPAWN_Y)
const CENTRE_LANE_SPAWN = Vector2(1322, SPAWN_Y)
const RIGHT_LANE_SPAWN = Vector2(1388, SPAWN_Y)

var speed = 0
var hit = false

var bpm = 150
var sec_per_beat = 60.0 / bpm


func _ready():
	pass


func _physics_process(delta):
	if !hit:
		position.y += speed * delta
		if position.y > 930:
			queue_free()
			get_parent().reset_combo()
	else:
		$Node2D.position.y -= speed * delta


func initialize(lane):
	if lane == 0:
		$AnimatedSprite.frame = 0
		position = LEFT_LANE_SPAWN
	elif lane == 1:
		$AnimatedSprite.frame = 1
		position = CENTRE_LANE_SPAWN
	elif lane == 2:
		$AnimatedSprite.frame = 2
		position = RIGHT_LANE_SPAWN
	else:
		printerr("Invalid lane set for note: " + str(lane))
		return
	
	speed = DIST_TO_TARGET / (sec_per_beat * 3)


func destroy(score):
	$CPUParticles2D.emitting = true
	$AnimatedSprite.visible = false
	$Timer.start()
	hit = true
	if score == 3:
		$Node2D/Label.text = "GREAT"
		$Node2D/Label.modulate = Color("f6d6bd")
	elif score == 2:
		$Node2D/Label.text = "GOOD"
		$Node2D/Label.modulate = Color("c3a38a")
	elif score == 1:
		$Node2D/Label.text = "OKAY"
		$Node2D/Label.modulate = Color("997577")


func _on_Timer_timeout():
	queue_free()