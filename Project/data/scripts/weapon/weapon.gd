class weapon:
	var owner : Node;
	var name : String;
	var firerate : float;
	var bullets : int;
	var ammo : int;
	var max_bullets : int;
	var damage : int;
	var reload_speed : float;
	
	func _init(owner, name, firerate, bullets, ammo, max_bullets, damage, reload_speed) -> void:
		self.owner = owner;
		self.name = name;
		self.firerate = firerate;
		self.bullets = bullets;
		self.ammo = ammo;
		self.max_bullets = max_bullets;
		self.damage = damage;
		self.reload_speed = reload_speed;
	
	# Get animation node
	var anim = owner.get_node("{}/mesh/anim".format([name], "{}"));
	
	# Get current animation
	var animc = anim.current_animation;
	
	# Get animation node
	var mesh = owner.get_node("{}".format([name], "{}"));
	
	func _draw() -> void:
		# Check is visible
		if not mesh.visible:
			# Play draw animaton
			anim.play("Draw");
	
	func _hide() -> void:
		# Check is visible
		if mesh.visible:
			# Play hide animaton
			anim.play("Hide");
	
	func _sprint(sprint, _delta) -> void:
		if sprint and owner.character.direction:
			mesh.rotation.x = lerp(mesh.rotation.x, -deg2rad(40), 5 * _delta);
		else:
			mesh.rotation.x = lerp(mesh.rotation.x, 0, 5 * _delta);
	
	func _shoot(_delta) -> void:
		# Get audio node
		var audio = owner.get_node("{}/audio".format([name], "{}"));
		
		# Get effects node
		var effect = owner.get_node("{}/effect".format([name], "{}"));
		
		if bullets > 0:
			# Play shoot animation if not reloading
			if animc != "Shoot" and animc != "Reload" and animc != "Draw" and animc != "Hide":
				bullets -= 1;
				
				# recoil
				owner.camera.rotation.x = lerp(owner.camera.rotation.x, rand_range(1, 2), _delta);
				owner.camera.rotation.y = lerp(owner.camera.rotation.y, rand_range(-1, 1), _delta);
				
				# Shake the camera
				owner.camera.shake_force = 0.002;
				owner.camera.shake_time = 0.2;
				
				# Change light energy
				effect.get_node("shoot").light_energy = 2;
				
				# Emitt fire particles
				effect.get_node("fire").emitting = true;
				
				# Emitt smoke particles
				effect.get_node("smoke").emitting = true;
				
				# Play shoot sound
				audio.get_node("shoot").pitch_scale = rand_range(0.9, 1.1);
				audio.get_node("shoot").play();
				
				# Play shoot animation using firate speed
				anim.play("Shoot", 0, firerate);
				
				# Get barrel node
				var barrel = owner.get_node("{}/barrel".format([name], "{}"));
				
				# Get main scene
				var main = owner.get_tree().get_root().get_child(0);
				
				# Create a instance of trail scene
				var trail = preload("res://data/scenes/trail.tscn").instance();
				
				# Change trail position to out of barrel position
				trail.translation = barrel.global_transform.origin;
				
				# Change trail rotation to camera rotation
				trail.rotation = owner.camera.global_transform.basis.get_euler();
				
				# Add the trail to main scene
				main.add_child(trail);
				
				# Get raycast weapon range
				var ray = owner.get_node("{}/ray".format([name], "{}"));
				
				# Check raycast is colliding
				if ray.is_colliding():
					var local_damage = int(rand_range(damage/1.5, damage))
					
					# Do damage
					if ray.get_collider() is RigidBody:
						ray.get_collider().apply_central_impulse(-ray.get_collision_normal() * (local_damage * 0.3));
					
					if ray.get_collider().is_in_group("prop"):
						if ray.get_collider().is_in_group("metal"):
							var spark = preload("res://data/scenes/spark.tscn").instance();
							
							# Add spark scene in collider
							ray.get_collider().add_child(spark);
								
							# Change spark position to collider position
							spark.global_transform.origin = ray.get_collision_point();
							
							spark.emitting = true;
						
						if ray.get_collider().has_method("_damage"):
							ray.get_collider()._damage(local_damage);
					
					# Create a instance of decal scene
					var decal = preload("res://data/scenes/decal.tscn").instance();
					
					# Add decal scene in collider
					ray.get_collider().add_child(decal);
					
					# Change decal position to collider position
					decal.global_transform.origin = ray.get_collision_point();
					
					# decal spins to collider normal
					decal.look_at(ray.get_collision_point() + ray.get_collision_normal(), Vector3(1, 1, 0));
		else:
			# Play out sound
			if not audio.get_node("out").playing:
				audio.get_node("out").pitch_scale = rand_range(0.9, 1.1);
				audio.get_node("out").play();

	func _reload() -> void:
		if bullets < max_bullets and ammo > 0:
			if animc != "Reload" and animc != "Shoot" and animc != "Draw" and animc != "Hide":
				# Play reload animation
				anim.play("Reload", 0.2, reload_speed);
				
				for b in ammo:
					bullets += 1
					ammo -= 1;
					
					if bullets >= max_bullets:
						break;
	
	func _zoom(input, _delta) -> void:
		var lerp_speed : int = 30;
		var camera = owner.camera;
		
		if input and animc != "Reload" and animc != "Hide" and animc != "Draw":
			camera.fov = lerp(camera.fov, 40, lerp_speed * _delta);
			mesh.translation.y = lerp(mesh.translation.y, 0.001, lerp_speed * _delta);
			mesh.translation.x = lerp(mesh.translation.x, -0.088, lerp_speed * _delta);
		else:
			camera.fov = lerp(camera.fov, 70, lerp_speed * _delta);
			mesh.translation.y = lerp(mesh.translation.y, 0, lerp_speed * _delta);
			mesh.translation.x = lerp(mesh.translation.x, 0, lerp_speed * _delta);
	
	func _update(_delta) -> void:
		if animc != "Shoot":
			if owner.arsenal.values()[owner.current] == self:
				owner.camera.rotation.x = lerp(owner.camera.rotation.x, 0, 10 * _delta);
				owner.camera.rotation.y = lerp(owner.camera.rotation.y, 0, 10 * _delta);
		
		# Get current animation
		animc = anim.current_animation;
		
		# Get effect node
		var effect = owner.get_node("{}/effect".format([name], "{}"));
		
		# Change light energy
		effect.get_node("shoot").light_energy = lerp(effect.get_node("shoot").light_energy, 0, 5 * _delta);
		
		# Remove recoil
		mesh.rotation.x = lerp(mesh.rotation.x, 0, 5 * _delta);
