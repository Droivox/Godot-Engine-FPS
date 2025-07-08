class weapon:
	var owner : Node;
	var name : String;
	var firerate : float;
	var bullets : int;
	var ammo : int;
	var max_bullets : int;
	var damage : int;
	var reload_speed : float;
	
	# Node references - will be initialized when needed
	var anim : Node;
	var mesh : Node;
	var animc : String;
	
	func _init(owner, name, firerate, bullets, ammo, max_bullets, damage, reload_speed) -> void:
		self.owner = owner;
		self.name = name;
		self.firerate = firerate;
		self.bullets = bullets;
		self.ammo = ammo;
		self.max_bullets = max_bullets;
		self.damage = damage;
		self.reload_speed = reload_speed;
		
		# Initialize node references
		if owner and name:
			anim = owner.get_node("%s/mesh/anim" % name);
			mesh = owner.get_node("%s" % name);
			if anim:
				animc = anim.current_animation;
	
	func _get_anim() -> Node:
		if not anim and owner and name:
			anim = owner.get_node("%s/mesh/anim" % name);
		return anim;
	
	func _get_mesh() -> Node:
		if not mesh and owner and name:
			mesh = owner.get_node("%s" % name);
		return mesh;
	
	func _get_camera() -> Node:
		if owner and owner.has_method("get_camera_node"):
			return owner.get_camera_node();
		return null;
	
	func _draw() -> void:
		var anim_node = _get_anim();
		var mesh_node = _get_mesh();
		if not anim_node or not mesh_node:
			return;
			
		# Check is visible
		if not mesh_node.visible:
			# Play draw animaton
			anim_node.play("Draw");
	
	func _hide() -> void:
		var anim_node = _get_anim();
		var mesh_node = _get_mesh();
		if not anim_node or not mesh_node:
			return;
			
		# Check is visible
		if mesh_node.visible:
			# Play hide animaton
			anim_node.play("Hide");
	
	func _sprint(sprint, _delta) -> void:
		var mesh_node = _get_mesh();
		if not mesh_node or not owner or not owner.character_node:
			return;
			
		if sprint and owner.character_node.direction:
			mesh_node.rotation.x = lerp(mesh_node.rotation.x, -deg_to_rad(40.0), 5.0 * _delta);
		else:
			mesh_node.rotation.x = lerp(mesh_node.rotation.x, 0.0, 5.0 * _delta);
	
	func _shoot(_delta) -> void:
		if not owner or not name:
			return;
			
		# Get audio node
		var audio = owner.get_node("%s/audio" % name);
		
		# Get effects node
		var effect = owner.get_node("%s/effect" % name);
		
		var anim_node = _get_anim();
		if not anim_node:
			return;
			
		var animc = anim_node.current_animation;
		
		if bullets > 0:
			# Play shoot animation if not reloading
			if animc != "Shoot" and animc != "Reload" and animc != "Draw" and animc != "Hide":
				bullets -= 1;
				
				# recoil
				var camera = _get_camera();
				if camera:
					camera.rotation.x = lerp(camera.rotation.x, randf_range(1.0, 2.0), _delta);
					camera.rotation.y = lerp(camera.rotation.y, randf_range(-1.0, 1.0), _delta);
					
					# Shake the camera
					camera.shake_force = 0.002;
					camera.shake_time = 0.2;
				
				# Change light energy
				if effect:
					effect.get_node("shoot").light_energy = 2.0;
					
					# Emitt fire particles
					effect.get_node("fire").emitting = true;
					
					# Emitt smoke particles
					effect.get_node("smoke").emitting = true;
				
				# Play shoot sound
				if audio:
					audio.get_node("shoot").pitch_scale = randf_range(0.9, 1.1);
					audio.get_node("shoot").play();
				
				# Play shoot animation using firate speed
				anim_node.play("Shoot", 0, firerate);
				
				# Get barrel node
				var barrel = owner.get_node("%s/barrel" % name);
				
				# Get main scene
				var main = owner.get_tree().get_root().get_child(0);
				
				# Create a instance of trail scene
				var trail = preload("res://data/scenes/trail.tscn").instantiate();
				
				# Change trail position to out of barrel position
				if barrel:
					trail.position = barrel.global_transform.origin;
				
				# Change trail rotation to camera rotation
				if camera:
					trail.rotation = camera.global_transform.basis.get_euler();
				
				# Add the trail to main scene
				main.add_child(trail);
				
				# Get raycast weapon range
				var ray = owner.get_node("%s/ray" % name);
				
				# Check raycast is colliding
				if ray and ray.is_colliding():
					var local_damage = int(randf_range(damage/1.5, damage))
					
					# Do damage
					if ray.get_collider() is RigidBody3D:
						ray.get_collider().apply_central_impulse(-ray.get_collision_normal() * (local_damage * 0.3));
					
					if ray.get_collider().is_in_group("prop"):
						if ray.get_collider().is_in_group("metal"):
							var spark = preload("res://data/scenes/spark.tscn").instantiate();
							
							# Add spark scene in collider
							ray.get_collider().add_child(spark);
								
							# Change spark position to collider position
							spark.global_transform.origin = ray.get_collision_point();
							
							spark.emitting = true;
						
						if ray.get_collider().has_method("_damage"):
							ray.get_collider()._damage(local_damage);
					
					# Create a instance of decal scene
					var decal = preload("res://data/scenes/decal.tscn").instantiate();
					
					# Add decal scene in collider
					ray.get_collider().add_child(decal);
					
					# Change decal position to collider position
					decal.global_transform.origin = ray.get_collision_point();
					
					# decal spins to collider normal
					decal.look_at(ray.get_collision_point() + ray.get_collision_normal(), Vector3(1, 1, 0));
		else:
			# Play out sound
			if audio and not audio.get_node("out").playing:
				audio.get_node("out").pitch_scale = randf_range(0.9, 1.1);
				audio.get_node("out").play();

	func _reload() -> void:
		var anim_node = _get_anim();
		if not anim_node:
			return;
			
		var animc = anim_node.current_animation;
		
		if bullets < max_bullets and ammo > 0:
			if animc != "Reload" and animc != "Shoot" and animc != "Draw" and animc != "Hide":
				# Play reload animation
				anim_node.play("Reload", 0.2, reload_speed);
				
				for b in ammo:
					bullets += 1
					ammo -= 1;
					
					if bullets >= max_bullets:
						break;
	
	func _zoom(input, _delta) -> void:
		var lerp_speed : float = 30.0;
		var camera = _get_camera();
		var mesh_node = _get_mesh();
		var anim_node = _get_anim();
		
		if not camera or not mesh_node or not anim_node:
			return;
			
		var animc = anim_node.current_animation;
		
		if input and animc != "Reload" and animc != "Hide" and animc != "Draw":
			camera.fov = lerp(camera.fov, 40.0, lerp_speed * _delta);
			mesh_node.position.y = lerp(mesh_node.position.y, 0.001, lerp_speed * _delta);
			mesh_node.position.x = lerp(mesh_node.position.x, -0.088, lerp_speed * _delta);
		else:
			camera.fov = lerp(camera.fov, 70.0, lerp_speed * _delta);
			mesh_node.position.y = lerp(mesh_node.position.y, 0.0, lerp_speed * _delta);
			mesh_node.position.x = lerp(mesh_node.position.x, 0.0, lerp_speed * _delta);
	
	func _update(_delta) -> void:
		var anim_node = _get_anim();
		if not anim_node:
			return;
			
		var animc = anim_node.current_animation;
		
		if animc != "Shoot":
			if owner and owner.arsenal and owner.current < owner.arsenal.size() and owner.arsenal.values()[owner.current] == self:
				var camera = _get_camera();
				if camera:
					camera.rotation.x = lerp(camera.rotation.x, 0.0, 10.0 * _delta);
					camera.rotation.y = lerp(camera.rotation.y, 0.0, 10.0 * _delta);
		
		# Get current animation
		animc = anim_node.current_animation;
		
		# Get effect node
		if owner and name:
			var effect = owner.get_node("%s/effect" % name);
			
			# Change light energy
			if effect:
				effect.get_node("shoot").light_energy = lerp(effect.get_node("shoot").light_energy, 0.0, 5.0 * _delta);
		
		# Remove recoil
		var mesh_node = _get_mesh();
		if mesh_node:
			mesh_node.rotation.x = lerp(mesh_node.rotation.x, 0.0, 5.0 * _delta);
