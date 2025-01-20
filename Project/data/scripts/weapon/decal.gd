extends Spatial


func _ready() -> void:
	var timer: Timer = $timer
	timer.connect("timeout", self, "queue_free")
