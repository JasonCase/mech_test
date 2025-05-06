extends Node3D

@export var target: PackedScene = preload("res://PREFABS/test_prefabs/targets/target_1m.tscn")
@export var frequency: float = 1
@export var vel: float = 1
@export var permanent: bool = false
@export var lifetime: float = 3

func _ready() -> void:
	$Timer.wait_time = frequency
	$Timer.start()

func _on_timer_timeout() -> void:
	var target_instance: RigidBody3D = target.instantiate()
	target_instance.permanent = permanent
	target_instance.lifetime = lifetime
	add_child(target_instance)
	target_instance.global_rotation = Vector3(0,0,0)
	target_instance.apply_impulse(-global_basis.z.normalized()*vel,Vector3.ZERO)
