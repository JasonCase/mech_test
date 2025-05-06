extends RigidBody3D

@export var permanent: bool = true
@export var lifetime: float = 3
@export var frozen: bool = false

func get_hit(_a,_b,_f):
	var player: Player = get_tree().current_scene.get_node_or_null("Player")
	if player:
		var dist: float = (global_position - player.global_position).length()
		print(str(int(dist)) + " meters")
		
	if !permanent:
		queue_free()

func _ready() -> void:
	$Timer.stop()  # Ensure stopped before setting wait_time
	$Timer.wait_time = lifetime
	$Timer.start()
	freeze = frozen


func _on_timer_timeout() -> void:
	if !permanent:
		queue_free()
