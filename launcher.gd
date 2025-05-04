extends Gun

@onready var laser: RayCast3D = $Laser
@onready var laser_designator: Marker3D = $Laser/LaserDesignator
@export var laser_range: float = 100



func update_marker():
	if laser.is_colliding():
		var col_p: Vector3 = laser.get_collision_point()
		laser_designator.global_position = col_p
	else:
		laser_designator.global_position = laser.global_transform.origin + laser.global_transform.basis.x * laser.target_position.x

		

func _ready() -> void:
	if laser:
		laser.target_position.x = laser_range

func _process(delta: float) -> void:
	super._process(delta)
	
	update_marker()
	
