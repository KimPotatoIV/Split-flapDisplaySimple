extends Node2D

const DIGIT_CELL_SCENE: PackedScene = preload("res://scenes/digit_cell/digit_cell.tscn")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		var cell: DigitCell = DIGIT_CELL_SCENE.instantiate()
		add_child(cell)
		cell.position = Vector2(300, 0)
		cell.set_digit(9)
