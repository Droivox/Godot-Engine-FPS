extends CanvasLayer

# Váriaveis de tela
var fullscreen : bool = false

# Todos os input do debug
var input : Dictionary = {};

func _process(_delta) -> void:
	# Chama a função para mudar para fullscren ou janela com Alt e Enter
	_toggle_fullscreen();
	
	# Chama a função para mostrar o framerate
	_display_framerate();
	
	# Chama a função para resetar o jogo
	_reload_scene();

func _toggle_fullscreen() -> void:
	# Caso não tenha o node timer fullscreen ele vai criar um
	if not has_node("timer_fullscreen"):
		# Cria um timer
		var timer = Timer.new();
		
		# Muda o nome do timer para fullscreen
		timer.name = "timer_fullscreen";
		
		# O tempo do timer
		timer.wait_time = 0.2;
		
		# Timer vai contar uma vez e parar
		timer.one_shot = true;
		
		# Adiciona o timer no debug
		add_child(timer);
	
	else: # caso já tenha o node timer fullscreen
		# Pega o node timer fullscreen 
		var timer = $"timer_fullscreen";
		
		# Caso o timer chegue a zero eu posso mudar o modo de tela
		if !timer.time_left:
			input["enter"] = Input.is_action_pressed("KEY_ENTER");
			input['alt']   = Input.is_action_pressed("KEY_ALT");
			
			if input['alt'] and input['enter']:
				fullscreen = !fullscreen;
				
				OS.window_fullscreen = fullscreen;
				
				# Inicia o timer novamente
				timer.start();

func _display_framerate() -> void:
	# Caso não tenha o framerate label
	if not has_node("framerate_label"):
		# Cria um novo label
		var framerate_label = Label.new();
		
		# Muda o nome do label para framerate label
		framerate_label.name = "framerate_label";
		
		# Muda a posição do framerate label
		framerate_label.rect_position = Vector2(5, 5)
		
		# Muda a cor do framerate label
		framerate_label.add_color_override("font_color", ColorN("black"))
		
		# Adiciona o label framerate ao debug
		add_child(framerate_label);
	else:
		# Pega o framerate label
		var framerate_label = $"framerate_label";
		
		# Muda o texto do label para o do framerate
		framerate_label.text = str(Engine.get_frames_per_second());

func _reload_scene() -> void:
	# Input
	input["reload"] = Input.is_action_just_pressed("KEY_F6")
	
	# Caso eu pressione o botão reload
	if input["reload"]:
		# Recarrega a cena
		get_tree().reload_current_scene();
