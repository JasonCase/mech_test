extends RigidBody3D

func get_hit(n,p,f):
	p = to_local(p)
	apply_impulse(n*f,p)
