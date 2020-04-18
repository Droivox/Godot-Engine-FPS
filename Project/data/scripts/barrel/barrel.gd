extends RigidBody

export var durability : int = 100;
var remove_decal : bool = false;

func _ready():
	$timer.connect("timeout", self, "queue_free");
	$explosion/timer.connect("timeout", self, "_explode_others");

func _damage(damage) -> void:
	if durability > 0:
		var dam_calc = durability - damage;
		
		$audios/impact.pitch_scale = rand_range(0.9, 1.1);
		$audios/impact.play()
		
		if dam_calc <= 0:
			durability -= damage;
			_explosion();
			$explosion/timer.start();
			$timer.start();
		else:
			durability -= damage;

func _process(_delta) -> void:
	_remove_decal();

func _explosion() -> void:
	$collision.disabled = true;
	
	var main = get_tree().get_root().get_child(0);
	
	var burnt_ground = preload("res://data/scenes/burnt_ground.tscn").instance();
	main.add_child(burnt_ground);
	burnt_ground.translation = global_transform.origin;
	
	mode = MODE_STATIC;
	
	$mesh.visible = false;
	$effects/ex.emitting = true;
	$effects/plo.emitting = true;
	$effects/sion.emitting = true;
	$audios/explosion.pitch_scale = rand_range(0.9, 1.1);
	$audios/explosion.play();
	
	remove_decal = true;

func _remove_decal():
	if remove_decal:
		for child in get_child_count():
			if get_child(child).is_in_group("decal"):
				get_child(child).queue_free();

func _explode_others():
	for bodie in $explosion.get_overlapping_bodies():
		if bodie.has_method("_damage") and bodie != self:
			if "durability" in bodie:
				if bodie.durability > 0:
					var explosion_distance = (5 * bodie.global_transform.origin.distance_to(global_transform.origin));
					bodie._damage(300 - explosion_distance);
