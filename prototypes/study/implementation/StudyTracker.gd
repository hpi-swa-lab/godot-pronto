@tool
extends Node2D
class_name StudyTracker

@export var participantId: int = 0
@export var studyId: String = "A1"

@export var active = false:
	set(value):
		if participantId == 0:
			print("Participant ID not set, study tracker won't activate!")
			return
		active = value	
		_handle_activation(value)

var logger: Logger = null

func _handle_activation(_active):
	if Engine.is_editor_hint():
		if _active:
			logger = Logger.new("C:/test/studyLog_participant_" + str(participantId) + ".log", "studyTracker")
			_subscribe_to_relevant_signals()
			logger.log("Participant " + str(participantId) + " started study " + str(studyId))
			print("Activated")
		else:
			logger.log("Participant " + str(participantId) + " stopped study " + str(studyId))
			_gather_final_data()
			logger.close()
			var root = self
			root.child_entered_tree.disconnect(_log_event)
			root.child_exiting_tree.disconnect(_log_event)
			print("Deactivated")	

func _subscribe_to_relevant_signals():
	if Engine.is_editor_hint():
		var root = self
		root.child_entered_tree.connect(_log_event.bind("child_entered_tree"))
		root.child_exiting_tree.connect(_log_event.bind("child_exited_tree"))

func _log_event(data, event):
	if active:
		logger.log(event + ": " + str(data))

func _gather_final_data():
	logger.log("Final state:")
	logger.log("    Editor tree node count: " + str(len(get_all_children(get_node("./")))))
	logger.log("    Maximum node depth: " + str(_get_tree_depth(self)))

func _get_tree_depth(node):
	var tmp = 0
	if node.get_child_count() == 0:
		return 1
	for n in node.get_children():
		tmp = max(_get_tree_depth(n), tmp)
	return tmp+1

func get_all_children(in_node,arr:=[]):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_all_children(child,arr)
	return arr
