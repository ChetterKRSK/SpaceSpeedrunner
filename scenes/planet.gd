extends StaticBody2D

@onready var camera: Camera2D = $"../PlanetCamera"
@onready var player: CharacterBody2D = $"../Player"


func _process(delta: float) -> void:
	#camera.rotation = player.rotation
	if Input.is_action_just_pressed("mouse_whell_up"):
		if camera.zoom.x < 4:
			camera.zoom += Vector2(0.1, 0.1)
	if Input.is_action_just_pressed("mouse_whell_down"):
		if camera.zoom.x > 0.2:
			camera.zoom -= Vector2(0.1, 0.1)
