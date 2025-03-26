@tool
extends Path2D

@export var line: Line2D

@export var orbitRadius: float = 10
@export var line_width: float = 10

@export_tool_button("Обновить орбиту") var updateButton: Callable = updateButtonEvent

func _ready():
	if Engine.is_editor_hint():
		if line == null:
			line = Line2D.new()
			set_line_defaults()
			line.points= curve.tessellate()
			lock_node(line)
			add_child(line)
			line.owner=owner

	if Engine.is_editor_hint():
		if not curve.changed.is_connected(curve_changed):
			curve.changed.connect(curve_changed)

func _enter_tree():
	if Engine.is_editor_hint():
		if not curve.changed.is_connected(curve_changed):
			curve.changed.connect(curve_changed)

func _exit_tree():
	if curve.changed.is_connected(curve_changed):
		curve.changed.disconnect(curve_changed)

func curve_changed():
	line.points=curve.tessellate()
	line.width = line_width

func lock_node(node:Node):
	node.set_meta("_edit_lock_", true);

func set_line_defaults():
	line.begin_cap_mode= Line2D.LINE_CAP_ROUND
	line.joint_mode=Line2D.LINE_JOINT_ROUND
	line.width = line_width
	line.width_curve = null
	line.name = name+"Line"

func make_default_curve():
	var retval = Curve.new()
	retval.min_value = 0
	retval.max_value = 1
	retval.add_point(Vector2(0,1))
	retval.add_point(Vector2(1,0))

	return retval


func updateButtonEvent():
	line.width = line_width
	
	curve.clear_points()
	var orbitSmooth = orbitRadius / (20./11)
	curve.add_point(Vector2(orbitRadius, 0), Vector2(), Vector2(0, -orbitSmooth))
	curve.add_point(Vector2(0, -orbitRadius), Vector2(orbitSmooth, 0), Vector2(-orbitSmooth, 0))
	curve.add_point(Vector2(-orbitRadius, 0), Vector2(0, -orbitSmooth), Vector2(0, orbitSmooth))
	curve.add_point(Vector2(0, orbitRadius), Vector2(-orbitSmooth, 0), Vector2(orbitSmooth, 0))
	curve.add_point(Vector2(orbitRadius, 0), Vector2(0, orbitSmooth), Vector2())
