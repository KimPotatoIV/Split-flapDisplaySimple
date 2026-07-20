"""
▶▶▶ cell.gd ◀◀◀

- 스플릿 플랩 디스플레이의 가장 작은 단위로
  이미지(텍스처) 하나만 담당하는 "그릇" 역할을 하며
  위쪽, 아래쪽, 플립 패널 모두 이 씬을 재사용하여
  텍스처만 다르게 갈아 끼우는 방식으로 작동
"""

extends Node2D

##################################################
@onready var sprite_2d_node: Sprite2D = $Sprite2D

##################################################
func _ready() -> void:
	"""
	- Sprite2D는 기본적으로 centered = true(중심 정렬) 상태
	- 중심 정렬이면 노드의 position이 이미지의 가운데를 가리키게 되는데,
	  우리는 위/아래 패널을 딱 붙여서 배치해야 하므로
	  좌상단 모서리를 기준으로 삼는 게 훨씬 계산하기 편함
	- 그래서 centered를 false로 꺼서, position이 이미지의 왼쪽 위 모서리를
	  가리키도록 만들어줌
	"""
	sprite_2d_node.centered = false
	
	"""
	- 이미지 원본을 2배 해상도로 제작했기 때문에,
	  실제 화면에 표시할 때는 절반 크기로 줄여서 보여줌
	"""
	sprite_2d_node.scale = Vector2(0.5, 0.5)

##################################################
"""
- 외부(DigitCell 등)에서 이 Cell이 어떤 상태(이미지)를 보여줄지
  정해줄 때 호출하는 함수
"""
func set_texture(texture_value: Texture2D) -> void:
	sprite_2d_node.texture = texture_value
