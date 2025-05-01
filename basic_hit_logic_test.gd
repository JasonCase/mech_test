extends RigidBody3D

var f = 50

func get_hit(n,p):
	p = to_local(p)
	apply_impulse(n*f,p)
