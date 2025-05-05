extends Node3D

var delete = false

func _on_timer_timeout() -> void:
	delete = true
	
func _process(delta: float) -> void:
	if delete:
		scale = scale.move_toward(Vector3.ZERO,delta*1)
	if scale <= Vector3(0.01,0.01,0.01):
		queue_free()
