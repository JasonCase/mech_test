extends Node3D

func _on_player_fired(bullet: Variant) -> void:
	add_child(bullet)
