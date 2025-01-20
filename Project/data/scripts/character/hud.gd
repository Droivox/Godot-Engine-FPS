extends CanvasLayer


onready var weapons: Weapons = get_node("%weapons")
onready var weapon_hud: Node2D = get_node("%weapon_hud")
onready var weapon_name: Label = get_node("%weapon_hud/name")
onready var weapon_ammo: Label = get_node("%weapon_hud/ammo")
onready var hud_bullets: Label = get_node("%weapon_hud/bullets")
onready var crosshair: Sprite = get_node("%crosshair")

var off: Vector2 = Vector2(180.0, 80.0)


func _process(_delta: float) -> void:
	_weapon_hud()
	_crosshair()


func _weapon_hud() -> void:
	weapon_hud.position = get_viewport().size - off

	var arsenals: Array = weapons.arsenal.values()
	var current_arsenal = arsenals[weapons.current]

	var bullets = current_arsenal.bullets
	var max_bullets = current_arsenal.max_bullets

	hud_bullets.text = str(bullets)
	weapon_name.text = str(current_arsenal.name)
	weapon_ammo.text = str(current_arsenal.ammo)

	# Color
	var color: Color

	if bullets < (max_bullets/4.0):
		color = Color("#ff0000")
	elif bullets < (max_bullets/2.0):
		color = Color("#dd761b")
	else:
		color = Color("#ffffff")

	hud_bullets.add_color_override("font_color", color)


func _crosshair() -> void:
	crosshair.position = get_viewport().size/2.0
