extends CanvasLayer

export(NodePath) var weapon
export(NodePath) var weapon_hud
export(NodePath) var crosshair

var viewport
var off = Vector2(180.0, 80.0)

func _ready():
	viewport = get_viewport()
	weapon = get_node(weapon)
	weapon_hud = get_node(weapon_hud)
	crosshair = get_node(crosshair)

func _process(_delta) -> void:
	_weapon_hud()
	_crosshair()

func _weapon_hud() -> void:
	weapon_hud.position = viewport.size - off

	var data = weapon.arsenal.values()[weapon.current]
	var color

	weapon_hud.get_node("name").text = str(data.name)
	weapon_hud.get_node("bullets").text = str(data.bullets)
	weapon_hud.get_node("ammo").text = str(data.ammo)

	# Color
	if data.bullets < (data.max_bullets / 4.0):
		color = Color("#ff0000")
	elif data.bullets < (data.max_bullets / 2.0):
		color = Color("#dd761b")
	else:
		color = Color("#ffffff")

	weapon_hud.get_node("bullets").add_color_override("font_color", color)

func _crosshair() -> void:
	crosshair.position = viewport.size / 2.0;
