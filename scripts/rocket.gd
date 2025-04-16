extends CharacterBody2D

signal open_map_to_select_point

@export var isKinematic: bool = false

@onready var interactTooltip: Label = $UI/InteractTooltip

var GM: Node2D
var SM: StateMachine
var planet: StaticBody2D
var availableForInteraction: bool = false


func _ready() -> void:
	GM = get_node("/root/GameScene")
	SM = get_node("/root/GameScene/StateMachine")
	
	planet = get_parent()

func _process(delta: float) -> void:
	adjustUI()

func _physics_process(delta: float) -> void:
	if isKinematic:
		return
	if !is_on_wall():
		velocity += get_gravity() * delta
	else:
		rotation_degrees = calc_normal_rotation(get_wall_normal())
	move_and_slide()

func _input(event: InputEvent) -> void:
	if SM.current_state.name == SM.GAME_STATES_NAME[SM.GAME_STATES.ON_PLANET]:
		interact(event)


func adjustUI():
	interactTooltip.rotation_degrees = -rotation_degrees

func calc_normal_rotation(normalVector: Vector2) -> float:
	var angle_in_radians = normalVector.angle()
	var angle_in_degrees = rad_to_deg(angle_in_radians)
	return angle_in_degrees + 90

func right_direction(vector: Vector2) -> Vector2:
	vector = vector.normalized()
	return Vector2(vector.y, -vector.x).normalized()

func interact(event):
	if availableForInteraction and Input.is_action_just_pressed("Interact"):
		emit_signal("open_map_to_select_point")

func _on_interact_tooltip_area_body_entered(body: Node2D) -> void:
	interactTooltip.visible = true
	interactTooltip.text = tr("TOOLTIP_INTERACT") % InputMap.action_get_events("Interact")[0].as_text_physical_keycode()
	availableForInteraction = true

func _on_interact_tooltip_area_body_exited(body: Node2D) -> void:
	interactTooltip.visible = false
	availableForInteraction = false
