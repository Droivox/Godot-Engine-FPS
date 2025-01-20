extends Camera
class_name CharacterCamera


export var shake_time: float
export var shake_force: float


#func _process(delta: float) -> void:
func _physics_process(delta: float) -> void:
	_shake(delta)


func _shake(delta: float) -> void:
	if shake_time > 0.0:
		h_offset = rand_range(-shake_force, shake_force)
		v_offset = rand_range(-shake_force, shake_force)
		shake_time -= delta
	else:
		h_offset = 0.0
		v_offset = 0.0
