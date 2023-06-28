@tool
#thumb("GPUParticles3D")
extends Behavior

## Spawns all children by default. Alternatively, provide a scene path here.
@export var scene_path: NodePath = ^""

## Shape used by 'spawn_in_shape' method. Only supports 'CircleShape2D' and 'RectangleShape2D'.
@export var spawn_shape: Shape2D = null:
	set(v):
		if !is_instance_of(v, RectangleShape2D) and !is_instance_of(v, CircleShape2D):
			push_warning("Spawners only support CircleShape2D and RectangleShape2D")
		spawn_shape = v
		queue_redraw()

## Debug Color in Editor for the shape used by 'spawn_in_shape'.
@export var spawn_shape_color: Color = Color('0099b36b')

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

func spawn_in_shape(index: int = -1):
	var instances = []
	if index < 0:
		for i in range(scenes.size()):
			instances.append(_spawn(i, true))
	else:
		instances = [_spawn(index, true)]
	
	var pos = global_position
	
	if spawn_shape is CircleShape2D:
		pos.x += spawn_shape.radius + 2
		
		while(global_position.distance_to(pos) > spawn_shape.radius):
			pos.x = global_position.x +  randf_range(-spawn_shape.radius, spawn_shape.radius)
			pos.y = global_position.y +  randf_range(-spawn_shape.radius, spawn_shape.radius)
	
	if spawn_shape is RectangleShape2D:
		pos.y = global_position.y + randf_range(-spawn_shape.size.y * 0.5,spawn_shape.size.y * 0.5)
		pos.x = global_position.x + randf_range(-spawn_shape.size.x * 0.5,spawn_shape.size.x * 0.5)
	
	for instance in instances:
		instance.global_position = pos
		spawned.emit(instance)
	
	return instances

func lines():
	var ret = super.lines()
	for child in get_children():
		ret.append(Lines.DashedLine.new(self, child, func (f): return "spawns", "spawns"))
	return ret

func _draw():
	super._draw()
	if Engine.is_editor_hint():
		draw_set_transform(Vector2.ZERO)
		if spawn_shape:
			spawn_shape.draw(get_canvas_item(),spawn_shape_color)

func _process(delta):
	super._process(delta)
	queue_redraw()
