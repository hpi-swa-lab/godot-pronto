extends CharacterBody2D

@export var movement_speed: float = 50.0
@export var carrying_movement_speed: float = 25.0

@export var target: Node2D
@export var navigation_agent: NavigationAgent2D
@export var base: Node2D

var tile_size = 16
var idle_distance = tile_size * 3
var timeout_between_idle_actions = 2

var state = "IDLE"
var food_carried = 0

# could we have built a state machine with pronto?

# WARNING: NavigationRegion2D has a huge issue atm
#          it doesn't take the actor's size into account
#          https://github.com/godotengine/godot/issues/60546
#          https://github.com/godotengine/godot/pull/70724
# For tilesets we can sort of fix this with: https://github.com/godotengine/godot/issues/60546
# (see the workaround posted by the user "timothyqiu")

# todo: re-evaluate path of tileset update of agent doesn't do this automatically (not tested yet)
# todo: figure out what we want to actually test/prototype incl. user tests

func _ready():
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0
	# we need to call_deferred as physics_server is syncing on first frame!
	call_deferred("actor_setup")
	
func actor_setup():
	await get_tree().physics_frame
	# setting target based on initial state
	evaluate_state()
		
		
func evaluate_state():
	print("Evaluating Postion")
	if state == "GATHERING_FOOD":
		# find nearest food and collect
		set_movement_target(target.global_position)
	elif state == "RETURNING_TO_BASE":
		print("Returning to base")
		# return home
		set_movement_target(base.global_position)	
	elif state == "IDLE":
		# idle
		navigation_agent.target_position = self.global_position
		# check for food in range
		#if G.at("detectedFood"):
		#	target = G.at("detectedFood")
		#	state = "GATHERING_FOOD"
		#	#G.put("AntState", "GATHERING_FOOD")
		#	G.put("detectedFood", null) 
		
		if randi_range(0, 10) < 6:
			# randomly select if we want to move half of the time
			var rand_direction = Vector2(randf_range(-idle_distance, idle_distance),randf_range(-idle_distance, idle_distance))
			set_movement_target(global_position + rand_direction)
		
		# warning: the following await will trigger independent of movement completion
		# e.g. if next target takes longer than timeout_between_idle_actions to reach,
		# a new idle command might be issued
		await get_tree().create_timer(timeout_between_idle_actions).timeout
		evaluate_state() 
			
	else:
		push_error("Ant " + str(self.name) + " has an invalid state: " + G.at("AntState"))	
	
func set_movement_target(target_position: Vector2):
	navigation_agent.target_position = target_position
	
func _physics_process(delta):
	
	# we could induce a timeout here after reaching next_path_position
	# this would simulate e.g. moving one tile every second
	
	if navigation_agent.is_navigation_finished():
		# early return in case of reaching target or obstructed path
		# return to idle here if allowed ?
		return
	
	var current_agent_position: Vector2 = global_position
	var next_path_pos: Vector2 = navigation_agent.get_next_path_position()
	
	var new_velocity: Vector2 = next_path_pos - current_agent_position
	new_velocity = new_velocity.normalized()
	if food_carried != 0:
		# reduce movement speed when carrying food
		new_velocity = new_velocity * carrying_movement_speed/food_carried
	else:
		new_velocity = new_velocity * movement_speed
	velocity = new_velocity
	move_and_slide()
	look_at(next_path_pos)
	
func on_food_collected():
	print("on_food_collected")
	food_carried = food_carried + 1
	state = "RETURNING_TO_BASE"
	evaluate_state()
	
func on_food_removed():
	print("on_food_removed")
	food_carried = 0
	state = "IDLE"
	evaluate_state()
	
func on_food_detected(food: Node2D):
	if(food_carried <= 1):
		if(state == "GATHERING_FOOD" and position.distance_to(food.position) > position.distance_to(navigation_agent.target_position)):
			return
		target = food
		state = "GATHERING_FOOD"
		evaluate_state()

	
