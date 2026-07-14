extends Node2D

##################################################
const DIGIT_CELL_SCENE: PackedScene = preload("res://scenes/digit_cell/digit_cell.tscn")
const CELL_SIZE: Vector2 = Vector2(120.0, 90.0)
const CELL_SPACING: float = 20.0

var digit_cells: Array[DigitCell] = []

##################################################
func _ready() -> void:
	pass

##################################################
func _update_time() -> void:
	var t: Dictionary = Time.get_time_dict_from_system()
	var digits: Array[int] = [
		t.hour / 10, t.hour % 10,
		t.minute / 10, t.minute % 10,
		t.second / 10, t.second % 10,
	]
	for i in digits.size():
		digit_cells[i].set_digit(digits[i])
