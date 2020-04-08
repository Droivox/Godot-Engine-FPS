extends Particles

export(NodePath) var timer;

func _ready():
	timer = get_node(timer);
	
	timer.connect("timeout", self, "queue_free");
