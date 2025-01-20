extends Spatial


onready var feet: RayCast = get_node("../../feet")
onready var character: MovementPlayer = get_node("../..")

var footsteep_timer: float = 0.0
#var footsteep_speed: float = 0.5
var footsteep_list: Dictionary = {}

# var dont_repeat: int = 0


func _ready() -> void:
	randomize()

	for audio in get_child_count():
		var item: Node = get_child(audio)
		footsteep_list[item.name] = item


#func _process(delta: float) -> void:
func _physics_process(delta: float) -> void:
	if footsteep_timer > 0.0:
		footsteep_timer -= delta
	elif character.direction and feet.is_colliding():
		var collider = feet.get_collider()
		var groups = collider.get_groups()

		for g in groups:
			if footsteep_list.has(g):
				var footsteep_node: Spatial = footsteep_list[g]

				if footsteep_node.get_child_count() > 0:
					var audio_index: int = randi() % footsteep_node.get_child_count()
					var audio: AudioStreamPlayer3D = footsteep_node.get_child(audio_index)

					audio.play()

					footsteep_timer = 1.0 - (0.06 * character.n_speed)
					break
