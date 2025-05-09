class_name Explosion extends Node3D

@export var debug_scene: PackedScene = preload("res://TOOLS/debug/debug_marker/debug_marker.tscn")
@export var particle_scene: PackedScene = preload("res://TOOLS/emitters/explosion_emitter.tscn")

@export var explosion_radius: float = 10
@export var force: float = 1
@export var ray_count: int = 2500
@export var debug: bool = false

func generate_coordinates(count: int) -> Array:
	var coordinates: Array = []
	for i in count:
		var phi: float = randf_range(0.0,TAU)
		var theta: float = randf_range(0.0,PI)
		
		var x: float = sin(theta) * cos(phi)
		var y: float = cos(theta)
		var z: float = sin(theta) * sin(phi)
		
		coordinates.append(Vector3(x,y,z))
		
	return coordinates

func process_rays(coordinates: Array) -> Array:
	var collisions: Array = []
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	for coord in coordinates:
		coord *= explosion_radius
		var query = PhysicsRayQueryParameters3D.create(global_position,global_position + coord)
		query.hit_back_faces = false
		var collision = space.intersect_ray(query)
		
		if len(collision) != 0:
			var hit_data: Dictionary = {
				"collider": collision.collider,
				"position": collision.position,
				"normal": collision.normal,
				"direction": coord
			}
			
			collisions.append(hit_data)
		
	return collisions
	

func draw_debug(collisions: Array) -> void:
	for collision in collisions:
		var debug_hit = debug_scene.instantiate()
		#var pos: Vector3 = collision.position
		#var distance: float = (collision.position - position).length()
		#var mesh: Mesh = debug_hit.mesh.duplicate(true)
		#var mat: StandardMaterial3D = (mesh.material as StandardMaterial3D).duplicate(true)
		#mat.albedo_color = Color(1,1,1) * distance
		add_child(debug_hit)
		debug_hit.global_position = collision.position
		debug_hit.reparent(get_parent().get_parent())

func generate_impulse(collisions: Array) -> void:
	for collision in collisions:
		var collider: Object = collision.collider
		var direction: Vector3 = collision.direction
		var pos: Vector3 = collision.position
		var distance: float = (collision.position - position).length()
		
		if collider is RigidBody3D:
			collider.apply_impulse(direction * force / distance, pos)
			

func generate_explosion() -> void:
	var coords: Array = generate_coordinates(ray_count)
	var collisions: Array = process_rays(coords)
	var particles: Node3D = particle_scene.instantiate()
	get_tree().current_scene.add_child(particles)
	particles.global_position = global_position
	particles.generate_explosion()
	generate_impulse(collisions)
	if debug == true:
		draw_debug(collisions)
	$AudioStreamPlayer3D.reparent(get_tree().current_scene)
	queue_free()
	

	
