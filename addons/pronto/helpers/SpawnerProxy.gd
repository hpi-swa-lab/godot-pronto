extends Node2D

var spawner

func spawn(indices = [], pos = Vector2.INF, toward = Vector2.INF, use_shape = false):
	spawner.spawn(indices, pos, toward, use_shape)
