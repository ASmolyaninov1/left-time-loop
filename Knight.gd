extends CharacterBody2D

@export var speed = 300.0
@export var max_speed = 400.0
@export var jump_force = -400.0
@export var max_jumps = 2
var is_attacking = false
var jump_counter = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	hide()

func _on_Player_body_entered(_body):
	hide() # Player disappears after being hit.
	emit_signal("hit")

func _physics_process(delta):
	var direction = Input.get_axis("move_left", "move_right")

	if not is_on_floor():
		velocity.y += gravity * delta
	
	_movement(direction)
	_jump()

	_switch_direction(direction)
	_animations()
	move_and_slide()

func _movement(direction: float):
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

func _jump():
	if is_on_floor():
		jump_counter = 0
	
	if jump_counter < max_jumps and Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_force
		jump_counter += 1
		
	if  velocity.y < 0 and Input.is_action_just_released("ui_accept"):
		velocity.y += 70
		
func _animations():
	if not is_attacking:
		if velocity == Vector2.ZERO:
			$AnimationPlayer.play("stay")
		elif velocity.x != 0 and is_on_floor():
			$AnimationPlayer.play("run")
		elif velocity.y < -10:
			$AnimationPlayer.play("jump")
		elif velocity.y > 10:
			$AnimationPlayer.play("fall")
		
	if Input.is_action_just_pressed("attack"):
		$AnimationPlayer.play("attack")
		is_attacking = true

var prev_direction = 1
func _switch_direction(direction: float):
	if direction && prev_direction != direction:
		prev_direction = direction
		scale.x = -scale.x

func start(pos):
	position = pos
	show()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "attack":
		is_attacking = false

func _on_brake_attack_body_entered(body):
	if is_instance_valid(body) and body.has_method('break_punch'):
		body.break_punch()

func _on_push_attack_body_entered(body):
	if is_instance_valid(body) and body is RigidBody2D:
		var offset = position - body.position
		var force = Vector2(500, 0)
		if offset.x > 0:
			force.x = -500
		body.apply_impulse(force, offset)
