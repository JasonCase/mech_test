class_name Projectile extends Node3D

@export var bh_scene: PackedScene= preload("res://bullet_hole.tscn")

@onready var ray: RayCast3D = $RayCast3D

var spd: int

func hit() -> void:
	var col_p: Vector3 = ray.get_collision_point()
	var col_n: Vector3 = ray.get_collision_normal()
	var bh: Node3D = bh_scene.instantiate()
	var hit_object: Object = ray.get_collider()
	hit_object.add_child(bh)
	bh.global_transform.origin = col_p
	bh.look_at(col_p+col_n+Vector3(0.001,0.001,0.001),Vector3.UP)
	position = col_p
	
	if hit_object.has_method("get_hit"):
		hit_object.get_hit(transform.basis.y.normalized(),col_p)
	
	queue_free()
		

func _physics_process(delta: float):
	var ray_length: float = spd * delta * 1
	ray.target_position.y = ray_length
	ray.force_raycast_update()
	
	if ray.is_colliding():
		hit()
	else:
		position += transform.basis.y * spd * delta
