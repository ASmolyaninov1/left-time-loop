extends Node

func _ready():
	new_game()

func new_game():
	$Knight.start($StartPosition.position)
