@tool
#thumb("Instance")
extends Behavior
class_name InstanceBehavior
## Allows you to instantiate its children in multiple places, while syncing changes to the original to all instances.
## Effectively creates a nested scene, in the same way that you would create a new scene in Godot.
## Supports editable children and overriding properties in its instances.
## Focus the connection list popup to create instances.

var scene_path: String = ""

func _ready():
	super._ready()
	if Engine.is_editor_hint():
		add_child(preload("res://addons/pronto/helpers/GroupDrawer.tscn").instantiate(), false, INTERNAL_MODE_BACK)
	else:
		get_child(0).queue_free()

func connect_ui():
	var b = Button.new()
	b.text = "Instance"
	b.pressed.connect(create_instance)
	return b

func _get_editor_node():
	return Utils.find(get_node("/root").get_children(),
		func (n: Node): return n.get_class() == "EditorNode")

func _enter_tree():
	if Engine.is_editor_hint():
		_get_editor_node().scene_saved.connect(maybe_update_scene)

func _exit_tree():
	if Engine.is_editor_hint():
		_get_editor_node().scene_saved.disconnect(maybe_update_scene)

func maybe_update_scene(path: String):
	if owner.scene_file_path == path:
		update_scene()

func update_scene():
	var root = get_child(0)
	Utils.all_nodes_do(root, func(n): if n != root: n.owner = root)
	var p = PackedScene.new()
	p.pack(root)
	
	if scene_path == "":
		var name = RegEx.create_from_string("[^A-Za-z0-9-_]").sub(
			"{0}__{1}".format([owner.scene_file_path.substr("res://".length()).get_basename(), str(owner.get_path_to(self))]),
			"_",
			true)
		DirAccess.make_dir_absolute("res://.scene-instances")
		scene_path = "res://.scene-instances/" + name + ".tscn"
	var old = FileAccess.get_file_as_string(scene_path)
	ResourceSaver.save(p, scene_path)
	var changed = old != FileAccess.get_file_as_string(scene_path)
	Utils.all_nodes_do(root, func(n): if n != root: n.owner = owner)
	
	if changed:
		# causing errors in the console right now, see:
		# https://github.com/godotengine/godot/issues/75839
		# Once fixed, we can drop the changed detection above likely as well
		get_editor_plugin().get_editor_interface().get_resource_filesystem().resources_reimported.emit([scene_path])

func create_instance():
	if scene_path == "":
		update_scene()
	
	var instance = load(scene_path).instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	instance.scene_file_path = scene_path
	add_child(instance)
	instance.owner = owner
	# owner.set_editable_instance(instance, true)
	instance.position = Vector2(30, 30)

func lines():
	return super.lines() + ([Lines.DashedLine.new(self, get_child(0), func (f): return "instances", "instances")] if get_child_count() > 0 else [])
