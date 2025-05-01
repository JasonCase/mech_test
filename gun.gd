class_name Gun extends RigidBody3D

const bullet_scene = preload("res://bullet.tscn")
@onready var muzzle = $MeshInstance3D/Muzzle
@onready var oscale = $MeshInstance3D.scale
@onready var smod = oscale * Vector3(1.2,1.2,1.2)

@export var VEL: int = 100
@export var DMG: int = 5

var shooting = false
var looking = false
var equipped: bool = false : 
	get(): return equipped
	set(value): 
		if value:
			freeze = true
			get_child(0).disabled = true
		else:
			freeze = false
			get_child(0).disabled = false
		equipped = value

signal fired(bullet)

func get_hit(n,p):
	p = to_local(p)
	apply_impulse(n*5,p)

func interact(interacting: bool,player_node: Player) -> void:
	$MeshInstance3D.scale = smod
	if interacting:
		if player_node.shoulder_mount.get_child_count() == 0:
			player_node.equip_gun(self)

func shoot() -> void:
	var bullet = bullet_scene.instantiate()
	var b_scale = bullet.scale
	shooting = true
	bullet.spd = VEL
	bullet.transform = muzzle.global_transform
	bullet.scale = b_scale
	
	fired.emit(bullet)
	
func _process(_delta: float) -> void:
	if !looking:
		$MeshInstance3D.scale = oscale
	
	shooting = false 
	looking = false
