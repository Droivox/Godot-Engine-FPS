extends StaticBody

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
	for child in get_child_count():
		if get_child(child).is_in_group("decal"):
			get_child(child).queue_free();
			$collision.disabled = true;
	
	$mesh.visible = false;
	$effects/fire.emitting = true;
	$effects/smoke.emitting = true;
	$audios/explosion.play();
