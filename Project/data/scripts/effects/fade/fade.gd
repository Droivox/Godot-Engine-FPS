extends ColorRect

@export  var fade_time : float = 1
@onready var timer : Node = $timer;

func _ready() -> void:
	timer.wait_time = fade_time;
	timer.one_shot = true;
	timer.start()
	
	timer.connect("timeout", Callable(self, "queue_free"))

func _process(_delta) -> void:
	_fade();

func _fade() -> void:
	scale = Vector2(get_viewport().size);
	
	modulate.a = timer.time_left;
