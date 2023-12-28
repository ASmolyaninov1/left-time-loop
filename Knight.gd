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
	
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y += jump_force
		jump_counter += 1
	
	if not is_on_floor() and Input.is_action_just_pressed("ui_accept") and jump_counter < max_jumps:
		velocity.y += jump_force/2
		if velocity.y > jump_force/2:
			velocity.y += jump_force/2
		
		jump_counter += 1
		print(velocity.y)
		
	if  velocity.y < 0 and Input.is_action_just_released("ui_accept"):
		falling = 20
	if falling > 0:
		velocity.y += falling
	if falling > 0:
		falling += 20
	if falling > 50:
		falling = 0

	velocity = move_and_slide(velocity, Vector2.UP)

	if velocity.length() > 0:
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
	
	if velocity.x != 0:
		$AnimatedSprite.animation = "walk"
		$AnimatedSprite.flip_v = false
		# See the note below about boolean assignment.
		$AnimatedSprite.flip_h = velocity.x < 0
	#elif velocity.y != 0:
		#$AnimatedSprite.animation = "up"


func _on_Player_body_entered(_body):
	hide() # Player disappears after being hit.
	emit_signal("hit")
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
