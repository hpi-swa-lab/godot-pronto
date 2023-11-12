@tool
#thumb("GuiVisibilityHidden")
extends Behavior
class_name StudyTrackerBehavior

@export var participantId: int = 0
@export var studyId: String = "A1"

@export var active = false:
	set(value):
		if participantId == 0:
			print("Participant ID not set, study tracker won't activate!")
			return
		active = value	
		_handle_activation(value)

var logger = null

# TODO: do we want to handle godot crashes explicitly?
func _handle_activation(_active):
	if _active:
		logger = Logger.new("C:/test/studyLog_participant_" + str(participantId) + ".log", "studyTracker")
		_subscribe_to_relevant_signals()
		logger.log("Participant " + str(participantId) + " started study " + str(studyId))
		print("Activated")
	else:
		logger.log("Participant " + str(participantId) + " stopped study " + str(studyId))
		_gather_final_data()
		logger.close()
		print("Deactivated")	

func _subscribe_to_relevant_signals():
	if Engine.is_editor_hint():
		var root = self.owner
		logger.log("subscribed the following events:")
		# the following events are relevant for pronto
		# - insertion of behavior
		# - creation of connection
		# - editing of connection
		# - removal of connection
		# - removal of behavior
		# - editing of values ?
		# - creation/edit of behavior (unlikely to detect through any signal)
		root.child_entered_tree.connect(_log_event.bind("child_entered_tree"))
		root.child_exiting_tree.connect(_log_event.bind("child_exited_tree"))
		# root.ready.connect(_log_event.bind("game_launched_successfuly"))  <-- doesn't work
	

func _log_event(data, event):
	logger.log(event + ": " + str(data))

func _gather_final_data():
	logger.log("Final state:")
	logger.log("Editor tree node count: " + str(get_tree().get_node_count()))
	logger.log("Maximum depth: " + str(_get_tree_depth()))

func _get_tree_depth():
	return "N/A"

		
# Called when the node enters the scene tree for the first time.
func _ready():
	print("ready")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(_get_tree_depth())
	pass
