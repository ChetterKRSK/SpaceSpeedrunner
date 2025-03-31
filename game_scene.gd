extends Node2D

signal change_game_state

enum GAME_STATES{
	ON_PLANET,
	ON_ORBIT,
	ON_STAR_MAP
}
var GAME_STATE:
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

@onready var SM: StateMachine = $StateMachine

@onready var mouseCursor: Sprite2D = $MouseCursor
@onready var mainCamera: Camera2D = $MainCamera

@export var planetOrbits: Array[Path2D]
@export var planetOrbitSpeed: Array[float]
@export var planetStartPosition: Array[float]

#region Общие переменные
var cameraZoomLimit: Array[float] = [1, 0.08, 2, 0.08, 2] # standart, min, max, currentMin, currentMax
var player: CharacterBody2D
#endregion

#region Переменные для карты
var cameraZoomStep: float = 1.15
#endregion

#region Переменные для планеты
var playersPlanet = 0
#endregion

#region temp переменные
var planetPaths: Array[PathFollow2D]
var planetOrbitDistances: Array[float]
var planets: Array[StaticBody2D]
#endregion


func _ready() -> void:
	SM.set_state(SM.GAME_STATES_NAME[SM.GAME_STATES.ON_STAR_MAP])
	setStandartValues()

func _process(delta: float) -> void:	
	planetOrbitMoving(delta)

func _input(event) -> void:
	pass

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
