extends RigidBody2D
#
#@onready var camera_2d: Camera2D = $"../Camera2D"
#@onready var planet: StaticBody2D = $"../Planet"
#@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
#
#var is_on_planet: bool = false
#
#func _ready() -> void:
	#contact_monitor = true
#
#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("mouse_whell_up"):
		#camera_2d.zoom += Vector2(0.5, 0.5)
	#if Input.is_action_just_pressed("mouse_whell_down"):
		#camera_2d.zoom -= Vector2(0.5, 0.5)
#
#func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#if Input.is_action_just_pressed("ui_left"):
		#anim.flip_h = true
	#elif Input.is_action_just_pressed("ui_right"):
		#anim.flip_h = false
	#
	#var standart_direction: Vector2 = Vector2(0, 1)
	#var planet_direction: Vector2 = position.direction_to(planet.position)
	#rotation_degrees = calc_player_rotation(planet.position, position)
	#
	#if Input.is_action_just_pressed("ui_accept") and is_on_planet:
		#state.apply_force(-planet_direction * 1000000, position)
	#
	#var direction = Input.get_axis("ui_left", "ui_right")
	#if direction and is_on_planet:
		#if (abs(linear_velocity.x) + abs(linear_velocity.y)) <= 200:
			#state.apply_force(right_direction(planet_direction) * 5000 * direction, position)
			#
	#if abs(linear_velocity.x) + abs(linear_velocity.y) > 1:
		#anim.play("run")
	#else:
		#anim.play("idle")
		#
	#if !direction and is_on_planet:
		#linear_velocity.x = move_toward(linear_velocity.x, 0, 10)
		#linear_velocity.y = move_toward(linear_velocity.y, 0, 10)
	#
#func calc_player_rotation(planet_pos: Vector2, player_pos: Vector2) -> float:
	#var relative_position = player_pos - planet_pos
	#var angle_in_radians = relative_position.angle()
	#var angle_in_degrees = rad_to_deg(angle_in_radians)
	#
	#return angle_in_degrees + 90
#
#func right_direction(vector: Vector2) -> Vector2:
	#vector = vector.normalized()
	#return Vector2(vector.y, -vector.x).normalized()
#
#
#func _on_body_entered(body: Node) -> void:
	#if body.get_collision_layer_value(2):
		#is_on_planet = true
#
#func _on_body_exited(body: Node) -> void:
	#if body.get_collision_layer_value(2):
		#is_on_planet = false
