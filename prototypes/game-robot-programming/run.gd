extends Button


func execute_area(area_to_run: Area2D, robot):
	var areas = area_to_run.get_node("Code").get_stmts()
	var executed = []
	print(robot, area_to_run, areas)
	
	for area in areas:
		await area_to_run.get_tree().create_timer(0.2).timeout
		robot.get_node("Laser/LaserShape").visible = false
		
		if area in executed:
			continue
		
		var stmt = area.get_node("Code").get_code()
		if stmt == "main":
			print("main")
		elif stmt == "forward":
			print("forward")
			executed.append(area)
			
			if len(robot.get_node("FrontFree").get_overlapping_bodies()) > 0:
				continue
			
			if robot.orientation == 0:
				robot.position.x += 64
			elif robot.orientation == 1:
				robot.position.y -= 64
			elif robot.orientation == 2:
				robot.position.x -= 64
			elif robot.orientation == 3:
				robot.position.y += 64
			
		elif stmt == "rotate-left":
			print("rotate left")
			executed.append(area)
			robot.rotation_degrees -= 90
			robot.orientation = (robot.orientation + 1) % 4
		elif stmt == "rotate-right":
			print("rotate right")
			executed.append(area)
			robot.rotation_degrees += 90
			robot.orientation = ((robot.orientation - 1) + 4) % 4
		elif stmt == "while":
			print("loop")
			
			if len(area.get_node("Code").get_stmts()) == 0:
				print("No blocks inside container")
				continue
			
			var condition = area.get_node("Code").get_stmts()[0]
			if not condition.get_node("Code").is_condition():
				print("No conditions inside container")
				continue
				
			while condition.get_node("Code").check(robot):
				print("Condition passed!")
				await execute_area(area, robot)
			
			executed.append_array(area.get_node("Code").get_stmts())
		elif stmt == "if":
			print("if")
			
			if len(area.get_node("Code").get_stmts()) == 0:
				print("No blocks inside container")
				continue
			
			var condition = area.get_node("Code").get_stmts()[0]
			if not condition.get_node("Code").is_condition():
				print("No conditions inside container")
				continue
			
			if condition.get_node("Code").check(robot):
				print("if is true")
				execute_area(area, robot)
			print(executed)
			executed.append_array(area.get_node("Code").get_stmts())
			print(executed)
		
		elif stmt == "laser":
			print("laser")
			executed.append(area)
			
			robot.get_node("Laser/LaserShape").visible = true
			
			var bodies = robot.get_node("Laser").get_overlapping_bodies()
			for body in bodies:
				if !body.is_in_group("Robot"):
					continue
				if body == robot:
					continue
				
				body.get_node("HP").damage(1)
		
		elif stmt == "punch":
			print("punch")
			executed.append(area)
			
			var bodies = robot.get_node("FrontFree").get_overlapping_bodies()
			for body in bodies:
				if !body.is_in_group("Robot"):
					continue
				if body == robot:
					continue
				
				body.get_node("HP").damage(1)
		
	return executed
