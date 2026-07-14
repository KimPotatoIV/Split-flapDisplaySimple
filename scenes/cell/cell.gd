extends Node2D

##################################################
@onready var sprite_2d_node: Sprite2D = $Sprite2D

##################################################
func _ready() -> void:
	sprite_2d_node.centered = false

##################################################
func set_texture(texture_value: Texture2D) -> void:
	sprite_2d_node.texture = texture_value
