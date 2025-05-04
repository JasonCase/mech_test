extends Node3D

@export var debug_scene = preload("res://debug_marker.tscn")
@export var explosion_radius: float = 10
@export var force: float = 10
@export var ray_count: int = 2500


#@onready var coords: Array = generate_coordinates(ray_count)

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
		var query = PhysicsRayQueryParameters3D.create(position,coord * explosion_radius)
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
		add_child(debug_hit)
		debug_hit.global_position = collision.position

func generate_impulse(collisions: Array) -> void:
	for collision in collisions:
		var collider: Object = collision.collider
		var direction: Vector3 = collision.direction
		var pos: Vector3 = collision.position
		
		if collider is RigidBody3D:
			collider.apply_impulse(direction * force, pos)
			

func _ready() -> void:
	var coords: Array = generate_coordinates(ray_count)
	var collisions: Array = process_rays(coords)
	generate_impulse(collisions)
	draw_debug(collisions)
	queue_free()
	
