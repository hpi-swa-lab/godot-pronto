extends CharacterBody2D

@export var movement_speed: float = 200.0

@export var target: Node2D
@export var navigation_agent: NavigationAgent2D

# WARNING: NavigationRegion2D has a huge issue atm
#          it doesn't take the actor's size into account
# https://github.com/godotengine/godot/issues/60546
# https://github.com/godotengine/godot/pull/70724


func _ready():
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0
	call_deferred("actor_setup")
	
func actor_setup():
	await get_tree().physics_frame
#	print("This: " + str(self.global_position) + " | Target: " + str(target.global_position))
	set_movement_target(target.global_position)
	
func set_movement_target(target_position: Vector2):
	navigation_agent.target_position = target_position
	
func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		print("Target reached")
		return
	
	var current_agent_position: Vector2 = global_position
	var next_path_pos: Vector2 = navigation_agent.get_next_path_position()
	
	var new_velocity: Vector2 = next_path_pos - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * movement_speed
	
	velocity = new_velocity
	move_and_slide()
	look_at(next_path_pos)		
