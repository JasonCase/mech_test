extends Projectile


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var gunshot: AudioStreamPlayer3D = get_node_or_null("Gunshot")
	if gunshot:
		gunshot.reparent(get_tree().current_scene)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
