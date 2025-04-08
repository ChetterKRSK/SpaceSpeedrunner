extends Node2D

var GM: Node2D
var SM: StateMachine

var planet
var playerCharacter: CharacterBody2D
var cameraZoomLimit: Array[float] = [1, 0.08, 2, 0.08, 2] # standart, min, max, currentMin, currentMax
var cameraZoomStep: float = 1.15


func _ready() -> void:
	GM = get_node("/root/GameScene")
	planet = get_tree().get_nodes_in_group("planets")[0]
	playerCharacter = get_tree().get_nodes_in_group("playerCharacter")[0]

func open() -> void:
	cameraZoomLimit[4] = cameraZoomLimit[2] / planet.find_child("Sprite2D").scale.x
	cameraZoomLimit[3] = cameraZoomLimit[4] - 0.5
	
	zoomOnPlanet()
	
	for node in get_tree().get_nodes_in_group("on_planet_state_objects"):
		node.visible = true

func close() -> void:
	for node in get_tree().get_nodes_in_group("on_planet_state_objects"):
		node.visible = false

func process(delta: float) -> void:
	cameraMovingZoomingOnPlanet()

func physics_process(delta: float) -> void:
	pass

func input(event: InputEvent) -> void:
	toggleMap(event)


func cameraMovingZoomingOnPlanet():
	GM.mainCamera.position = planet.global_position
	
	if Input.is_action_just_pressed("Zoom_In_Map") or Input.is_action_pressed("Zoom_In_Map"):
		if GM.mainCamera.zoom.x < cameraZoomLimit[4] / cameraZoomStep:
			GM.mainCamera.zoom *= cameraZoomStep
		else:
			GM.mainCamera.zoom = Vector2(cameraZoomLimit[4], cameraZoomLimit[4])
			
	if Input.is_action_just_pressed("Zoom_Out_Map") or Input.is_action_pressed("Zoom_Out_Map"):
		if GM.mainCamera.zoom.x > cameraZoomLimit[3] * cameraZoomStep:
			GM.mainCamera.zoom /= cameraZoomStep
		else:
			GM.mainCamera.zoom = Vector2(cameraZoomLimit[3], cameraZoomLimit[3])

func zoomOnPlanet():
	if GM.mainCamera.zoom.x > cameraZoomLimit[4]:
		GM.mainCamera.zoom = Vector2(cameraZoomLimit[4], cameraZoomLimit[4])
	elif GM.mainCamera.zoom.x < cameraZoomLimit[3]:
		GM.mainCamera.zoom = Vector2(cameraZoomLimit[3], cameraZoomLimit[3])
	GM.mainCamera.position = planet.global_position

func toggleMap(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("Toggle_Map"):
			SM.change_state(SM.GAME_STATES_NAME[SM.GAME_STATES.ON_STAR_MAP])
