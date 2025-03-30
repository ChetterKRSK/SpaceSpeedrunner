extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var GAME_STATE = 0

var planet: StaticBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

func _ready() -> void:
	planet = get_parent()

func _physics_process(delta: float) -> void:
	if !is_on_wall():
		velocity += get_gravity() * delta
	rotation_degrees = calc_player_rotation(planet.position, position)
	
	if GAME_STATE == 0:
		playerMovement()
		move_and_slide()


func playerMovement():
	var direction := Input.get_axis("Move_Left", "Move_Right")
	if direction and is_on_wall():
		if direction > 0:
			anim.flip_h = false
		elif direction < 0:
			anim.flip_h = true
		anim.play("run")
		velocity = velocity.lerp(right_direction(position.direction_to(planet.position)) * SPEED * direction, 0.1)
	if !direction and is_on_wall():
		anim.play("idle")
		velocity = velocity.lerp(Vector2(), 0.2)

func calc_player_rotation(planet_pos: Vector2, player_pos: Vector2) -> float:
	var relative_position = player_pos - planet_pos
	var angle_in_radians = relative_position.angle()
	var angle_in_degrees = rad_to_deg(angle_in_radians)
	return angle_in_degrees + 90

func right_direction(vector: Vector2) -> Vector2:
	vector = vector.normalized()
	return Vector2(vector.y, -vector.x).normalized()

func _change_game_state(game_state):
	GAME_STATE = game_state
