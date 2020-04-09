extends RigidBody

export(NodePath) var timer;

export var durability : int = 99999999;

func _ready():
	timer = get_node(timer);
	
	timer.connect("timeout", self, "queue_free");

func _interact(damage) -> void:
	var dam_calc = durability - damage;
	
	$audios/impact.pitch_scale = rand_range(0.9, 1.1);
	$audios/impact.play()
	
	if dam_calc <= 0:
		_explosion();
		timer.start();
	else:
		durability -= damage;

func _explosion() -> void:
	$collision.disabled = true;
	
	var main = get_tree().get_root().get_child(0);
	
	var burnt_ground = preload("res://data/scenes/burnt_ground.tscn").instance();
	main.add_child(burnt_ground);
	burnt_ground.translation = global_transform.origin;
	
	mode = MODE_STATIC;
	
	$mesh.visible = false;
	$effects/fire.emitting = true;
	$effects/smoke.emitting = true;
	$effects/black_smoke.emitting = true;
	$audios/explosion.play();
	
	for child in get_child_count():
		if get_child(child).is_in_group("decal"):
			get_child(child).queue_free();
