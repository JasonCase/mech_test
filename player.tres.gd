extends CharacterBody3D

@onready var animation_tree = $AnimationTree
@onready var shoulder_mount = $CharacterArmature/Skeleton3D/BoneAttachment3D/ShoulderMount

@onready var LHand = $CharacterArmature/Skeleton3D/LHand
@onready var RHand = $CharacterArmature/Skeleton3D/RHand

signal fired(bullet)

const JUMP_VELOCITY = 4.5

var SPEED = 4.0
var sens = 0.004
var xrot = 0.0
var yrot = 0.0
var maxangle = 70.0

var hasgun = false

func equip_gun(gun_path) -> void:
	var gun_scene = load(gun_path)
	var gun = gun_scene.instantiate() as Gun
	
	gun.connect("fired",has_fired)
	
	gun.scale *= 25
	shoulder_mount.add_child(gun)
	LHand.target_node = NodePath(str(gun.get_path())+"/MeshInstance3D/Grip")
	RHand.target_node = NodePath(str(gun.get_path())+"/MeshInstance3D/Trigger")
	hasgun = true

func has_fired(bullet) -> void:
	fired.emit(bullet)

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func camera_control(event) -> void:
	if event is InputEventMouseMotion:
		xrot -= event.relative.x * sens
		yrot -= event.relative.y * sens
		yrot = clamp(yrot,deg_to_rad(-maxangle),deg_to_rad(maxangle))
		

func move(delta) -> void:
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
		
func hand_IK(delta) -> void:
	if hasgun:
		LHand.start(false)
		RHand.start(false)
		if LHand.get_influence() != 1:
			LHand.set_influence(lerp(LHand.get_influence(),1,delta))
		if RHand.get_influence() != 1:
			RHand.set_influence(lerp(RHand.get_influence(),1,delta))
	else:
		LHand.start(true)
		RHand.start(true)
		
	$CharacterArmature/Skeleton3D/Torso.start(false)
		
func animate() -> void:
	if abs(velocity.x)+abs(velocity.z) <= .5:
		animation_tree.set("parameters/Blend2/blend_amount",0)
	elif abs(velocity.x)+abs(velocity.z) >= 4:
		animation_tree.set("parameters/Blend2/blend_amount",1)
		if abs(velocity.x)+abs(velocity.z) >= 7:
			animation_tree.set("parameters/Blend2 2/blend_amount",1)
		else:
			animation_tree.set("parameters/Blend2 2/blend_amount",0)
			
func handle_input(event) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("Ctrl"):
			if !hasgun:
				equip_gun("res://M4.tscn")
			else:
				shoulder_mount.get_child(0).queue_free() 
				hasgun = false
		if event.is_action_pressed("ui_cancel"):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if event.is_action_pressed("Shift"):
			SPEED = 7.0
		if event.is_action_released("Shift"):
			SPEED = 4.0
	elif event is InputEventMouseButton:
		if shoulder_mount.get_child_count() != 0 && shoulder_mount.get_child(0) is Gun:
			if event.is_action_pressed("Left_Click"):
				(shoulder_mount.get_child(0) as Gun).shoot()
			elif event.is_action_pressed("Right_Click"):
				$SpringArm3D.spring_length = 0.3
				#$AnimationTree.active = false
				$AnimationTree.set("parameters/Blend2 3/blend_amount",1)
			elif event.is_action_released("Right_Click"):
				$SpringArm3D.spring_length = 2
				#$AnimationTree.active = true
				$AnimationTree.set("parameters/Blend2 3/blend_amount",0)

func _unhandled_input(event: InputEvent) -> void:
	camera_control(event)
	handle_input(event)
	

func _process(delta: float) -> void:
	rotation.y = xrot
	$SpringArm3D.rotation.x = yrot
	$TorsoPivot.rotation.x = -yrot

func _physics_process(delta: float) -> void:
	hand_IK(delta)
	move(delta)
	animate()

	move_and_slide()
