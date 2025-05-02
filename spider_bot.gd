extends Node3D

@export var BR: Marker3D
@export var BL: Marker3D
@export var FR: Marker3D
@export var FL: Marker3D

@export var BRT: Marker3D
@export var BLT: Marker3D
@export var FRT: Marker3D
@export var FLT: Marker3D

@onready var hb: CollisionShape3D = $CollisionShape3D

var tdist: float = 3.

func _ready() -> void:
	return
	
func dist(point_a: Marker3D,point_b: Marker3D) -> float:
	var distance: float = (point_a.global_position-point_b.global_position).length()
	#print(distance)
	return distance
	
func _physics_process(_delta: float) -> void:
	#if hb.global_position.y <=3:
	#	hb.global_position.y = 3
		
	if dist(BR,BRT) >= tdist:
		BR.global_position = BRT.global_position
	if dist(BL,BLT) >= tdist:
		BL.global_position = BLT.global_position
	if dist(FR,FRT) >= tdist:
		FR.global_position = FRT.global_position
	if dist(FL,FLT) >= tdist:
		FL.global_position = FLT.global_position
