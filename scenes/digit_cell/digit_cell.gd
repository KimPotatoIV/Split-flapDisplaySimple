extends Node2D

class_name DigitCell

##################################################
const CELL_SIZE: Vector2 = Vector2(240.0, 180.0)
const HALF_LINE_SIZE: Vector2 = Vector2(240.0, 4.0)
const FLIP_DURATION: float = 0.15

var current_value: int = -1
var flip_upper_local_pos: Vector2
var flip_lower_local_pos: Vector2

@export var upper_textures: Array[Texture2D] = []
@export var lower_textures: Array[Texture2D] = []

@onready var cell_upper_node: Node2D = $CellTop
@onready var cell_lower_node: Node2D = $CellBottom
@onready var half_line_node: ColorRect = $HalfLine
@onready var flip_pivot_node: Node2D = $FlipPivot
@onready var flip_node: Node2D = $FlipPivot/Flip

##################################################
func _ready() -> void:
	cell_upper_node.position = Vector2.ZERO
	
	cell_lower_node.position = \
		Vector2(Vector2.ZERO.x, CELL_SIZE.y + HALF_LINE_SIZE.y)
	
	half_line_node.custom_minimum_size = HALF_LINE_SIZE
	half_line_node.position = Vector2(Vector2.ZERO.x, CELL_SIZE.y)
	
	flip_pivot_node.position = \
		Vector2(Vector2.ZERO.x, CELL_SIZE.y + HALF_LINE_SIZE.y / 2.0)
	
	flip_upper_local_pos = \
		Vector2(0.0, -(CELL_SIZE.y + HALF_LINE_SIZE.y / 2.0))
	flip_lower_local_pos = Vector2(0.0, HALF_LINE_SIZE.y / 2.0)
	
	flip_pivot_node.z_index = 10
	flip_pivot_node.visible = false
	
	_set_digit_instant(0)

##################################################
func _set_digit_instant(value: int) -> void:
	cell_upper_node.set_texture(upper_textures[value])
	cell_lower_node.set_texture(lower_textures[value])
	current_value = value

##################################################
func set_digit(new_value: int) -> void:
	if new_value == current_value:
		return
	
	var old_value: int = current_value
	current_value = new_value
	
	flip_node.set_texture(upper_textures[old_value])
	flip_node.position = flip_upper_local_pos
	flip_pivot_node.scale.y = 1.0
	flip_pivot_node.visible = true
	
	var tw: Tween = create_tween()
	
	tw.tween_property(flip_pivot_node, "scale:y", 0.0, FLIP_DURATION)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	tw.tween_callback(func() -> void:
		flip_node.set_texture(lower_textures[new_value])
		flip_node.position = flip_lower_local_pos
		cell_lower_node.set_texture(lower_textures[new_value])
	)
	
	tw.tween_property(flip_pivot_node, "scale:y", 1.0, FLIP_DURATION)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	tw.tween_callback(func() -> void:
		cell_upper_node.set_texture(upper_textures[new_value])
		flip_pivot_node.visible = false
	)
