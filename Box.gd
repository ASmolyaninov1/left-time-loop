extends RigidBody2D

@export var hp = 2
var punch_counter = 0

func break_punch():
	if (punch_counter > hp):
		queue_free()
	punch_counter += 1
