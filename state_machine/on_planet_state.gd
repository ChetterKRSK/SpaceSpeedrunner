extends Node2D

var fsm: StateMachine

@onready var GM: Node2D = $"../.."

var planet
var cameraZoomLimit: Array[float] = [1, 0.08, 2] # standart, min, max
var cameraZoomStep: float = 1.15

func _ready() -> void:
	planet = $"../../MainObjectsSystem/PlanetOrbit3/PathFollow2D/Planet3"


func process(delta: float) -> void:
	cameraMovingZoomingOnPlanet()
	
func input(event: InputEvent) -> void:
	pass

func cameraMovingZoomingOnPlanet():
	GM.mainCamera.position = planet.global_position
	
	if Input.is_action_just_pressed("Zoom_In_Map") or Input.is_action_pressed("Zoom_In_Map"):
		if GM.mainCamera.zoom.x < cameraZoomLimit[2] / cameraZoomStep:
			GM.mainCamera.zoom *= cameraZoomStep
		else:
			GM.mainCamera.zoom = Vector2(cameraZoomLimit[2], cameraZoomLimit[2])
			
	if Input.is_action_just_pressed("Zoom_Out_Map") or Input.is_action_pressed("Zoom_Out_Map"):
		if GM.mainCamera.zoom.x > cameraZoomLimit[1] * cameraZoomStep:
			GM.mainCamera.zoom /= cameraZoomStep
		else:
			GM.mainCamera.zoom = Vector2(cameraZoomLimit[1], cameraZoomLimit[1])
