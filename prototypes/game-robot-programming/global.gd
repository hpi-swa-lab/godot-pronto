extends Node

var handled_events = []

func note_event(event):
	handled_events.push_back(weakref(event))
	handled_events = handled_events.filter(func(x): return x.get_ref() != null)
	
func event_is_handled(event):
	for e in handled_events:
		if e.get_ref() == event:
			return true
	return false
