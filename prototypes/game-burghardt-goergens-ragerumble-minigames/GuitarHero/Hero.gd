extends CharacterBody2D

var hitNote = false
var attacked = false
var labelPosition
var hitLabelPosition
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$Timer.start(5)
	labelPosition = $LabelContainer.position
	hitLabelPosition = $HitLabelContainer.position
	$HitLabelContainer/Label.modulate = Color("ff0000")

func _physics_process(delta):
	if hitNote:
		$LabelContainer.position.y -= 100 * delta
		$LabelContainer.position.x -= 75 * delta

func onAttacked(accuracy):
	$HealthBarBehavior.damage(5 * accuracy)
	attacked = true
	if accuracy == 3:
		$HitLabelContainer/Label.text = "!!!"
	elif accuracy == 2:
		$HitLabelContainer/Label.text = "!!"
	elif accuracy == 1:
		$HitLabelContainer/Label.text = "!"
	$HitLabelTimer.start(0.2)


func _on_timer_timeout():
	var randScore = randi_range(1,3)
	hitNote = true
	onHeal(randScore)
	onFight(randScore)
	if randScore == 3:
		$LabelContainer/Label.text = "GREAT"
		$LabelContainer/Label.modulate = Color("f6d6bd")
	elif randScore == 2:
		$LabelContainer/Label.text = "GOOD"
		$LabelContainer/Label.modulate = Color("c3a38a")
	elif randScore == 1:
		$LabelContainer/Label.text = "OKAY"
		$LabelContainer/Label.modulate = Color("997577")
		
	var randTime = randi_range(1,2)
	$Timer.start(randTime)
	$LabelTimer.start(0.5)
	

func _on_label_timer_timeout():
	hitNote = false
	$LabelContainer/Label.text = ""
	$LabelContainer.position = labelPosition
	
func _on_hit_label_timer_timeout():
	attacked = false
	$HitLabelContainer/Label.text = ""
	$HitLabelContainer.position = hitLabelPosition

func onHeal(accuracy):
	$HealthBarBehavior.heal(5 * accuracy)
	
func onFight(accuracy):
	get_parent().attackPlayer(accuracy)
