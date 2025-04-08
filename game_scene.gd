extends Node2D

@onready var SM: StateMachine = $StateMachine
@onready var mouseCursor: Sprite2D = $MouseCursor
@onready var mainCamera: Camera2D

@export var planetOrbitSpeed: Array[float]
@export var planetStartPosition: Array[float]

#region Общие переменные
var cameraZoomLimit: Array[float] = [1, 0.08, 2, 0.08, 2] # standart, min, max, currentMin, currentMax
var player: CharacterBody2D
#endregion

#region temp переменные
var planetOrbitDistances: Array[float]
#endregion


func _ready() -> void:
	mainCamera = get_viewport().get_camera_2d()
	SM.set_state(SM.GAME_STATES_NAME[SM.GAME_STATES.ON_PLANET])
	
	setStandartValues()

func _process(delta: float) -> void:
	planetOrbitMoving(delta)

func _input(event) -> void:
	pass


func setStandartValues():
	for i in planetStartPosition.size():
		if planetStartPosition[i] == -9:
			planetStartPosition[i] = randf_range(0, 1)
			get_tree().get_nodes_in_group("planetPathFollows")[i].progress_ratio = planetStartPosition[i]
	
	for path: PathFollow2D in get_tree().get_nodes_in_group("planetPathFollows"):
		planetOrbitDistances.append(path.get_parent().curve.get_point_position(0).distance_to(Vector2()))
		
	for i in planetOrbitSpeed.size():
		if planetOrbitSpeed[i] == 0.0:
			var rndMinutes: float = randf_range(2, 8)
			planetOrbitSpeed[i] = (0.1/6) / rndMinutes # (0.1/6) - 60s
			planetOrbitSpeed[i] = -planetOrbitSpeed[i] if randi_range(0, 10) <= 1 else planetOrbitSpeed[i]

func planetOrbitMoving(delta: float):
	for i in range(get_tree().get_nodes_in_group("planetPathFollows").size()):
		get_tree().get_nodes_in_group("planetPathFollows")[i].progress_ratio += planetOrbitSpeed[i] * delta
		if planetOrbitSpeed[i] > 0:
			var minutes = (0.1/6) / planetOrbitSpeed[i]
			var seconds = minutes * 60
			get_tree().get_nodes_in_group("planets")[i].endOfTurnSecond = seconds * (1 - get_tree().get_nodes_in_group("planetPathFollows")[i].progress_ratio)
		else:
			var minutes = (0.1/6) / -planetOrbitSpeed[i]
			var seconds = minutes * 60
			get_tree().get_nodes_in_group("planets")[i].endOfTurnSecond = seconds * get_tree().get_nodes_in_group("planetPathFollows")[i].progress_ratio
