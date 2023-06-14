@tool
#thumb("GPUParticles3D")
extends Behavior

## Spawns its direct child by default. Alternatively, provide a scene path here.
@export var scene_path: NodePath = ^""

## When set, spawns new nodes as children of the given node.
@export var container: Node = null

var scene = null

signal spawned(instance: Node)

func _ready():
	super._ready()
	
	if not Engine.is_editor_hint():
		if not scene_path.is_empty():
			scene = get_node(scene_path)
		else:
			scene = get_child(0)
			remove_child(scene)

func _duplicate_blueprint():
	return scene.duplicate(DUPLICATE_USE_INSTANTIATION | DUPLICATE_SCRIPTS | DUPLICATE_SIGNALS | DUPLICATE_GROUPS)

func _spawn(top_level: bool = false):
	var instance = _duplicate_blueprint()
	
	instance.top_level = top_level
	
	if container == null:
		var path_corrector = Node.new()
		path_corrector.add_child(instance)
		get_parent().add_child(path_corrector)
	else:
		container.add_child(instance)
	
	return instance

func spawn():
	var instance = _spawn()
	
	instance.global_position = global_position
	spawned.emit(instance)
	
	return instance

func spawn_toward(pos: Vector2):
	var instance = _spawn(true)
	
	instance.global_position = global_position
	instance.rotation = global_position.angle_to_point(pos)
	
	spawned.emit(instance)
	
	return instance

func spawn_at(pos: Vector2):
	var instance = _spawn(true)
	
	instance.global_position = pos
	
	spawned.emit(instance)
	
	return instance

func lines():
	return super.lines() + ([Lines.DashedLine.new(self, get_child(0), func (f): return "spawns", "spawns")] if get_child_count() > 0 else [])
