extends Node2D

@onready var mouseCursor: Sprite2D = $"../../MouseCursor"

var GM: Node2D
var SM: StateMachine

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
	GM = get_node("/root/GameScene")

func open() -> void:
	for node in get_tree().get_nodes_in_group("on_star_map_state_objects"):
		node.visible = true

func close() -> void:
	for node in get_tree().get_nodes_in_group("on_star_map_state_objects"):
		node.visible = false

func process(delta: float) -> void:
	selectingPlanetOnMap()
	cameraMovingZoomingOnMap()
	adjustingUI()

func physics_process(delta: float) -> void:
	pass
	
func input(event: InputEvent) -> void:
	movingOrbitCursorOnMap(event)
	toggleMap(event)


func selectingPlanetOnMap():
	if Input.is_action_just_pressed("Mouse_Left_Button"):
		if isCursorOnPlanet:
			if selectedPlanet != null and selectedPlanet != targetMousePlanet:
				get_tree().get_nodes_in_group("planets")[selectedPlanet].hideInfoWindow()
			selectedPlanet = targetMousePlanet
			cameraZoomLimit[4] = cameraZoomLimit[2] / get_tree().get_nodes_in_group("planets")[selectedPlanet].find_child("Sprite2D").scale.x
			changeCameraZoom()
			get_tree().get_nodes_in_group("planets")[targetMousePlanet].showInfoWindow()
		elif !isCursorOnPlanet and selectedPlanet != null:
			get_tree().get_nodes_in_group("planets")[selectedPlanet].hideInfoWindow()
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
		if GM.mainCamera.zoom.x > cameraZoomLimit[3] * cameraZoomStep:
			var lastPos = get_global_mouse_position()
			GM.mainCamera.zoom /= cameraZoomStep
			GM.mainCamera.position += (lastPos - get_global_mouse_position())
		else:
			GM.mainCamera.zoom = Vector2(cameraZoomLimit[3], cameraZoomLimit[3])
			GM.mainCamera.position = Vector2(0, 0)

	if selectedPlanet != null:
		GM.mainCamera.position = get_tree().get_nodes_in_group("planetPathFollows")[selectedPlanet].position
	if Input.is_action_just_pressed("Drag_Map"):
		lastMousePosition = get_global_mouse_position()
	if Input.is_action_pressed("Drag_Map"):
		if selectedPlanet != null:
			get_tree().get_nodes_in_group("planets")[targetMousePlanet].hideInfoWindow()
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
	for orbit in get_tree().get_nodes_in_group("planetOrbits"):
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

func toggleMap(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("Toggle_Map"):
			SM.change_to_previous_state()

func _on_planet_mouse_entered(extra_arg_0: int) -> void:
	isCursorOnPlanet = true
	targetMousePlanet = extra_arg_0

func _on_planet_mouse_exited() -> void:
	isCursorOnPlanet = false
