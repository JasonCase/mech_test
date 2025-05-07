class_name Projectile extends Node3D

@export var bh_scene: PackedScene= preload("res://PROJECTILES/decals/bullet_hole.tscn")
 
@onready var ray: RayCast3D = $RayCast3D

@export var spd: int = 100
@export var spawns_decal: bool = true
@export var force: float = 5

var fired_from: Node3D

func spawn_decal(surface: Object, col_p: Vector3, col_n: Vector3) -> void:
	var bh: Node3D = bh_scene.instantiate()
	surface.add_child(bh)
	bh.global_transform.origin = col_p
	bh.look_at(col_p+col_n+Vector3(0.001,0.001,0.001),Vector3.UP)
	
	
	
func hit() -> void:
	var col_p: Vector3 = ray.get_collision_point()
	var col_n: Vector3 = ray.get_collision_normal()
	var hit_object: Object = ray.get_collider()
	
	if col_p == Vector3.ZERO:
		col_p = global_position
	
	position = col_p
	if hit_object:
		var HitReciever: Node3D = hit_object.get_node_or_null("HitReciever")
		if HitReciever:
			HitReciever.take_hit(-transform.basis.z.normalized(),col_p,force)
	
	on_hit(hit_object,col_p,col_n)
	queue_free()

func on_hit(hit_object,col_p,col_n) -> void:
	#hit_object.get_hit(-transform.basis.z.normalized(),col_p,force)
	if spawns_decal:
		spawn_decal(hit_object,col_p,col_n)

func update_projectile(delta: float) -> void:
	calculate_ray_target(delta)
	ray.force_raycast_update()
	
	if ray.is_colliding():
		hit()
	else:
		position += -transform.basis.z * spd * delta

func set_fired_from(from: Node3D) -> void:
	fired_from = from

func calculate_ray_target(delta) -> void:
	var ray_length: float = spd * delta * 1
	ray.target_position.z = -ray_length
	
func _physics_process(delta: float):
	update_projectile(delta)
