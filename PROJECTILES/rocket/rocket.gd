extends Projectile

@export var explosion_scene: PackedScene = preload("res://TOOLS/emitters/explosion/explosion.tscn")
@export var trail_scene: PackedScene = preload("res://TOOLS/emitters/smoke_trail.tscn")
@export var turn_speed: float = 1
@export var lifetime: float = 10


var target: Marker3D
var laser: RayCast3D

var rot: Vector3 = Vector3()

var straight: Vector3

func calculate_ray_target(delta: float) -> void:
	var ray_length: float = spd * delta * 10
	if target and laser.enabled :
		var target_direction: Vector3 = (target.global_position - global_position).normalized()
		var current_direction: Vector3 = -transform.basis.z.normalized()
		var new_direction: Vector3 = current_direction.lerp(target_direction,turn_speed*delta).normalized()
		
		look_at(global_position + new_direction,Vector3.UP)
	else:
		look_at(straight+global_position,Vector3.UP)
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
		laser = fired_from.get_node("Laser")
	else:
		target = null
	straight = -fired_from.global_basis.z
	
func _ready() -> void:
	$Timer.wait_time = lifetime
	$Timer.start()
	


func _process(delta: float) -> void:
	#$Camera3D.current = true
	print($Warhead.global_position)
	var trail: Node3D = trail_scene.instantiate()
	get_tree().current_scene.add_child(trail)
	trail.global_position = $Exhaust.global_position
	trail.look_at(trail.global_position + transform.basis.z,Vector3.UP)
	trail.get_node("TrailEmitter").emitting = true
	update_projectile(delta)
	
func _on_timer_timeout() -> void:
	hit()
