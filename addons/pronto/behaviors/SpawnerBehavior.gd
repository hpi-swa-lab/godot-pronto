@tool
#thumb("GPUParticles3D")
extends Behavior
class_name SpawnerBehavior

## The SpawnerBehavior is a [class Behavior] that allows to spawn 
## new nodes based off a number of blueprint nodes (its children)

## Spawns all children by default. Alternatively, provide a scene path here.
@export var scene_path: NodePath = ^""

## When set, spawns new nodes as children of the given node.
@export var container: Node = null

## Type of shape used for the [method SpawnerBehavior.spawn_in_shape] method.
@export_enum("Polygon", "Generic") var shape_type: String = "Generic":
	set(val):
		shape_type = val
		queue_redraw()

## Polygon used by [method SpawnerBehavior.spawn_in_shape] method. 
## Dont set the [class PolygonShape2D] itself as child of the spawner.
@export var spawn_shape_polygon: Polygon2D = null:
	set(v):
		spawn_shape_polygon = v
		if spawn_shape_polygon:
			spawn_shape_polygon.color = Color('0099b36b')
			spawn_shape_polygon.set_visible(false)
		queue_redraw()

## Shape used by [method SpawnerBehavior.spawn_in_shape] method. 
## Supports [class CircleShape2D], [class RectangleShape2D] and [class CapsuleShape2D].
@export var spawn_shape_generic: Shape2D = null:
	set(v):
		if !is_instance_of(v, RectangleShape2D) and !is_instance_of(v, CircleShape2D) and !is_instance_of(v, CapsuleShape2D):
			push_warning("Spawners only support CircleShape2D, RectangleShape2D and CapsuleShape2D")
		spawn_shape_generic = v
		
		if spawn_shape_generic is RectangleShape2D:
			shape_size = spawn_shape_generic.size
		
		if spawn_shape_generic is CircleShape2D:
			shape_radius = spawn_shape_generic.radius
		
		if spawn_shape_generic is CapsuleShape2D:
			shape_radius = spawn_shape_generic.radius
			shape_height = spawn_shape_generic.height
		queue_redraw()

## Debug Color in Editor for the shape used by [method SpawnerBehavior.spawn_in_shape].
@export var spawn_shape_color: Color = Color('0099b36b'):
	set(v):
		spawn_shape_color = v
		queue_redraw()

# Needed to check if spawn shape has to be redrawn
var last_spawn_shape_size_rectangle: Vector2
var last_spawn_shape_size_circle: float
var last_spawn_shape_size_capsule: float
var shape_radius: float
var shape_height: float
var shape_size: Vector2

var spawn_shape_polygon_randomizer: PolygonRandomPointGenerator

## List of all blueprints the spawner can spawn
## gets calculated automatically in [method SpawnerBehavior._ready]
var scenes = null

## A list of offsets that can be used for spawning the new instances.
## This was added so that the new instances don't spawn at the same position
## which might result in unwanted collision behavior etc. The offsets are mapped
## to the blueprints by their index in the respective arrays.
var scene_offsets = null

## Emitted when [method SpawnerBehavior.spawn] completed successfully.
##
## [param instance]: the newly spawned node
signal spawned(instance: Node)

func _ready():
	super._ready()
	
	if Engine.is_editor_hint():
		add_child(preload("res://addons/pronto/helpers/GroupDrawer.tscn").instantiate(), false, INTERNAL_MODE_BACK)
	else:
		if not scene_path.is_empty():
			scenes = [get_node(scene_path)]
		else:
			scenes = get_children()
			scene_offsets = []
			for scene in scenes:
				if scene != spawn_shape_polygon:
					scene_offsets.append(scene.position)
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

## Spawns the selected blueprint(s) as the SpawnerBehavior's sibling node.
##
## [param index]: selects the blueprint to spawn. If set to [code]-1[/code],
## every blueprint gets spawned.
##
## [param relative]: selects whether the the [member SpawnerBehavior.scene_offsets]
## should be used for the spawning. If set to [code]false[/code], the new instance(s)
## will be spawned at the spawner's position. If set to [code]true[/code], the 
## corresponding offset is applied afterwards.
func spawn(index: int = -1, relative: bool = false):
	var instances = []
	if index < 0:
		for i in range(scenes.size()):
			instances.append([_spawn(i), scene_offsets[i] if scene_offsets else null])
	else:
		instances = [[_spawn(index), scene_offsets[index] if scene_offsets else null]]
	
	for instance_pair in instances:
		instance_pair[0].global_position = global_position
		if relative:
			instance_pair[0].global_position += instance_pair[1]
		spawned.emit(instance_pair[0])
	
	return instances

