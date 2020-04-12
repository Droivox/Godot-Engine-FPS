extends Particles

export(NodePath) var timer;

func _ready() -> void:
	timer = get_node(timer);
	
	timer.connect("timeout", self, "queue_free");
