extends CanvasLayer

@export var weapon: NodePath;
@export var weapon_hud: NodePath;
@export var crosshair: NodePath;

var weapon_node: Node;
var weapon_hud_node: Node;
var crosshair_node: Node;

func _ready():
	if weapon != NodePath():
		weapon_node = get_node(weapon);
	if weapon_hud != NodePath():
		weapon_hud_node = get_node(weapon_hud);
	if crosshair != NodePath():
		crosshair_node = get_node(crosshair);

func _process(_delta) -> void:
	if weapon_node and weapon_hud_node and crosshair_node:
		_weapon_hud()
		_crosshair()

func _weapon_hud() -> void:
	var off = Vector2(180, 80);
	weapon_hud_node.position = Vector2(get_viewport().size) - off;
	
	weapon_hud_node.get_node("name").text = str(weapon_node.arsenal.values()[weapon_node.current].name);
	weapon_hud_node.get_node("bullets").text = str(weapon_node.arsenal.values()[weapon_node.current].bullets);
	weapon_hud_node.get_node("ammo").text = str(weapon_node.arsenal.values()[weapon_node.current].ammo);
	
	# Color
	if weapon_node.arsenal.values()[weapon_node.current].bullets < (weapon_node.arsenal.values()[weapon_node.current].max_bullets/4):
		weapon_hud_node.get_node("bullets").add_theme_color_override("font_color", Color.RED);
	elif weapon_node.arsenal.values()[weapon_node.current].bullets < (weapon_node.arsenal.values()[weapon_node.current].max_bullets/2):
		weapon_hud_node.get_node("bullets").add_theme_color_override("font_color", Color.ORANGE);
	else:
		weapon_hud_node.get_node("bullets").add_theme_color_override("font_color", Color.WHITE);

func _crosshair() -> void:
	crosshair_node.position = Vector2(get_viewport().size)/2;
