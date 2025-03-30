extends Node2D

signal change_game_state

enum GAME_STATES{
	ON_PLANET,
	ON_ORBIT,
	ON_STAR_MAP
}
var GAME_STATE = GAME_STATES.ON_PLANET:
	get():
		return GAME_STATE
	set(value):
		GAME_STATE = value
		change_game_state.emit(GAME_STATE)
		match GAME_STATE:
			GAME_STATES.ON_PLANET:
				zoomOnPlanet(playersPlanet)
				showUIOnPlanet()
			GAME_STATES.ON_ORBIT:
				pass
			GAME_STATES.ON_STAR_MAP:
				showUIOnMap()


@onready var mouseCursor: Sprite2D = $MouseCursor
@onready var mainCamera: Camera2D = $MainCamera

@export var planetOrbits: Array[Path2D]
@export var planetOrbitSpeed: Array[float]
@export var planetStartPosition: Array[float]

#region Общие переменные
var cameraZoomLimit: Array[float] = [1, 0.08, 2, 0.08, 2] # standart, min, max, currentMin, currentMax
var planetOrbitLineWidth: Array[float] = [3, 0, 0] # standart, min, max
var mouseCursorSize: Array[float] = [0.1, 0, 0] # standart, min, max
var player: CharacterBody2D
#endregion

#region Переменные для карты
var cameraZoomStep: float = 1.15
var selectedOrbit: float = 0
var isMouseOnOrbit: bool = false
var selectedPlanet
var isCursorOnPlanet: bool = false
#endregion

#region Переменные для планеты
var playersPlanet = 0
#endregion

#region temp переменные
var targetMousePlanet
var planetPaths: Array[PathFollow2D]
var planetOrbitDistances: Array[float]
var planets: Array[StaticBody2D]
var lastMousePosition: Vector2
#endregion


func _ready() -> void:
	setStandartValues()
	
	GAME_STATE = GAME_STATES.ON_PLANET
	flyToPlanet(playersPlanet)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		GAME_STATE+=1
		if GAME_STATE >= GAME_STATES.size():
			GAME_STATE = 0
	
	planetOrbitMoving(delta)
	
	match GAME_STATE:
		GAME_STATES.ON_PLANET:
			cameraMovingZoomingOnPlanet()
		GAME_STATES.ON_ORBIT:
			pass
		GAME_STATES.ON_STAR_MAP:
			selectingPlanetOnMap()
			cameraMovingZoomingOnMap()
			adjustingUI()

func _input(event) -> void:
	match GAME_STATE:
		GAME_STATES.ON_PLANET:
			pass
		GAME_STATES.ON_ORBIT:
			pass
		GAME_STATES.ON_STAR_MAP:
			movingOrbitCursorOnMap(event)

func setStandartValues():
	player = find_child("Player")
	change_game_state.connect(Callable(player, "_change_game_state"))
	
	for orbit in planetOrbits:
		planetPaths.append(orbit.find_child("PathFollow2D", false))
		planets.append(planetPaths[-1].get_child(0))
	
	for i in planetStartPosition.size():
		if planetStartPosition[i] == -99:
			planetStartPosition[i] = randf_range(0, 1)
			planetPaths[i].progress_ratio = planetStartPosition[i]
	
	for path: PathFollow2D in planetPaths:
		planetOrbitDistances.append(path.get_parent().curve.get_point_position(0).distance_to(Vector2()))
		
	for i in planetOrbitSpeed.size():
		if planetOrbitSpeed[i] == 0.0:
			var rndMinutes: float = randf_range(2, 8)
			planetOrbitSpeed[i] = (0.1/6) / rndMinutes # (0.1/6) - 60s
			planetOrbitSpeed[i] = -planetOrbitSpeed[i] if randi_range(0, 10) <= 1 else planetOrbitSpeed[i]

