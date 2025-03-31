extends StaticBody2D

@onready var mainCamera: Camera2D
@onready var infoWindow: Control = $UI/InfoWindow

@export var planetName: String

var endOfTurnSecond: float = 0
var infoWindowStandartPosition: Vector2
var isInfoWindowShow = false

func _ready() -> void:
	mainCamera = get_viewport().get_camera_2d()
	if infoWindow:
		infoWindowStandartPosition = infoWindow.position
		updateUI()

func _process(delta: float) -> void:
	if infoWindow:
		updateUI()
		if isInfoWindowShow:
			resizeUI()
	

func showInfoWindow():
	infoWindow.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(infoWindow, "scale", Vector2(1 / mainCamera.zoom.x, 1/ mainCamera.zoom.y), 0.25)
	isInfoWindowShow = true
	
func hideInfoWindow():
	isInfoWindowShow = false
	var tween = get_tree().create_tween()
	tween.tween_property(infoWindow, "scale", Vector2(), 0.25)
	await tween.finished
	infoWindow.visible = false

func resizeUI():
	var tween = get_tree().create_tween()
	tween.tween_property(infoWindow, "scale", Vector2(1 / mainCamera.zoom.x, 1/ mainCamera.zoom.y), 0.25)
	infoWindow.position = infoWindowStandartPosition
	if infoWindow.global_position.x < mainCamera.limit_left:
		infoWindow.position.x = infoWindowStandartPosition.x + mainCamera.limit_left - infoWindow.global_position.x
	if infoWindow.global_position.x + infoWindow.get_global_rect().size.x > mainCamera.limit_right:
		infoWindow.position.x = infoWindowStandartPosition.x - (infoWindow.global_position.x + infoWindow.get_global_rect().size.x - mainCamera.limit_right)
	if infoWindow.global_position.y < mainCamera.limit_top:
		infoWindow.position.y = infoWindowStandartPosition.y + mainCamera.limit_top - infoWindow.global_position.y
	if infoWindow.global_position.y + infoWindow.get_global_rect().size.y > mainCamera.limit_bottom:
		infoWindow.position.y = infoWindowStandartPosition.y - (infoWindow.global_position.y + infoWindow.get_global_rect().size.y - mainCamera.limit_bottom)

func updateUI():
	$UI/InfoWindow/VBoxContainer/PlanetName.text = "''%s''" % planetName
	
	var minutes = int(endOfTurnSecond / 60)
	var seconds = int(endOfTurnSecond) - (minutes * 60)
	var strTimer: String = str(minutes) if minutes >= 10 else "0" + str(minutes)
	strTimer += ":"
	strTimer += str(seconds) if seconds >= 10 else "0" + str(seconds)
	$UI/InfoWindow/VBoxContainer/TurnoverTime.text = "ОСТАЛОСЬ: %s" % [strTimer]
	
