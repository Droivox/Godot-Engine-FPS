extends Camera

export var shake_time : float;
export var shake_force : float;

func _process(_delta) -> void:
	_shake(_delta);

func _shake(_delta) -> void:
	if shake_time > 0:
		h_offset = rand_range(-shake_force, shake_force);
		v_offset = rand_range(-shake_force, shake_force);
		shake_time -= _delta;
	else:
		h_offset = 0;
		v_offset = 0;
