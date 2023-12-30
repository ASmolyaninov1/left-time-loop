extends KinematicBody2D
signal hit

export var speed = 400
export var gravity = 900
export var jump_force = -400
onready var screen_size = get_viewport_rect().size
var velocity = Vector2.ZERO

func _ready():
	hide()

func _process(delta):
	velocity.x = 0
	if Input.is_action_pressed("move_right"):
		velocity.x += speed
	if Input.is_action_pressed("move_left"):
		velocity.x -= speed
	
	velocity.y += gravity * delta
	
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y += jump_force

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
	elif velocity.y != 0:
		$AnimatedSprite.animation = "up"


func _on_Player_body_entered(_body):
	hide() # Player disappears after being hit.
	emit_signal("hit")
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
