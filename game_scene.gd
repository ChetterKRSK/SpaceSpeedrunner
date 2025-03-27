extends Node2D


enum GAME_STATES{
	ON_PLANET,
	ON_ORBIT,
	ON_STAR_MAP
}
var GAME_STATE = GAME_STATES.ON_STAR_MAP

@export var planetPaths: Array[PathFollow2D]
@export var planetOrbitSpeed: Array[float]

@onready var mouseCursor: Sprite2D = $MouseCursor
@onready var mainCamera: Camera2D = $MainCamera

var cameraZoomLimit: Array[float] = [0.08, 2]
var cameraZoomStep: float = 1.5
var planetOrbitDistances: Array[float]
var lastSelectedOrbit = 0
var lastMousePosition: Vector2

#var tween: Tween

func _ready() -> void:
	#mainCamera.zoom = Vector2(1, 1)
	for path: PathFollow2D in planetPaths:
		path.progress_ratio = randf_range(0, 1)
		planetOrbitDistances.append(path.get_parent().curve.get_point_position(0).distance_to(Vector2()))
		
	for i in planetOrbitSpeed.size():
		var rndMinutes: float = randf_range(2, 8)
		planetOrbitSpeed[i] = (0.1/6) / rndMinutes # (0.1/6) - 60s
		planetOrbitSpeed[i] = -planetOrbitSpeed[i] if randi_range(0, 10) <= 1 else planetOrbitSpeed[i]

func _process(delta: float) -> void:
	for i in range(planetPaths.size()):
		planetPaths[i].progress_ratio += planetOrbitSpeed[i] * delta
	
	cameraMoving()

func _input(event) -> void:
	movingOrbitCursorOnMap(event)

func movingOrbitCursorOnMap(event):
	if event is InputEventMouseMotion:
		var angleMousePosition: float = (get_global_mouse_position() - Vector2()).angle()
		mouseCursor.position = Vector2(planetOrbitDistances[lastSelectedOrbit] * cos(angleMousePosition), planetOrbitDistances[lastSelectedOrbit] * sin(angleMousePosition))
		var mouseDistance = get_global_mouse_position().distance_to(Vector2())
		for distance: float in planetOrbitDistances:
			if mouseDistance - distance > -250 and mouseDistance - distance < 250:
				lastSelectedOrbit = planetOrbitDistances.find(distance)
	
func cameraMoving():
	if Input.is_action_just_pressed("Zoom_In_Map") or Input.is_action_pressed("Zoom_In_Map"):
		if mainCamera.zoom.x < cameraZoomLimit[1] / cameraZoomStep:
			var tween = get_tree().create_tween()
			tween.tween_property(mainCamera, "zoom", mainCamera.zoom * cameraZoomStep, 0.5)
		else:
			var tween = get_tree().create_tween()
			tween.tween_property(mainCamera, "zoom", Vector2(cameraZoomLimit[1], cameraZoomLimit[1]), 0.5)
	if Input.is_action_just_pressed("Zoom_Out_Map") or Input.is_action_pressed("Zoom_Out_Map"):
		if mainCamera.zoom.x > cameraZoomLimit[0] * cameraZoomStep:
			var tween = get_tree().create_tween()
			tween.tween_property(mainCamera, "zoom", mainCamera.zoom / cameraZoomStep, 0.5)
		else:
			var tween = get_tree().create_tween()
			tween.tween_property(mainCamera, "zoom", Vector2(cameraZoomLimit[0], cameraZoomLimit[0]), 0.5)

	if Input.is_action_just_pressed("Mouse_Left_Button"):
		lastMousePosition = get_global_mouse_position()
	if Input.is_action_pressed("Mouse_Left_Button"):
		mainCamera.position += lastMousePosition - get_global_mouse_position()
		if mainCamera.position.x < mainCamera.limit_left + (mainCamera.get_viewport_rect().size.x / 2) / mainCamera.zoom.x:
			mainCamera.position.x = mainCamera.limit_left + (mainCamera.get_viewport_rect().size.x / 2) / mainCamera.zoom.x
		if mainCamera.position.x > mainCamera.limit_right - (mainCamera.get_viewport_rect().size.x / 2) / mainCamera.zoom.x:
			mainCamera.position.x = mainCamera.limit_right - (mainCamera.get_viewport_rect().size.x / 2) / mainCamera.zoom.x
		if mainCamera.position.y < mainCamera.limit_top + (mainCamera.get_viewport_rect().size.y / 2) / mainCamera.zoom.y:
			mainCamera.position.y = mainCamera.limit_top + (mainCamera.get_viewport_rect().size.y / 2) / mainCamera.zoom.y
		if mainCamera.position.y > mainCamera.limit_bottom - (mainCamera.get_viewport_rect().size.y / 2) / mainCamera.zoom.y:
			mainCamera.position.y = mainCamera.limit_bottom - (mainCamera.get_viewport_rect().size.y / 2) / mainCamera.zoom.y
