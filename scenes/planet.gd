extends StaticBody2D

@onready var camera: Camera2D = $PlanetCamera

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("mouse_whell_up"):
		if camera.zoom.x < 3:
			camera.zoom += Vector2(0.1, 0.1)
		else:
			camera.zoom = Vector2(3, 3)
	if Input.is_action_just_pressed("mouse_whell_down"):
		if camera.zoom.x > 0.1:
			camera.zoom -= Vector2(0.1, 0.1)
		else:
			camera.zoom = Vector2(0.1, 0.1)
