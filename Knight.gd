extends KinematicBody2D
signal hit

export var speed = 400
export var gravity = 900
export var jump_force = -400
onready var screen_size = get_viewport_rect().size
var velocity = Vector2.ZERO
var jump_counter = 0
var max_jumps = 2

func _ready():
	hide()
	$AnimatedSprite.play()

var falling = 0

func _process(delta):
	velocity.x = 0
	if Input.is_action_pressed("move_right"):
		velocity.x += speed
	if Input.is_action_pressed("move_left"):
		velocity.x -= speed
	
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y > 2000:
			velocity.y = 2000
	
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

	velocity = move_and_slide(velocity, Vector2.UP)
	
	$AnimatedSprite.flip_h = velocity.x < 0
	if velocity == Vector2.ZERO:
		$AnimatedSprite.animation = "stay"
	elif velocity.x != 0 and is_on_floor():
		$AnimatedSprite.animation = "walk"
	elif velocity.y < -10:
		$AnimatedSprite.animation = "jump"
	elif velocity.y > 10:
		$AnimatedSprite.animation = "fall"


func _on_Player_body_entered(_body):
	hide() # Player disappears after being hit.
	emit_signal("hit")
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