## Spawns the selected blueprint(s) as the SpawnerBehavior's sibling node 
## rotated towars the given position
##
## [param pos]: The position to rotate the new instance(s) towards
##
## [param index]: selects the blueprint to spawn. If set to [code]-1[/code],
## every blueprint gets spawned.
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

## Spawns the selected blueprint(s) as the SpawnerBehavior's sibling node 
## at a given position
##
## [param pos]: The position to spawn the new instance(+) at
##
## [param index]: selects the blueprint to spawn. If set to [code]-1[/code],
## every blueprint gets spawned.
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

func spawn_at_with_damage(pos: Vector2, damage = 30, index: int = -1):
	var instances = []
	if index < 0:
		for i in range(scenes.size()):
			instances.append(_spawn(i, true))
	else:
		instances = [_spawn(index, true)]
		
	for instance in instances:
		instance.global_position = pos
		instance.damage = damage
		spawned.emit(instance)
	
	return instances

## Spawns the selected blueprint(s) at a random position within the
## shape determined by [member SpawnerBehavior.shape_type], 
## [member SpawnerBehavior.spawn_shape_polygon] and [member SpawnerBehavior.spawn_shape_generic]
##
## If [member SpawnerBehavior.shape_type] is set to [code]"Polygon"[/code] it will use the
## [member SpawnerBehavior.spawn_shape_polygon] to determine the spawn coordinates.
## Otherwise it will use the shape given in [member SpawnerBehavior.spawn_shape_generic]
##
## [param index]: selects the blueprint(s) to spawn. If set to [code]-1[/code],
## every blueprint gets spawned.
func spawn_in_shape(index: int = -1):
	var instances = []
	if index < 0:
		for i in range(scenes.size()):
			instances.append(_spawn(i, true))
	else:
		instances = [_spawn(index, true)]
	
	var pos = global_position
	
	if shape_type == "Polygon":
		if spawn_shape_polygon == null:
			push_warning("No Polygon2D specified.")
			return null
		if spawn_shape_polygon_randomizer == null:
			spawn_shape_polygon_randomizer = PolygonRandomPointGenerator.new(spawn_shape_polygon.polygon)
		
		# pos = global.position # for positioning when Polygon2D is child of SpawnBehavior
		pos = spawn_shape_polygon_randomizer.get_random_point() * spawn_shape_polygon.scale
		pos += spawn_shape_polygon.position + spawn_shape_polygon.offset
		
	elif spawn_shape_generic == null:
		push_warning("No Shape2D specified.")
		return null
	elif spawn_shape_generic is CircleShape2D:
		pos.x += spawn_shape_generic.radius + 2
		
		while(global_position.distance_to(pos) > spawn_shape_generic.radius):
			pos.x = global_position.x +  randf_range(-spawn_shape_generic.radius, spawn_shape_generic.radius)
			pos.y = global_position.y +  randf_range(-spawn_shape_generic.radius, spawn_shape_generic.radius)
			
	elif spawn_shape_generic is RectangleShape2D:
		pos.y = global_position.y + randf_range(-spawn_shape_generic.size.y * 0.5,spawn_shape_generic.size.y * 0.5)
		pos.x = global_position.x + randf_range(-spawn_shape_generic.size.x * 0.5,spawn_shape_generic.size.x * 0.5)
		
	elif spawn_shape_generic is CapsuleShape2D:
		pos.x = global_position.x +  randf_range(-spawn_shape_generic.radius, spawn_shape_generic.radius)
		pos.y = global_position.y +  randf_range(-spawn_shape_generic.height/2, spawn_shape_generic.height/2)
		var is_out_of_radius
		var is_out_of_height
		var is_out_of_radius_height
		
		while(is_out_of_radius or is_out_of_height):
			var true_rect = spawn_shape_generic.height/2 - spawn_shape_generic.radius
			
			if (global_position + Vector2(0,true_rect)).distance_to(pos) < spawn_shape_generic.radius or (global_position - Vector2(0,true_rect)).distance_to(pos) < spawn_shape_generic.radius:
				break
			pos.x = global_position.x +  randf_range(-spawn_shape_generic.radius, spawn_shape_generic.radius)
			pos.y = global_position.y +  randf_range(-true_rect, true_rect)
			
			is_out_of_radius = global_position.distance_to(Vector2(pos.x,global_position.y)) > spawn_shape_generic.radius
			is_out_of_height = global_position.distance_to(Vector2(global_position.x,pos.y)) > true_rect
	
	for instance in instances:
		instance.global_position = pos
		spawned.emit(instance)
	
	return instances


