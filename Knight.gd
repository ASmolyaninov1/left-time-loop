extends CharacterBody2D
signal hit

@export var speed = 400
@export var gravity = 900
@export var jump_force = -400
@onready var screen_size = get_viewport_rect().size
var custom_velocity = Vector2.ZERO
var jump_counter = 0
var max_jumps = 2
var is_attack_finished = true

func _ready():
	hide()
	$AnimatedSprite2D.play()

var falling = 0

func _gravitation(delta):
	if not is_on_floor():
		custom_velocity.y += gravity * delta
		if custom_velocity.y > 2000:
			custom_velocity.y = 2000

func _jump():
	if is_on_floor():
		jump_counter = 0
	
	if jump_counter < max_jumps and Input.is_action_just_pressed("ui_accept"):
		custom_velocity.y = jump_force
		jump_counter += 1
		
	if  custom_velocity.y < 0 and Input.is_action_just_released("ui_accept"):
		falling = 20
	if falling > 0:
		custom_velocity.y += falling
	if falling > 0:
		falling += 20
	if falling > 50:
		falling = 0
		
func _animations():
	if custom_velocity.x != 0:
		$AnimatedSprite2D.flip_h = custom_velocity.x < 0

	if is_attack_finished:
		if custom_velocity == Vector2.ZERO:
			$AnimatedSprite2D.animation = "stay"
		elif custom_velocity.x != 0 and is_on_floor():
			$AnimatedSprite2D.animation = "walk"
		elif custom_velocity.y < -10:
			$AnimatedSprite2D.animation = "jump"
		elif custom_velocity.y > 10:
			$AnimatedSprite2D.animation = "fall"
		
	if Input.is_action_just_pressed('attack'):
		$AnimatedSprite2D.animation = "attack"
		is_attack_finished = false

var push_force = 80.0

func _process(delta):
	custom_velocity.x = 0
	if Input.is_action_pressed("move_right"):
		custom_velocity.x += speed
	if Input.is_action_pressed("move_left"):
		custom_velocity.x -= speed
	
	_gravitation(delta)
	_jump()

	set_velocity(custom_velocity)
	set_up_direction(Vector2.UP)
	move_and_slide()
	custom_velocity = velocity
	
	_animations()


func _on_Player_body_entered(_body):
	hide() # Player disappears after being hit.
	emit_signal("hit")
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func _on_animated_sprite_2d_animation_looped():
	if ($AnimatedSprite2D.animation == "attack"):
		is_attack_finished = true
