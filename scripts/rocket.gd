extends CharacterBody2D

@onready var SM: StateMachine
@onready var interactTooltip: Label = $UI/InteractTooltip

var planet: StaticBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _ready() -> void:
	SM = get_tree().get_root().find_child("StateMachine", true, false)
	planet = get_parent()
	
func _physics_process(delta: float) -> void:
	if !is_on_wall():
		velocity += get_gravity() * delta
	else:
		rotation_degrees = calc_player_rotation(get_wall_normal())
		
	move_and_slide()
	
func calc_player_rotation(normalVector: Vector2) -> float:
	var angle_in_radians = normalVector.angle()
	var angle_in_degrees = rad_to_deg(angle_in_radians)
	return angle_in_degrees + 90

func right_direction(vector: Vector2) -> Vector2:
	vector = vector.normalized()
	return Vector2(vector.y, -vector.x).normalized()


func _on_interact_tooltip_area_body_entered(body: Node2D) -> void:
	interactTooltip.visible = true
	interactTooltip.rotation_degrees = -rotation_degrees
	interactTooltip.text = tr("TOOLTIP_INTERACT") % InputMap.action_get_events("Interact")[0].as_text_physical_keycode()

func _on_interact_tooltip_area_body_exited(body: Node2D) -> void:
	interactTooltip.visible = false
