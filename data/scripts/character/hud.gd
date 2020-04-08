extends CanvasLayer

export(NodePath) var weapon;
export(NodePath) var weapon_hud;
export(NodePath) var crosshair;

func _ready():
	weapon = get_node(weapon);
	weapon_hud = get_node(weapon_hud);
	crosshair = get_node(crosshair);

func _process(_delta) -> void:
	_weapon_hud()
	_crosshair()

func _weapon_hud() -> void:
	var off = Vector2(180, 80);
	weapon_hud.position = get_viewport().size - off;
	
	weapon_hud.get_node("name").text = str(weapon.arsenal.values()[weapon.current].name);
	weapon_hud.get_node("bullets").text = str(weapon.arsenal.values()[weapon.current].bullets);
	weapon_hud.get_node("ammo").text = str(weapon.arsenal.values()[weapon.current].ammo);
	
	# Color
	if weapon.arsenal.values()[weapon.current].bullets < (weapon.arsenal.values()[weapon.current].max_bullets/4):
		weapon_hud.get_node("bullets").add_color_override("font_color", Color("#ff0000"));
	elif weapon.arsenal.values()[weapon.current].bullets < (weapon.arsenal.values()[weapon.current].max_bullets/2):
		weapon_hud.get_node("bullets").add_color_override("font_color", Color("#dd761b"));
	else:
		weapon_hud.get_node("bullets").add_color_override("font_color", Color("#ffffff"));

func _crosshair() -> void:
	crosshair.position = get_viewport().size/2;
