extends Node2D

@onready var players := {
	"1": { 
		viewport = $LeftSubViewportContainer/SubViewport, 
		camera = $LeftSubViewportContainer/SubViewport/Camera2D, 
		player = $LeftSubViewportContainer/SubViewport/Level/Player1,
	},
	"2": {
		viewport = $RightSubViewportContainer/SubViewport, 
		camera = $RightSubViewportContainer/SubViewport/Camera2D, 
		player = $RightSubViewportContainer/SubViewport/Level2/Player2,
	}
}

# Called when the node enters the scene tree for the first time.
func _ready():

	for node in players.values():
		var remote_transform := RemoteTransform2D.new()
		remote_transform.remote_path = node.camera.get_path()
		node.player.add_child(remote_transform)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.	
func _process(delta):
	pass
