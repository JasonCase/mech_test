extends Projectile

@export var explosion_scene: PackedScene = preload("res://TOOLS/emitters/explosion/explosion.tscn")

var target: Marker3D
@export var turn_speed: float = 1
var rot: Vector3 = Vector3()


func calculate_ray_target(delta: float) -> void:
	var ray_length: float = spd * delta * 2
	if target:
		var target_direction: Vector3 = (target.global_position - global_position).normalized()
		var current_direction: Vector3 = -transform.basis.z.normalized()
		var new_direction: Vector3 = current_direction.lerp(target_direction,turn_speed*delta).normalized()
		
		look_at(global_position + new_direction,Vector3.UP)
		
	ray.target_position.y = ray_length

func on_hit(hit_object,col_p,col_n) -> void:
	super.on_hit(hit_object,col_p,col_n)
	var explosion: Explosion = explosion_scene.instantiate()
	add_child(explosion)
	explosion.global_position = $Warhead.global_position
	#explosion.call_deferred("generate_explosion")
	
	explosion.generate_explosion()

func set_fired_from(from: Node3D):
	super.set_fired_from(from)
	if fired_from != null and fired_from.has_node("Laser/LaserDesignator"):
		target = fired_from.get_node("Laser/LaserDesignator")
	else:
		target = null

func _process(delta: float) -> void:
	#$Camera3D.current = true
	update_projectile(delta)
	
	
	
