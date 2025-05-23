class_name Gun extends RigidBody3D

@export var projectile_scene = preload("res://PROJECTILES/projectile/projectile.tscn")
@onready var muzzle = $MeshInstance3D/Muzzle
@onready var oscale = $MeshInstance3D.scale
@onready var smod = oscale * Vector3(1.2,1.2,1.2)
@onready var flash: Node3D =  get_node_or_null("MeshInstance3D/MuzzleFlash")

@export var DMG: int = 5
@export var RATE: float = 180
var shooting_cooldown: float

var looked_at: bool = false
var trigger_held: bool = false
var shooting: bool = false
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

signal fired(projectile)

func is_equipped() -> bool:
	return true if get_parent() is Marker3D else false

func interact(interacting: bool,player_node: Player) -> void:
	if interacting:
		if player_node.shoulder_mount.get_child_count() == 0 and !is_equipped():
			player_node.equip_gun(self)

func looking():
	if looked_at:
		$MeshInstance3D.scale = smod
	else:
		$MeshInstance3D.scale = oscale

func shoot() -> void:
	if shooting_cooldown > 0 or !trigger_held: return
	var projectile: Projectile = projectile_scene.instantiate()
	var b_scale: Vector3 = projectile.scale
	
	if flash:
		flash.flash()
	shooting = true
	projectile.transform = muzzle.global_transform
	projectile.scale = b_scale
	projectile.set_fired_from(self)
	
	fired.emit(projectile)
	
	shooting_cooldown = 60 / RATE 


func _process(delta: float) -> void:

	shooting = false 
	
	if trigger_held && is_equipped():
		shoot()
	else:
		trigger_held = false
		if flash:
			flash.reset()
		
	
	if shooting_cooldown > 0:
		shooting_cooldown -= delta
	
	looking()
