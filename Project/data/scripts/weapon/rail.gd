extends Node3D

var speed : float = 200;
@export var timer: NodePath;
var timer_node: Node;

func _ready() -> void:
	$mesh.position.z = -$mesh.mesh.height/2;
	if timer != NodePath():
		timer_node = get_node(timer);
		timer_node.connect("timeout", Callable(self, "queue_free"));

func _process(_delta) -> void:
	position -= (global_transform.basis.z * speed) * _delta;
