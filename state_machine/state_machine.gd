extends Node2D
class_name StateMachine

enum GAME_STATES{
	ON_PLANET,
	ON_PLANET_ORBIT,
	ON_STAR_MAP
}
var GAME_STATES_NAME: Dictionary[int, String] = {
	GAME_STATES.ON_PLANET: "OnPlanet",
	GAME_STATES.ON_PLANET_ORBIT: "OnPlanetOrbit",
	GAME_STATES.ON_STAR_MAP: "OnStarMap",
}

var current_state: Object

var states: Dictionary[String, Object]
var history: Array[Object]

func _ready() -> void:
	for state in get_children():
		state.fsm = self
		states[state.name] = state

func _process(delta: float) -> void:
	current_state.process(delta)
	
func _input(event: InputEvent) -> void:
	current_state.input(event)

func change_state(state_name):
	history.append(current_state.name)
	set_state(state_name)

func set_state(state_name):
	current_state = states[state_name]