func movingOrbitCursorOnMap(event):
	if event is InputEventMouseMotion:
		var angleMousePosition: float = (get_global_mouse_position() - Vector2()).angle()
		var mouseDistance = get_global_mouse_position().distance_to(Vector2())
		for distance: float in planetOrbitDistances:
			if mouseDistance - planetOrbitDistances[0] < -10 / mainCamera.zoom.x:
				selectedOrbit = 0
				isMouseOnOrbit = false
				break
			elif mouseDistance - planetOrbitDistances[-1] > 10 / mainCamera.zoom.x:
				selectedOrbit = planetOrbitDistances.size() - 1
				isMouseOnOrbit = false
				break
			else:
				if mouseDistance - distance > -10 / mainCamera.zoom.x and mouseDistance - distance < 10 / mainCamera.zoom.x:
					selectedOrbit = planetOrbitDistances.find(distance)
					isMouseOnOrbit = true
					break
				else:
					isMouseOnOrbit = false
		mouseCursor.position = Vector2(planetOrbitDistances[selectedOrbit] * cos(angleMousePosition), planetOrbitDistances[selectedOrbit] * sin(angleMousePosition))

func selectingPlanetOnMap():
	if Input.is_action_just_pressed("Mouse_Left_Button"):
		if isCursorOnPlanet:
			if selectedPlanet != null and selectedPlanet != targetMousePlanet:
				planets[selectedPlanet].hideInfoWindow()
			selectedPlanet = targetMousePlanet
			cameraZoomLimit[4] = cameraZoomLimit[2] / planets[selectedPlanet].find_child("Sprite2D").scale.x
			changeCameraZoom()
			planets[targetMousePlanet].showInfoWindow()
		elif !isCursorOnPlanet and selectedPlanet != null:
			planets[selectedPlanet].hideInfoWindow()
			cameraZoomLimit[4] = cameraZoomLimit[2]
			selectedPlanet = null

func cameraMovingZoomingOnMap():
	if Input.is_action_just_pressed("Zoom_In_Map") or Input.is_action_pressed("Zoom_In_Map"):
		if mainCamera.zoom.x < cameraZoomLimit[4] / cameraZoomStep:
			var lastPos = get_global_mouse_position()
			mainCamera.zoom *= cameraZoomStep
			mainCamera.position += (lastPos - get_global_mouse_position())
		else:
			var lastPos = get_global_mouse_position()
			mainCamera.zoom = Vector2(cameraZoomLimit[4], cameraZoomLimit[4])
			mainCamera.position += (lastPos - get_global_mouse_position())
			
	if Input.is_action_just_pressed("Zoom_Out_Map") or Input.is_action_pressed("Zoom_Out_Map"):
		if mainCamera.zoom.x > cameraZoomLimit[1] * cameraZoomStep:
			var lastPos = get_global_mouse_position()
			mainCamera.zoom /= cameraZoomStep
			mainCamera.position += (lastPos - get_global_mouse_position())
		else:
			mainCamera.zoom = Vector2(cameraZoomLimit[1], cameraZoomLimit[1])
			mainCamera.position = Vector2(0, 0)
	
	if selectedPlanet != null:
		mainCamera.position = planetPaths[selectedPlanet].position
	if Input.is_action_just_pressed("Drag_Map"):
		lastMousePosition = get_global_mouse_position()
	if Input.is_action_pressed("Drag_Map"):
		if selectedPlanet != null:
			planets[targetMousePlanet].hideInfoWindow()
			cameraZoomLimit[4] = cameraZoomLimit[2]
			selectedPlanet = null
		mainCamera.position += lastMousePosition - get_global_mouse_position()
		if mainCamera.position.x < mainCamera.limit_left + (mainCamera.get_viewport_rect().size.x / 2) / mainCamera.zoom.x:
			mainCamera.position.x = mainCamera.limit_left + (mainCamera.get_viewport_rect().size.x / 2) / mainCamera.zoom.x
		if mainCamera.position.x > mainCamera.limit_right - (mainCamera.get_viewport_rect().size.x / 2) / mainCamera.zoom.x:
			mainCamera.position.x = mainCamera.limit_right - (mainCamera.get_viewport_rect().size.x / 2) / mainCamera.zoom.x
		if mainCamera.position.y < mainCamera.limit_top + (mainCamera.get_viewport_rect().size.y / 2) / mainCamera.zoom.y:
			mainCamera.position.y = mainCamera.limit_top + (mainCamera.get_viewport_rect().size.y / 2) / mainCamera.zoom.y
		if mainCamera.position.y > mainCamera.limit_bottom - (mainCamera.get_viewport_rect().size.y / 2) / mainCamera.zoom.y:
			mainCamera.position.y = mainCamera.limit_bottom - (mainCamera.get_viewport_rect().size.y / 2) / mainCamera.zoom.y

