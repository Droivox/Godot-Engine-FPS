class Weapon:
	var owner: Weapons
	var name: String
	var firerate: float
	var bullets: int
	var ammo: int
	var max_bullets: int
	var damage: int
	var reload_speed: float
	var root: Viewport
	var anim: AnimationPlayer
	var animc: String
	var mesh: Spatial
	var camera: CharacterCamera
	var character: MovementPlayer
	var arsenal: Dictionary
	var lerp_speed: float = 30.0
	var decal_base: Vector3 = Vector3(1.0, 1.0, 0.0)

	func _init(
		_owner: Weapons,
		_name: String,
		_firerate: float,
		_bullets: int,
		_ammo: int,
		_max_bullets: int,
		_damage: int,
		_reload_speed: float
	) -> void:
		owner = _owner
		name = _name
		firerate = _firerate
		bullets = _bullets
		ammo = _ammo
		max_bullets = _max_bullets
		damage = _damage
		reload_speed = _reload_speed
		root = _owner.get_tree().get_root()
		anim = _owner.get_node("{}/mesh/anim".format([name], "{}"))
		animc = anim.current_animation
		mesh = _owner.get_node("{}".format([name], "{}"))
		camera = _owner.get_camera()
		character = _owner.get_character()
		arsenal = _owner.arsenal


	func _draw() -> void:
		# Check is visible
		if not mesh.visible:
			# Play draw animaton
			anim.play("Draw")


	func _hide() -> void:
		# Check is visible
		if mesh.visible:
			# Play hide animaton
			anim.play("Hide")


	func _sprint(sprint: bool, delta: float) -> void:
		if sprint and character.direction:
			mesh.rotation.x = lerp(mesh.rotation.x, -deg2rad(40.0), 5.0 * delta)
		else:
			mesh.rotation.x = lerp(mesh.rotation.x, 0.0, 5.0 * delta)


	func _shoot(delta: float) -> void:
		# Get audio node
		var audio = owner.get_node("{}/audio".format([name], "{}"))

		# Get effects node
		var effect = owner.get_node("{}/effect".format([name], "{}"))
		
		if bullets > 0:
			# Play shoot animation if not reloading
			if animc != "Shoot" and animc != "Reload" and animc != "Draw" and animc != "Hide":
				bullets -= 1

				# recoil
				var rot = camera.rotation
				camera.rotation.x = lerp(rot.x, rand_range(1.0, 2.0), delta)
				camera.rotation.y = lerp(rot.y, rand_range(-1.0, 1.0), delta)

				# Shake the camera
				camera.shake_force = 0.002
				camera.shake_time = 0.2

				# Change light energy
				effect.get_node("shoot").light_energy = 2

				# Emitt fire particles
				effect.get_node("fire").emitting = true

				# Emitt smoke particles
				effect.get_node("smoke").emitting = true

				# Play shoot sound
				audio.get_node("shoot").pitch_scale = rand_range(0.9, 1.1)
				audio.get_node("shoot").play()

				# Play shoot animation using firate speed
				anim.play("Shoot", -1.0, firerate)

				# Get barrel node
				var barrel = owner.get_node("{}/barrel".format([name], "{}"))

				# Get main scene
				var main = root.get_child(0)

				# Create a instance of trail scene
				var trail = preload("res://data/scenes/trail.tscn").instance()

				# Change trail position to out of barrel position
				trail.translation = barrel.global_transform.origin

				# Change trail rotation to camera rotation
				trail.rotation = camera.global_transform.basis.get_euler()

				# Add the trail to main scene
				main.add_child(trail)

				# Get raycast weapon range
				var ray = owner.get_node("{}/ray".format([name], "{}"))

				# Check raycast is colliding
				if ray.is_colliding():
					var local_damage = int(rand_range(damage/1.5, damage))

					# Do damage
					if ray.get_collider() is RigidBody:
						ray.get_collider().apply_central_impulse(-ray.get_collision_normal() * (local_damage * 0.3))

					if ray.get_collider().is_in_group("prop"):
						if ray.get_collider().is_in_group("metal"):
							var spark: Particles = preload("res://data/scenes/spark.tscn").instance()

							# Add spark scene in collider
							ray.get_collider().add_child(spark)

							# Change spark position to collider position
							spark.global_transform.origin = ray.get_collision_point()

							spark.emitting = true

						if ray.get_collider().has_method("_damage"):
							ray.get_collider()._damage(local_damage)

					# Create a instance of decal scene
					var decal: Spatial = preload("res://data/scenes/decal.tscn").instance()

					# Add decal scene in collider
					ray.get_collider().add_child(decal)

					# Change decal position to collider position
					decal.global_transform.origin = ray.get_collision_point()

					# decal spins to collider normal
					decal.look_at(ray.get_collision_point() + ray.get_collision_normal(), decal_base)
		else:
			# Play out sound
			var out_audio: AudioStreamPlayer3D = audio.get_node("out")

			if not out_audio.playing:
				out_audio.pitch_scale = rand_range(0.9, 1.1)
				out_audio.play()


	func _reload() -> void:
		if bullets < max_bullets and ammo > 0:
			if animc != "Reload" and animc != "Shoot" and animc != "Draw" and animc != "Hide":
				# Play reload animation
				anim.play("Reload", 0.2, reload_speed)
				
				for b in ammo:
					bullets += 1
					ammo -= 1

					if bullets >= max_bullets:
						break


	func _zoom(input, delta: float) -> void:
		if input and animc != "Reload" and animc != "Hide" and animc != "Draw":
			camera.fov = lerp(camera.fov, 40.0, lerp_speed * delta)
			mesh.translation.y = lerp(mesh.translation.y, 0.001, lerp_speed * delta)
			mesh.translation.x = lerp(mesh.translation.x, -0.088, lerp_speed * delta)
		else:
			camera.fov = lerp(camera.fov, 70.0, lerp_speed * delta)
			mesh.translation.y = lerp(mesh.translation.y, 0.0, lerp_speed * delta)
			mesh.translation.x = lerp(mesh.translation.x, 0.0, lerp_speed * delta)


	func _update(delta: float) -> void:
		if animc != "Shoot":
			if arsenal.values()[owner.current] == self:
				camera.rotation.x = lerp(camera.rotation.x, 0.0, 10.0 * delta)
				camera.rotation.y = lerp(camera.rotation.y, 0.0, 10.0 * delta)

		# Get current animation
		animc = anim.current_animation

		# Get shoot effect node
		var shoot: OmniLight = owner.get_node("{}/effect/shoot".format([name], "{}"))

		# Change light energy
		shoot.light_energy = lerp(shoot.light_energy, 0.0, 5.0 * delta)

		# Remove recoil
		mesh.rotation.x = lerp(mesh.rotation.x, 0.0, 5.0 * delta)
