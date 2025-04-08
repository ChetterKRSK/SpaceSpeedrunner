extends Node2D

var GM: Node2D
var SM: StateMachine


func _ready() -> void:
	GM = get_node("/root/GameScene")

func open() -> void:
	for node in get_tree().get_nodes_in_group("on_planet_orbit_state_objects"):
		node.visible = true

func close() -> void:
	for node in get_tree().get_nodes_in_group("on_planet_orbit_state_objects"):
		node.visible = false

func process(delta: float) -> void:
	pass

func physics_process(delta: float) -> void:
	pass

func input(event: InputEvent) -> void:
	toggleMap(event)


func toggleMap(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("Toggle_Map"):
			SM.change_state(SM.GAME_STATES_NAME[SM.GAME_STATES.ON_STAR_MAP])
