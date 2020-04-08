extends AnimationPlayer

# Váriavel que pega o caminho para o node do personagem
export(NodePath) var player;

func _ready():
	# Pega o node do personagem
	player = get_node(player);

func _process(_delta):
	# Uma função de animação dinâmica para o pescoço
	_neck_animation(_delta)

	# Chama uma função com animações prontas
	_animation()

func _animation() -> void:
	# Caso o jogador pressione o botão de pular
	if player.input["jump"]:
		# Checa se a animação de pular está ativa
		if current_animation != "jump":
			# Inicia a animação de pular
			play("jump", 0.3);

	# Caso o personagem esteja se movendo
	if player.direction:
		# Caso a animação atual não seja walk
		if current_animation != "jump":
			if player.input["run"]:
				if current_animation != "run":
					play("run", 0.3, 1.5);
			else:
				if current_animation != "walk":
					play("walk", 0.3);
	else:
		# Caso a animação atual não seja idle
		if current_animation != "idle" and current_animation != "jump":
			# Inicia a animação com uma suavização
			play("idle", 0.3, 0.1);

func _neck_animation(_delta) -> void:
	# Velocidade da rotação do pescoço
	var rotation_speed : float = player.n_speed * _delta 

	# Pega o node da câmera
	var camera : Node = $"../camera";

	# Cria o angulo baseado na movimentação do personagem
	var angle : float = 2 * (player.input["right"] + -player.input["left"]);

	# Aplica uma interpolação a rotação do pescoço baseado no angulo
	camera.rotation.z = lerp(camera.rotation.z, -deg2rad(angle), rotation_speed)
