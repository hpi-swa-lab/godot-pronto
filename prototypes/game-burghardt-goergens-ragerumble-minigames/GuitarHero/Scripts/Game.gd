extends Node2D

var score = 0
var combo = 0

var max_combo = 0
var great = 0
var good = 0
var okay = 0
var missed = 0

var healCounter = 0

var startTime = Time.get_unix_time_from_system()
var endTime

var lastClickTime = Time.get_unix_time_from_system()
var lastBeatTime = 0

var bpm = 150

var song_position = 0.0
var song_position_in_beats = 0
var last_spawned_beat = 0
var sec_per_beat = 60.0 / bpm

var spawn_1_beat = 0
var spawn_2_beat = 0
var spawn_3_beat = 1
var spawn_4_beat = 0

var lane = 0
var rand = 0
var note = load("res://prototypes/game-burghardt-goergens-ragerumble-minigames/GuitarHero/Note.tscn")
var instance

signal comboBuff(activated)


func _ready():
	randomize()
	$Conductor.play_with_beat_offset(8)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if get_tree().change_scene_to_file("res://prototypes/game-burghardt-goergens-ragerumble-minigames/GuitarHero/menu.tscn") != OK:
			print ("Error changing scene to Menu")
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var now = Time.get_unix_time_from_system()
		if now - lastClickTime > sec_per_beat * 0.7:
			lastClickTime = now
			var accuracy = calculateAccuracy(now, lastBeatTime)
			fight(accuracy)


func _on_Conductor_measure(localPosition):
	if localPosition == 1:
		_spawn_notes(spawn_1_beat)
	elif localPosition == 2:
		_spawn_notes(spawn_2_beat)
	elif localPosition == 3:
		_spawn_notes(spawn_3_beat)
	elif localPosition == 4:
		_spawn_notes(spawn_4_beat)

func _on_Conductor_beat(localPosition, beatTime):
	lastBeatTime = beatTime
	song_position_in_beats = localPosition
	if song_position_in_beats > 36:
		spawn_1_beat = 2
		spawn_2_beat = 0
		spawn_3_beat = 1
		spawn_4_beat = 0
	if song_position_in_beats > 53:
		spawn_1_beat = 1
		spawn_2_beat = 1
		spawn_3_beat = 1
		spawn_4_beat = 1
	if song_position_in_beats > 80:
		spawn_1_beat = 2
		spawn_2_beat = 2
		spawn_3_beat = 1
		spawn_4_beat = 1
	if song_position_in_beats > 108:
		spawn_1_beat = 2
		spawn_2_beat = 2
		spawn_3_beat = 2
		spawn_4_beat = 1
	if song_position_in_beats > 128:
		spawn_1_beat = 1
		spawn_2_beat = 0
		spawn_3_beat = 2
		spawn_4_beat = 0
	if song_position_in_beats > 144:
		spawn_1_beat = 0
		spawn_2_beat = 2
		spawn_3_beat = 1
		spawn_4_beat = 2
	if song_position_in_beats > 160:
		spawn_1_beat = 0
		spawn_2_beat = 0
		spawn_3_beat = 1
		spawn_4_beat = 1
	if song_position_in_beats > 192:
		spawn_1_beat = 2
		spawn_2_beat = 1
		spawn_3_beat = 2
		spawn_4_beat = 2
	if song_position_in_beats > 208:
		spawn_1_beat = 3
		spawn_2_beat = 2
		spawn_3_beat = 2
		spawn_4_beat = 1
	if song_position_in_beats > 222:
		spawn_1_beat = 1
		spawn_2_beat = 0
		spawn_3_beat = 1
		spawn_4_beat = 0
	if song_position_in_beats > 248:
		spawn_1_beat = 0
		spawn_2_beat = 0
		spawn_3_beat = 0
		spawn_4_beat = 0
	if song_position_in_beats > 259:
		if get_tree().change_scene_to_file("res://prototypes/game-burghardt-goergens-ragerumble-minigames/GuitarHero/menu.tscn") != OK:
			print ("Error changing scene to Menu")



func _spawn_notes(to_spawn):
	if to_spawn > 0:
		lane = randi() % 3
		instance = note.instantiate()
		instance.initialize(lane)
		add_child(instance)
	if to_spawn > 1:
		while rand == lane:
			rand = randi() % 3
		lane = rand
		instance = note.instantiate()
		instance.initialize(lane)
		add_child(instance)
		


func increment_score(by):
	if by > 0:
		combo += 1
		onHeal()
	else:
		reset_combo()
	
	if by == 3:
		great += 1
	elif by == 2:
		good += 1
	elif by == 1:
		okay += 1
	else:
		missed += 1
	
	score += by * combo
	$ScoreLabel.text = "Score: " + str(score)
	if combo > 0:
		$Combo.text = str(combo) + " combo!"
		if combo > max_combo:
			max_combo = combo
			$MaxCombo.text = str(max_combo) + " max!"
	else:
		$Combo.text = ""
	
	if combo == 40:
		comboBuff.emit(true)


func reset_combo():
	if missed == 0:
		endTime = Time.get_unix_time_from_system()
		var flawlessTime = endTime - startTime
		$FlawlessLabel.text = "Flawless for: " + str(floor(flawlessTime)) + " seconds"
	missed += 1
	combo = 0
	comboBuff.emit(false)
	$Combo.text = ""
	
func onHeal():
	healCounter += 1
	if healCounter == 5:
		$Player.onHeal()
		healCounter = 0

func fight(accuracy):
	$Hero.onAttacked(accuracy)
	
func attackPlayer(damage):
	$Player.onAttacked(damage)

func calculateAccuracy(clickTime, beatTime):
	var diff = abs(clickTime - beatTime)
	var accuracy = abs(0.5 - (diff / sec_per_beat)) * 2 #Take Distance to the time between two beats, clamped between 0 and 0.5, scaled to 0 to 1
	print("Clicktime: " + str(clickTime))
	print("Beattime: " + str(beatTime))
	print("diff: " + str(diff))
	print("acc:" + str(accuracy))
	if accuracy >= 0.85:
		return 3
	elif accuracy >= 0.7:
		return 2
	else:
		return 1
	
