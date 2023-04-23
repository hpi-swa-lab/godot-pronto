@tool
#thumb("GPUParticles3D")
extends Behavior

var scene = null

func _init():
	super._init()
	
	child_entered_tree.connect(func (n):
		add_line(Lines.DashedLine.new(self, get_child(0), "instances")))
	child_exiting_tree.connect(func (n):
		if n.get_index() == 0:
			add_line(Lines.DashedLine.new(self, get_child(1), "instances")))

func _ready():
	super._ready()
	
	if not Engine.is_editor_hint():
		scene = get_child(0)
		remove_child(scene)

func _spawn():
	return scene.duplicate(DUPLICATE_USE_INSTANTIATION | DUPLICATE_SCRIPTS | DUPLICATE_SIGNALS | DUPLICATE_GROUPS)

func spawn():
	var instance = _spawn()
	instance.position = position
	get_parent().add_child(instance)

func spawn_toward(pos: Vector2):
	var instance = _spawn()
	instance.top_level = true
	instance.global_position = global_position
	instance.rotation = global_position.angle_to_point(pos)
	get_parent().add_child(instance)
