class_name Launcher extends Gun

@onready var laser: RayCast3D = get_node_or_null("Laser")
@onready var laser_designator: Marker3D = get_node_or_null("Laser/LaserDesignator")
@export var laser_range: float = 500
@export var laser_guidance: bool = false



func update_marker():
	if laser.is_colliding():
		var col_p: Vector3 = laser.get_collision_point()
		laser_designator.global_position = col_p
	else:
		laser_designator.global_position = laser.global_transform.origin + laser.global_transform.basis.x * laser.target_position.x

func check_laser() -> bool:
	if laser_guidance: laser.enabled = true
	if laser and laser_designator:
		if laser.enabled:
			return true
		else:
			return false
	else:
		return false


func _process(delta: float) -> void:
	super._process(delta)
	if !laser_guidance:
		laser.enabled = false
		laser_designator.get_node("MeshInstance3D").visible = false
	if laser and check_laser():
		laser.target_position.x = laser_range
	
	
	update_marker()
	
