extends RigidBody


export var durability: int = 100
export var damage_distance: int = 300

var remove_decal: bool = false

onready var root = get_tree().get_root()

onready var timer: Timer = $timer
onready var explosion_timer: Timer = $explosion/timer
onready var collision: CollisionShape = $collision
onready var mesh: Spatial = $mesh
onready var effects_ex: Particles = $effects/ex
onready var effects_plo: Particles = $effects/plo
onready var effects_sion: Particles = $effects/sion
onready var audios_explosion: AudioStreamPlayer3D = $audios/explosion
onready var audios_impact: AudioStreamPlayer3D = $audios/impact
onready var explosion: Area = $explosion


func _ready() -> void:
	timer.connect("timeout", self, "queue_free")
	explosion_timer.connect("timeout", self, "_explode_others")


func _process(_delta: float) -> void:
	_remove_decal()


func _damage(damage: int) -> void:
	if durability > 0:
		var dam_calc: int = durability - damage

		audios_impact.pitch_scale = rand_range(0.9, 1.1)
		audios_impact.play()

		if dam_calc <= 0:
			durability -= damage
			_explosion()
			explosion_timer.start()
			timer.start()
		else:
			durability -= damage


func _explosion() -> void:
	collision.disabled = true
	
	var main: Node = root.get_child(0)
	var burnt_ground: Spatial = preload("res://data/scenes/burnt_ground.tscn").instance()

	main.add_child(burnt_ground)
	burnt_ground.translation = global_transform.origin

	# freeze_mode
	mode = MODE_STATIC

	mesh.visible = false
	effects_ex.emitting = true
	effects_plo.emitting = true
	effects_sion.emitting = true
	audios_explosion.pitch_scale = rand_range(0.9, 1.1)
	audios_explosion.play()

	remove_decal = true


func _remove_decal() -> void:
	if remove_decal:
		for child in get_child_count():
			var item: Node = get_child(child)

			if item.is_in_group("decal"):
				item.queue_free()


func _explode_others() -> void:
	for bodie in explosion.get_overlapping_bodies():
		if bodie != self and bodie.has_method("_damage") and "durability" in bodie and bodie.durability > 0:
			var explosion_distance: float = (5.0 * bodie.global_transform.origin.distance_to(global_transform.origin))
			bodie._damage(damage_distance - explosion_distance)
