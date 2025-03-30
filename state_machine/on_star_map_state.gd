extends Node2D

var fsm: StateMachine

@onready var GM: Node2D = $"../.."
@onready var mouseCursor: Sprite2D = $"../../MouseCursor"

#region Общие переменные
var cameraZoomLimit: Array[float] = [1, 0.08, 2, 0.08, 2] # standart, min, max, currentMin, currentMax
var planetOrbitStandartLineWidth: float = 3
var mouseCursorStandartSize: float = 0.1
#endregion

#region Переменные для карты
var cameraZoomStep: float = 1.15
var selectedOrbit: float = 0
var isMouseOnOrbit: bool = false
var selectedPlanet
var isCursorOnPlanet: bool = false
#endregion

#region temp переменные
var targetMousePlanet
var lastMousePosition: Vector2
#endregion

func _ready() -> void:
	print("2")
	pass

func process(delta: float) -> void:
	selectingPlanetOnMap()
	cameraMovingZoomingOnMap()
	adjustingUI()

func input(event: InputEvent) -> void:
	movingOrbitCursorOnMap(event)
	

func selectingPlanetOnMap():
	if Input.is_action_just_pressed("Mouse_Left_Button"):
		if isCursorOnPlanet:
			if selectedPlanet != null and selectedPlanet != targetMousePlanet:
				GM.planets[selectedPlanet].hideInfoWindow()
			selectedPlanet = targetMousePlanet
			cameraZoomLimit[4] = cameraZoomLimit[2] / GM.planets[selectedPlanet].find_child("Sprite2D").scale.x
			changeCameraZoom()
			GM.planets[targetMousePlanet].showInfoWindow()
		elif !isCursorOnPlanet and selectedPlanet != null:
			GM.planets[selectedPlanet].hideInfoWindow()
			cameraZoomLimit[4] = cameraZoomLimit[2]
			selectedPlanet = null

func cameraMovingZoomingOnMap():
	if Input.is_action_just_pressed("Zoom_In_Map") or Input.is_action_pressed("Zoom_In_Map"):
		if GM.mainCamera.zoom.x < cameraZoomLimit[4] / cameraZoomStep:
			var lastPos = get_global_mouse_position()
			GM.mainCamera.zoom *= cameraZoomStep
			GM.mainCamera.position += (lastPos - get_global_mouse_position())
		else:
			var lastPos = get_global_mouse_position()
			GM.mainCamera.zoom = Vector2(cameraZoomLimit[4], cameraZoomLimit[4])
			GM.mainCamera.position += (lastPos - get_global_mouse_position())
			
	if Input.is_action_just_pressed("Zoom_Out_Map") or Input.is_action_pressed("Zoom_Out_Map"):
		if GM.mainCamera.zoom.x > cameraZoomLimit[1] * cameraZoomStep:
			var lastPos = get_global_mouse_position()
			GM.mainCamera.zoom /= cameraZoomStep
			GM.mainCamera.position += (lastPos - get_global_mouse_position())
		else:
			GM.mainCamera.zoom = Vector2(cameraZoomLimit[1], cameraZoomLimit[1])
			GM.mainCamera.position = Vector2(0, 0)
	
	if selectedPlanet != null:
		GM.mainCamera.position = GM.planetPaths[selectedPlanet].position
	if Input.is_action_just_pressed("Drag_Map"):
		lastMousePosition = get_global_mouse_position()
	if Input.is_action_pressed("Drag_Map"):
		if selectedPlanet != null:
			GM.planets[targetMousePlanet].hideInfoWindow()
			cameraZoomLimit[4] = cameraZoomLimit[2]
			selectedPlanet = null
		GM.mainCamera.position += lastMousePosition - get_global_mouse_position()
		if GM.mainCamera.position.x < GM.mainCamera.limit_left + (GM.mainCamera.get_viewport_rect().size.x / 2) / GM.mainCamera.zoom.x:
			GM.mainCamera.position.x = GM.mainCamera.limit_left + (GM.mainCamera.get_viewport_rect().size.x / 2) / GM.mainCamera.zoom.x
		if GM.mainCamera.position.x > GM.mainCamera.limit_right - (GM.mainCamera.get_viewport_rect().size.x / 2) / GM.mainCamera.zoom.x:
			GM.mainCamera.position.x = GM.mainCamera.limit_right - (GM.mainCamera.get_viewport_rect().size.x / 2) / GM.mainCamera.zoom.x
		if GM.mainCamera.position.y < GM.mainCamera.limit_top + (GM.mainCamera.get_viewport_rect().size.y / 2) / GM.mainCamera.zoom.y:
			GM.mainCamera.position.y = GM.mainCamera.limit_top + (GM.mainCamera.get_viewport_rect().size.y / 2) / GM.mainCamera.zoom.y
		if GM.mainCamera.position.y > GM.mainCamera.limit_bottom - (GM.mainCamera.get_viewport_rect().size.y / 2) / GM.mainCamera.zoom.y:
			GM.mainCamera.position.y = GM.mainCamera.limit_bottom - (GM.mainCamera.get_viewport_rect().size.y / 2) / GM.mainCamera.zoom.y
			
func changeCameraZoom():
	if GM.mainCamera.zoom.x > cameraZoomLimit[4]:
		GM.mainCamera.zoom = Vector2(cameraZoomLimit[4], cameraZoomLimit[4])
	elif GM.mainCamera.zoom.x < cameraZoomLimit[3]:
		GM.mainCamera.zoom = Vector2(cameraZoomLimit[3], cameraZoomLimit[3])
		
func adjustingUI():
	var newMouseCursorScale = mouseCursorStandartSize / GM.mainCamera.zoom.x
	mouseCursor.scale = Vector2(newMouseCursorScale, newMouseCursorScale)
	var newPlanetOrbitLineWidth = planetOrbitStandartLineWidth / GM.mainCamera.zoom.x
	for orbit in GM.planetOrbits:
		orbit.line_width = newPlanetOrbitLineWidth
		orbit.updateButtonEvent()
		
func movingOrbitCursorOnMap(event):
	if event is InputEventMouseMotion:
		var angleMousePosition: float = (get_global_mouse_position() - Vector2()).angle()
		var mouseDistance = get_global_mouse_position().distance_to(Vector2())
		for distance: float in GM.planetOrbitDistances:
			if mouseDistance - GM.planetOrbitDistances[0] < -10 / GM.mainCamera.zoom.x:
				selectedOrbit = 0
				isMouseOnOrbit = false
				break
			elif mouseDistance - GM.planetOrbitDistances[-1] > 10 / GM.mainCamera.zoom.x:
				selectedOrbit = GM.planetOrbitDistances.size() - 1
				isMouseOnOrbit = false
				break
			else:
				if mouseDistance - distance > -10 / GM.mainCamera.zoom.x and mouseDistance - distance < 10 / GM.mainCamera.zoom.x:
					selectedOrbit = GM.planetOrbitDistances.find(distance)
					isMouseOnOrbit = true
					break
				else:
					isMouseOnOrbit = false
		mouseCursor.position.x = GM.planetOrbitDistances[selectedOrbit] * cos(angleMousePosition)
		mouseCursor.position.y = GM.planetOrbitDistances[selectedOrbit] * sin(angleMousePosition)


func _on_planet_mouse_entered(extra_arg_0: int) -> void:
	isCursorOnPlanet = true
	targetMousePlanet = extra_arg_0

func _on_planet_mouse_exited() -> void:
	isCursorOnPlanet = false
