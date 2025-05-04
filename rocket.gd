extends Projectile

@onready var collision_box: Area3D = $Area3D

var target: Marker3D
var turn_speed: float = 10
var rot: Vector3 = Vector3()


func calculate_ray_target(delta: float) -> void:
	var ray_length: float = spd * delta
	if target:
		var target_direction: Vector3 = (target.global_position - global_position).normalized()
		var current_direction: Vector3 = -transform.basis.z.normalized()
		var new_direction: Vector3 = current_direction.lerp(target_direction,turn_speed*delta).normalized()
		
		look_at(global_position + new_direction,Vector3.UP)
		
	ray.target_position.y = ray_length


func set_fired_from(from: Node3D):
	super.set_fired_from(from)
	if fired_from != null and fired_from.has_node("Laser/LaserDesignator"):
		target = fired_from.get_node("Laser/LaserDesignator")
		print(target)
	else:
		target = null

func _process(delta: float) -> void:
	#if len(collision_box.get_overlapping_bodies()) != 0: hit()
	update_projectile(delta)
