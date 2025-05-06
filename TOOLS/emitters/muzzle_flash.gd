extends Node3D

@onready var flash_emitter: GPUParticles3D = $FlashEmitter
@onready var smoke: GPUParticles3D = $Smoke

func flash() -> void:
	flash_emitter.restart()
	smoke.restart()
	
func reset() -> void:
	flash_emitter.emitting = false
	smoke.emitting = false
