extends Node2D

@export var planetPaths: Array[PathFollow2D]
@export var planetOrbitSpeed: Array[float]

@onready var a: PathFollow2D = $Planet1_Orbit/PathFollow2D
@onready var mouseCursor: Sprite2D = $MouseCursor

var planetOrbitDistances: Array[float]
var lastSelectedOrbit = 0

func _ready() -> void:
	for path: PathFollow2D in planetPaths:
		#path.progress_ratio = randf_range(0, 1)
		planetOrbitDistances.append(path.get_parent().curve.get_point_position(0).distance_to(Vector2()))
		
	for i in planetOrbitSpeed.size():
		#planetOrbitSpeed[i] = randf_range(0.005, 0.01)
		planetOrbitSpeed[i] = (0.1/6) # | 0.005 - 200s | 0.01 - 100s | 0.02 - 50s | 0.1 - 10s | (0.1/6) - 60s |
		#planetOrbitSpeed[i] = -planetOrbitSpeed[i] if randi_range(0, 1) == 0 else planetOrbitSpeed[i]

func _process(delta: float) -> void:
	for i in range(planetPaths.size()):
		planetPaths[i].progress_ratio += planetOrbitSpeed[i] * delta

func _input(event) -> void:
	if event is InputEventMouseMotion:
		var angleMousePosition: float = (get_global_mouse_position() - Vector2()).angle()
		mouseCursor.position = Vector2(planetOrbitDistances[lastSelectedOrbit] * cos(angleMousePosition), planetOrbitDistances[lastSelectedOrbit] * sin(angleMousePosition))
		var mouseDistance = get_global_mouse_position().distance_to(Vector2())
		for distance: float in planetOrbitDistances:
			if mouseDistance - distance > -250 and mouseDistance - distance < 250:
				lastSelectedOrbit = planetOrbitDistances.find(distance)
