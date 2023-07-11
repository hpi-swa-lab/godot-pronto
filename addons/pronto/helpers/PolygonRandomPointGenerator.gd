# adapted from https://www.reddit.com/r/godot/comments/mqp29g/comment/hddil1b/
class_name PolygonRandomPointGenerator

var _polygon: PackedVector2Array
var _triangles: PackedInt32Array
var _cumulated_triangle_areas: Array

var _rand: RandomNumberGenerator

func _init(polygon: PackedVector2Array) -> void:
	_polygon = polygon
	_triangles = Geometry2D.triangulate_polygon(_polygon)	
	_rand = RandomNumberGenerator.new()
	
	var triangle_count: int = _triangles.size() / 3
	assert(triangle_count > 0)
	_cumulated_triangle_areas.resize(triangle_count)
	_cumulated_triangle_areas[-1] = 0
	for i in range(triangle_count):
		var a: Vector2 = _polygon[_triangles[3 * i + 0]]
		var b: Vector2 = _polygon[_triangles[3 * i + 1]]
		var c: Vector2 = _polygon[_triangles[3 * i + 2]]
		_cumulated_triangle_areas[i] = _cumulated_triangle_areas[i - 1] + triangle_area(a, b, c)

func get_random_point() -> Vector2:
	var total_area: float = _cumulated_triangle_areas[-1]
	var choosen_triangle_index: int = _cumulated_triangle_areas.bsearch(_rand.randf() * total_area)
	var a: Vector2 = _polygon[_triangles[3 * choosen_triangle_index + 0]]
	var b: Vector2 = _polygon[_triangles[3 * choosen_triangle_index + 1]]
	var c: Vector2 = _polygon[_triangles[3 * choosen_triangle_index + 2]]
	return random_triangle_point(a, b, c)

static func triangle_area(a: Vector2, b: Vector2, c: Vector2) -> float:
	return 0.5 * abs((c.x - a.x) * (b.y - a.y) - (b.x - a.x) * (c.y - a.y))

static func random_triangle_point(a: Vector2, b: Vector2, c: Vector2) -> Vector2:
	return a + sqrt(randf()) * (-a + b + randf() * (c - b))
