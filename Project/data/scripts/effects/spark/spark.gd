extends GPUParticles3D

@export var timer: NodePath;
var timer_node: Node;

func _ready() -> void:
	if timer != NodePath():
		timer_node = get_node(timer);
		timer_node.connect("timeout", Callable(self, "queue_free"));
