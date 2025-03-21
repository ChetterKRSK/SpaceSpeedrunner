extends CharacterBody2D

@onready var planet: StaticBody2D = $"../Planet"
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta: float) -> void:
	rotation_degrees = calc_player_rotation(planet.position, position)
	if !is_on_wall():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("ui_accept") and is_on_wall():
		velocity += JUMP_VELOCITY * position.direction_to(planet.position)

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction and is_on_wall():
		if direction > 0:
			anim.flip_h = false
		elif direction < 0:
			anim.flip_h = true
		anim.play("run")
		velocity = right_direction(position.direction_to(planet.position)) * SPEED * direction
	
	if !direction and is_on_wall():
		anim.play("idle")
		velocity = velocity.move_toward(Vector2(), 20)
	
	move_and_slide()

func calc_player_rotation(planet_pos: Vector2, player_pos: Vector2) -> float:
	var relative_position = player_pos - planet_pos
	var angle_in_radians = relative_position.angle()
	var angle_in_degrees = rad_to_deg(angle_in_radians)
	
	return angle_in_degrees + 90

func right_direction(vector: Vector2) -> Vector2:
	vector = vector.normalized()
	return Vector2(vector.y, -vector.x).normalized()
