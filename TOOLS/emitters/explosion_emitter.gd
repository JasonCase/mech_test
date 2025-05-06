extends Node3D

@onready var smoke: GPUParticles3D = $Smoke
@onready var sparks: GPUParticles3D = $Sparks
@onready var fire: GPUParticles3D = $Fire


func generate_explosion() -> void:
	smoke.emitting = true
	sparks.emitting = true
	fire.emitting = true
	
	await get_tree().create_timer(5).timeout
	queue_free()
