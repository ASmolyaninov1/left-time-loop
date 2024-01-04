extends KinematicBody2D
signal hit

export var speed = 400
export var gravity = 900
export var jump_force = -400
onready var screen_size = get_viewport_rect().size
var velocity = Vector2.ZERO
var jump_counter = 0
var max_jumps = 2
var is_attack_finished = true

func _ready():
	hide()
	$AnimatedSprite.play()

var falling = 0

func _gravitation(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y > 2000:
			velocity.y = 2000

func _jump():
	if is_on_floor():
		jump_counter = 0
	
	if jump_counter < max_jumps and Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_force
		jump_counter += 1
		
	if  velocity.y < 0 and Input.is_action_just_released("ui_accept"):
		falling = 20
	if falling > 0:
		velocity.y += falling
	if falling > 0:
		falling += 20
	if falling > 50:
		falling = 0
		
func _animations():
	if velocity.x != 0:
		$AnimatedSprite.flip_h = velocity.x < 0

	if is_attack_finished:
		if velocity == Vector2.ZERO:
			$AnimatedSprite.animation = "stay"
		elif velocity.x != 0 and is_on_floor():
			$AnimatedSprite.animation = "walk"
		elif velocity.y < -10:
			$AnimatedSprite.animation = "jump"
		elif velocity.y > 10:
			$AnimatedSprite.animation = "fall"
		
	if Input.is_action_just_pressed('attack'):
		$AnimatedSprite.animation = "attack"
		is_attack_finished = false

func _process(delta):
	velocity.x = 0
	if Input.is_action_pressed("move_right"):
		velocity.x += speed
	if Input.is_action_pressed("move_left"):
		velocity.x -= speed
	
	_gravitation(delta)
	_jump()

	velocity = move_and_slide(velocity, Vector2.UP)
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


func _on_AnimatedSprite_animation_finished():
	if ($AnimatedSprite.animation == "attack"):
		is_attack_finished = true
