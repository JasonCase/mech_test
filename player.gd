class_name Player extends CharacterBody3D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var shoulder_mount: Marker3D = $CharacterArmature/Skeleton3D/BoneAttachment3D/ShoulderMount

@onready var LHand: SkeletonIK3D = $CharacterArmature/Skeleton3D/LHand
@onready var RHand: SkeletonIK3D = $CharacterArmature/Skeleton3D/RHand
@onready var ray: RayCast3D = $CharacterArmature/Skeleton3D/BoneAttachment3D2/RayCast3D

@onready var camera: Camera3D = $SpringArm3D/Camera3D

signal fired(projectile: Projectile)

const JUMP_VELOCITY: float = 4.5

var SPEED: float = 4.0
var sens: float = 0.004
var xrot: float = 0.0
var yrot: float = 0.0
var max_angle: float = 70.0

var shoot_allowed: bool = true
var interacting: bool = false

var last_hit_object: Object

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func get_held_gun() -> Gun:
	if shoulder_mount.get_child_count() != 0 && shoulder_mount.get_child(0) is Gun:
		return shoulder_mount.get_child(0)
	else:
		return null

func gun_is_equipped() -> bool:
	return get_held_gun() != null

func equip_gun(gun: Gun) -> void:
	if !gun_is_equipped():
		if !gun.fired.is_connected(_on_fired):
			gun.connect("fired",_on_fired)

		if is_instance_valid(gun.get_parent()):
			gun.reparent(shoulder_mount)
		else:
			shoulder_mount.add_child(gun)

		gun.position = Vector3(0,0,0)
		gun.rotation = Vector3(0,0,0)
		gun.scale = Vector3(1,1,1)

		gun.equipped = true
		LHand.target_node = NodePath(str(gun.get_path())+"/MeshInstance3D/Grip")
		RHand.target_node = NodePath(str(gun.get_path())+"/MeshInstance3D/Trigger")

func drop_gun() -> void:
	var gun: Gun = get_held_gun()
	if !gun: return
	gun.reparent(get_parent())
	gun.linear_velocity = velocity
	gun.equipped = false

func _on_fired(projectile: Projectile) -> void:
	fired.emit(projectile)

func camera_control(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		xrot -= event.relative.x * sens
		yrot -= event.relative.y * sens
		yrot = clamp(yrot,deg_to_rad(-max_angle),deg_to_rad(max_angle))

func move(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var input_dir := Input.get_vector("A", "D", "W", "S")
	var direction :=Vector3(0,0,0)-(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func hand_IK(delta: float) -> void:
	if gun_is_equipped():
		if !LHand.is_running():
			LHand.start(false)
			RHand.start(false)
		if LHand.get_influence() != 1:
			LHand.set_influence(lerp(LHand.get_influence(),1,delta))
		if RHand.get_influence() != 1:
			RHand.set_influence(lerp(RHand.get_influence(),1,delta))
	else:
		if LHand.is_running():
			LHand.start(true)
			RHand.start(true)
		
	($CharacterArmature/Skeleton3D/Torso as SkeletonIK3D).start(false) 

func animate() -> void:
	if abs(velocity.x)+abs(velocity.z) <= .5:
		animation_tree.set("parameters/Blend2/blend_amount",0)
	elif abs(velocity.x)+abs(velocity.z) >= 4:
		animation_tree.set("parameters/Blend2/blend_amount",1)
		if abs(velocity.x)+abs(velocity.z) >= 7:
			animation_tree.set("parameters/Blend2 2/blend_amount",1)
		else:
			animation_tree.set("parameters/Blend2 2/blend_amount",0)

func handle_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if event.is_action_pressed("Shift"):
			SPEED = 7.0
		if event.is_action_released("Shift"):
			SPEED = 4.0
		if event.is_action_pressed("Interact"):
			interacting = true
		if event.is_action_released("Interact"):
			interacting = false
		if event.is_action_released("Drop"):
			drop_gun()

	elif event is InputEventMouseButton:
		var gun: Gun = get_held_gun()
		if gun && event.is_action_pressed("Left_Click"):
			gun.shoot()
		if event.is_action_pressed("Right_Click"):
			$SpringArm3D.spring_length = 0.3
			$AnimationTree.set("parameters/Blend2 3/blend_amount",1)

		elif event.is_action_released("Right_Click"):
			$SpringArm3D.spring_length = 2
			$AnimationTree.set("parameters/Blend2 3/blend_amount",0)


func trigger_held(allowed: bool) -> bool:
	return true if Input.is_action_pressed("Left_Click") and allowed else false

func check_interact(hit_object: Object) -> void:
		if hit_object.has_method("interact"):
			hit_object.interact(interacting,self)

func check_looking() -> void:
	var hit_object: Object = ray.get_collider()
	if ray.is_colliding():
		if hit_object.get("looked_at") != null and hit_object != last_hit_object:
			hit_object.looked_at = true
		check_interact(hit_object)
		
	if last_hit_object:
		if last_hit_object != hit_object and last_hit_object.get("looked_at") != null:
			last_hit_object.looked_at = false
		
	last_hit_object = hit_object

func _unhandled_input(event: InputEvent) -> void:
	camera_control(event)
	handle_input(event)

func _process(_delta: float) -> void:
	rotation.y = xrot
	($SpringArm3D as SpringArm3D).rotation.x = yrot
	($TorsoPivot as Node3D).rotation.x = -yrot
	

func _physics_process(delta: float) -> void:
	hand_IK(delta)
	move(delta)
	animate()
	check_looking()
	if gun_is_equipped():
		get_held_gun().trigger_held = trigger_held(shoot_allowed)
	move_and_slide()
