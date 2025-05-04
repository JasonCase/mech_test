extends Node3D

func take_hit(n: Vector3,p: Vector3, f: float) -> void:
	if get_parent().has_method("get_hit"): 
		get_parent().get_hit(n,p,f)
	else:
		if get_parent() is RigidBody3D:
			p = to_local(p)
			get_parent().apply_impulse(n*f,p)