## Override of [method Behavior.lines] in order to display
## dashed lines towards the spawner's blueprints (aka its childs)
func lines():
	var ret = super.lines()
	for child in get_children():
		ret.append(Lines.DashedLine.new(self, child, func (f): return "spawns", "spawns"))
	return ret

func _draw():
	super._draw()
	if Engine.is_editor_hint():
		draw_set_transform(Vector2.ZERO)
		if shape_type == "Generic" and spawn_shape_generic:
			spawn_shape_generic.draw(get_canvas_item(),spawn_shape_color)

func _process(delta):
	super._process(delta)
	
	if shape_type == "Generic" and spawn_shape_generic:
		if spawn_shape_generic is RectangleShape2D and spawn_shape_generic.size != shape_size:
			spawn_shape_generic.size = shape_size
		
		if spawn_shape_generic is CircleShape2D and spawn_shape_generic.radius != shape_radius:
			spawn_shape_generic.radius = shape_radius
		
		if spawn_shape_generic is CapsuleShape2D:
			if spawn_shape_generic.radius != shape_radius or spawn_shape_generic.height != shape_height:
				spawn_shape_generic.radius = shape_radius
				spawn_shape_generic.height = shape_height
		
		if spawn_shape_generic is RectangleShape2D and spawn_shape_generic.size != last_spawn_shape_size_rectangle:
			last_spawn_shape_size_rectangle = spawn_shape_generic.size
			queue_redraw()
			
		if spawn_shape_generic is CircleShape2D and spawn_shape_generic.radius != last_spawn_shape_size_circle:
			last_spawn_shape_size_circle = spawn_shape_generic.radius
			queue_redraw()
			
		if spawn_shape_generic is CapsuleShape2D and spawn_shape_generic.height != last_spawn_shape_size_capsule or spawn_shape_generic.radius != last_spawn_shape_size_circle:
			last_spawn_shape_size_circle = spawn_shape_generic.radius
			last_spawn_shape_size_capsule = spawn_shape_generic.height
			queue_redraw()


func handles():
	if shape_type == "Polygon":
		return null
	
	if shape_type == "Generic" and spawn_shape_generic:
		if is_instance_of(spawn_shape_generic, RectangleShape2D):
			return [
				Handles.SetPropHandle.new(
					(transform * spawn_shape_generic.size - position) / 2,
					Utils.icon_from_theme("EditorHandle", self),
					self,
					"shape_size",
					func (coord): return (floor(coord * 2) * transform.translated(-position)).clamp(Vector2(1, 1), Vector2(10000, 10000)))
			]
		elif is_instance_of(spawn_shape_generic, CircleShape2D):
			return [
				Handles.SetPropHandle.new(
					(transform * Vector2(spawn_shape_generic.radius, 0) - position),
					Utils.icon_from_theme("EditorHandle", self),
					self,
					"shape_radius",
					func (coord): return clamp(coord.distance_to(Vector2(0,0)),1.0, 10000.0))
			]
		elif is_instance_of(spawn_shape_generic, CapsuleShape2D):
			return [
				Handles.SetPropHandle.new(
					(transform * Vector2(spawn_shape_generic.radius, 0) - position),
					Utils.icon_from_theme("EditorHandle", self),
					self,
					"shape_radius",
					func (coord): return clamp(coord.distance_to(Vector2(0,0)),1.0, 10000.0)),
				Handles.SetPropHandle.new(
					(transform * Vector2(0, spawn_shape_generic.height/2) - position),
					Utils.icon_from_theme("EditorHandle", self),
					self,
					"shape_height",
					func (coord): return clamp(coord.distance_to(Vector2(0,0)),1.0, 10000.0)*2)
			]