func cameraMovingZoomingOnPlanet():
	mainCamera.position = planetPaths[playersPlanet].position
	
	if Input.is_action_just_pressed("Zoom_In_Map") or Input.is_action_pressed("Zoom_In_Map"):
		if mainCamera.zoom.x < cameraZoomLimit[4] / cameraZoomStep:
			mainCamera.zoom *= cameraZoomStep
		else:
			mainCamera.zoom = Vector2(cameraZoomLimit[4], cameraZoomLimit[4])
			
	if Input.is_action_just_pressed("Zoom_Out_Map") or Input.is_action_pressed("Zoom_Out_Map"):
		if mainCamera.zoom.x > cameraZoomLimit[3] * cameraZoomStep:
			mainCamera.zoom /= cameraZoomStep
		else:
			mainCamera.zoom = Vector2(cameraZoomLimit[3], cameraZoomLimit[3])

func changeCameraZoom():
	if mainCamera.zoom.x > cameraZoomLimit[4]:
		mainCamera.zoom = Vector2(cameraZoomLimit[4], cameraZoomLimit[4])
	elif mainCamera.zoom.x < cameraZoomLimit[3]:
		mainCamera.zoom = Vector2(cameraZoomLimit[3], cameraZoomLimit[3])

func adjustingUI():
	var newMouseCursorScale = mouseCursorSize[0] / mainCamera.zoom.x
	mouseCursor.scale = Vector2(newMouseCursorScale, newMouseCursorScale)
	var newPlanetOrbitLineWidth = planetOrbitLineWidth[0] / mainCamera.zoom.x
	for orbit in planetOrbits:
		orbit.line_width = newPlanetOrbitLineWidth
		orbit.updateButtonEvent()

func planetOrbitMoving(delta: float):
	for i in range(planetPaths.size()):
		planetPaths[i].progress_ratio += planetOrbitSpeed[i] * delta
		if planetOrbitSpeed[i] > 0:
			var minutes = (0.1/6) / planetOrbitSpeed[i]
			var seconds = minutes * 60
			planets[i].endOfTurnSecond = seconds * (1 - planetPaths[i].progress_ratio)
		else:
			var minutes = (0.1/6) / -planetOrbitSpeed[i]
			var seconds = minutes * 60
			planets[i].endOfTurnSecond = seconds * planetPaths[i].progress_ratio

func zoomOnPlanet(planetIndex):
	mainCamera.zoom = Vector2(cameraZoomLimit[4], cameraZoomLimit[4])
	mainCamera.position = planets[planetIndex].global_position

func flyToPlanet(planetIndex):
	cameraZoomLimit[3] = cameraZoomLimit[2] - 0.5
	cameraZoomLimit[4] = cameraZoomLimit[2] / planets[planetIndex].find_child("Sprite2D").scale.x

func hideAllUI():
	mouseCursor.visible = false
	player.visible = false
	
	for orbit in planetOrbits:
		orbit.line.visible = false
	for planet in planets:
		planet.find_child("UI").visible = false

func showUIOnPlanet():
	hideAllUI()
	
	player.visible = true

func showUIOnMap():
	hideAllUI()
	
	for orbit in planetOrbits:
		orbit.line.visible = true
	mouseCursor.visible = true
	for planet in planets:
		planet.find_child("UI").visible = true


func _on_planet_mouse_entered(extra_arg_0: int) -> void:
	isCursorOnPlanet = true
	targetMousePlanet = extra_arg_0

func _on_planet_mouse_exited() -> void:
	isCursorOnPlanet = false
