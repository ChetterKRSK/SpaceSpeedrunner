extends StaticBody2D

@onready var main_camera: Camera2D
@onready var info_window: Control = $UI/InfoWindow

@export var planetName: String

var endOfTurnSecond: float = 0

func _ready() -> void:
	main_camera = get_viewport().get_camera_2d()
	if info_window:
		updateUI()

func _process(delta: float) -> void:
	if info_window:
		updateUI()
		resizeUI()
	

func showInfoWindow():
	info_window.visible = true
	
func hideInfoWindow():
	info_window.visible = false

func resizeUI():
	info_window.scale = Vector2(1 / main_camera.zoom.x, 1/ main_camera.zoom.y)

func updateUI():
	$UI/InfoWindow/VBoxContainer/PlanetName.text = "''%s''" % planetName
	
	var minutes = int(endOfTurnSecond / 60)
	var seconds = int(endOfTurnSecond) - (minutes * 60)
	var strTimer: String = str(minutes) if minutes >= 10 else "0" + str(minutes)
	strTimer += ":"
	strTimer += str(seconds) if seconds >= 10 else "0" + str(seconds)
	$UI/InfoWindow/VBoxContainer/TurnoverTime.text = "ОСТАЛОСЬ: %s" % [strTimer]
	
