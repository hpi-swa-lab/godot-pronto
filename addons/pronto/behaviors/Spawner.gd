@tool
#thumb("GPUParticles3D")
extends Behavior

## Spawns its direct child by default. Alternatively, provide a scene path here.
@export var scene_path: NodePath = ^""

## When set, spawns new nodes as children of the given node.
@export var container: Node = null

var scenes = null

signal spawned(instance: Node)

func _ready():
	super._ready()
	
	if not Engine.is_editor_hint():
		if not scene_path.is_empty():
			scenes = [get_node(scene_path)]
		else:
			scenes = get_children()
			for scene in scenes:
				remove_child(scene)

func _duplicate_blueprint(index: int):
	return scenes[index].duplicate(DUPLICATE_USE_INSTANTIATION | DUPLICATE_SCRIPTS | DUPLICATE_SIGNALS | DUPLICATE_GROUPS)

func _spawn(index: int, top_level: bool = false):
	var instance = _duplicate_blueprint(index)
	
	instance.top_level = top_level
	
	if container == null:
		var path_corrector = Node.new()
		path_corrector.add_child(instance)
		get_parent().add_child(path_corrector)
	else:
		container.add_child(instance)
	
	return instance

func spawn(index: int = -1):
	var instances = []
	if index < 0:
		for i in range(scenes.size()):
			instances.append(_spawn(i))
	else:
		instances = [_spawn(index)]
	
	for instance in instances:
		instance.global_position = global_position
		spawned.emit(instance)
	
	return instances

func spawn_toward(pos: Vector2, index: int = -1):
	var instances = []
	if index < 0:
		for i in range(scenes.size()):
			instances.append(_spawn(i, true))
	else:
		instances = [_spawn(index, true)]
	
	for instance in instances:
		instance.global_position = global_position
		instance.rotation = global_position.angle_to_point(pos)
		spawned.emit(instance)
	
	return instances

func spawn_at(pos: Vector2, index: int = -1):
	var instances = []
	if index < 0:
		for i in range(scenes.size()):
			instances.append(_spawn(i, true))
	else:
		instances = [_spawn(index, true)]
		
	for instance in instances:
		instance.global_position = pos
		spawned.emit(instance)
	
	return instances

func lines():
	var ret = super.lines()
	for child in get_children():
		ret.append(Lines.DashedLine.new(self, child, func (f): return "spawns", "spawns"))
	return ret
