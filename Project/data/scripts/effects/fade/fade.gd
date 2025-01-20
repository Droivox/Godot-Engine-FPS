extends ColorRect


export var fade_time: float = 1.0

onready var timer: Timer = $timer
onready var viewport: Viewport = get_viewport()


func _ready() -> void:
	timer.wait_time = fade_time
	timer.start()


func _process(_delta: float) -> void:
	rect_scale = viewport.size
	modulate.a = timer.time_left
