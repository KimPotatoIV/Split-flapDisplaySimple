"""
▶▶▶ digit_cell.gd ◀◀◀

- 숫자 하나(0~9)를 표시하는 스플릿 플랩 셀 하나를 담당
- Cell 씬(위쪽, 아래쪽, 플립용)을 조합해서
  위에서 아래로 판이 넘어가며 숫자가 바뀌는 연출을 만듦

- 값이 여러 번 빠르게 바뀌어도(예: 초가 9→0으로 넘어가며 동시에 분도 바뀔 때)
  숫자를 건너뛰지 않고 0→1→2...처럼 한 칸씩 순서대로 넘기기 위해
  target_value, current_value, is_animating 세 변수로
  애니메이션 큐를 관리
"""

extends Node2D

class_name DigitCell

##################################################
const CELL_SIZE: Vector2 = Vector2(120.0, 90.0)
const HALF_LINE_SIZE: Vector2 = Vector2(120.0, 4.0)
const FLIP_DURATION: float = 0.1

var current_value: int = -1		# 지금 화면에 실제로 표시 중인 숫자
var target_value: int = -1		# 최종적으로 도달해야 하는 숫자
var is_animating: bool = false	# 현재 플립 애니메이션이 진행 중인지 여부
var flip_upper_local_pos: Vector2
var flip_lower_local_pos: Vector2

@export var upper_textures: Array[Texture2D] = []
@export var lower_textures: Array[Texture2D] = []

@onready var cell_upper_node: Node2D = $CellUpper
@onready var cell_lower_node: Node2D = $CellLower
@onready var half_line_node: ColorRect = $HalfLine
@onready var flip_pivot_node: Node2D = $FlipPivot
@onready var flip_node: Node2D = $FlipPivot/Flip

##################################################
func _ready() -> void:
	"""
	- CellUpper 노드는 셀의 원점(0,0)에 그대로,
	  CellLower 노드는 그 바로 아래에 배치
	- 두 패널 사이에 HalfLine(그림자 라인) 노드만큼 틈을 벌려서
	  실제 전광판의 이음매처럼 보이게 함
	"""
	cell_upper_node.position = Vector2.ZERO
	
	cell_lower_node.position = \
		Vector2(Vector2.ZERO.x, CELL_SIZE.y + HALF_LINE_SIZE.y)
	
	half_line_node.custom_minimum_size = HALF_LINE_SIZE
	half_line_node.position = Vector2(Vector2.ZERO.x, CELL_SIZE.y)
	
	"""
	- FlipPivot 노드는 실제 이미지가 아니라 회전축(힌지) 역할만 하는
	  빈 Node2D로 CellUpper 노드와 CellLower 노드 사이,
	  HalfLine의 정중앙에 위치시켜야 scale.y를 조정했을 때
	  그 라인을 기준으로 접혔다 펴지는 것처럼 보임
	"""
	flip_pivot_node.position = \
		Vector2(Vector2.ZERO.x, CELL_SIZE.y + HALF_LINE_SIZE.y / 2.0)
	
	"""
	- Flip(자식 Cell) 노드는 FlipPivot의 로컬 좌표계를 따르므로,
	  Pivot이 힌지로 내려간 만큼을 다시 빼줘야
	  화면상으로는 CellUpper/CellLower 노드와 정확히 같은 자리에 겹쳐 보임
	"""
	flip_upper_local_pos = \
		Vector2(0.0, -(CELL_SIZE.y + HALF_LINE_SIZE.y / 2.0))
	flip_lower_local_pos = Vector2(0.0, HALF_LINE_SIZE.y / 2.0)
	
	"""
	- z_index를 높여서 Flip 노드가 애니메이션 도중 HalfLine이나
	  다른 셀에 가려지지 않고 항상 맨 위에 그려지도록 함
	- 평소(애니메이션 없을 때)엔 안 보이게 숨겨둠
	"""
	flip_pivot_node.z_index = 10
	flip_pivot_node.visible = false
	
	_set_digit_instant(0)

##################################################
"""
- 애니메이션 없이 즉시 숫자를 표시하는 함수로
  씬이 처음 시작될 때 깜빡임 없이 바로 0을 보여주기 위해 사용
"""
func _set_digit_instant(value: int) -> void:
	cell_upper_node.set_texture(upper_textures[value])
	cell_lower_node.set_texture(lower_textures[value])
	current_value = value
	target_value = value

##################################################
"""
- 외부(Main 등)에서 호출하는 진입점으로
  같은 값이면 아무 것도 하지 않고, 다르면 target_value만 갱신

- 이미 애니메이션이 진행 중일 때 호출되어도 여기서 새 애니메이션을
  바로 시작하지 않는 게 핵심으로 target_value만 바꿔두면
  현재 진행 중인 _run_flip_sequence()의 while 루프가
  알아서 새 목표까지 이어서 처리해줌 (숫자 건너뛰기 방지)
"""
func set_digit(new_value: int) -> void:
	if new_value == target_value:
		return
	
	target_value = new_value
	
	if not is_animating:
		_run_flip_sequence()

##################################################
"""
- current_value가 target_value에 도달할 때까지
  0→1→2...→9→0 순서로 한 칸씩 플립을 반복하는 함수

  예) 초가 8에서 갑자기 그 다음 프레임에 target이 0으로 바뀌어도
      8→9→0 순서로 자연스럽게 넘어감
	  (9를 건너뛰고 바로 0으로 점프하지 않음)
"""
func _run_flip_sequence() -> void:
	is_animating = true
	
	while current_value != target_value:
		var next_value: int = (current_value + 1) % 10
		# await을 사용하면 _flip_once() 함수가 끝날 때까지 여기서 기다림
		await _flip_once(next_value)
	
	is_animating = false

##################################################
"""
- 숫자 한 칸(예: 3→4)을 실제로 플립하는 애니메이션 함수
"""
func _flip_once(new_value: int) -> void:
	var old_value: int = current_value
	current_value = new_value
	
	# CellUpper 노드를 미리 새 숫자로 바꿔둠
	cell_upper_node.set_texture(upper_textures[new_value])
	
	# Flip 노드에 old 값의 윗부분을 넣음
	flip_node.set_texture(upper_textures[old_value])
	flip_node.position = flip_upper_local_pos
	flip_pivot_node.scale.y = 1.0
	flip_pivot_node.visible = true
	
	SM.play_flap_clack_sound()
	
	# 힌지 쪽으로 접히며 사라짐
	var tw_close: Tween = create_tween()
	tw_close.tween_property(flip_pivot_node, "scale:y", 0.0, \
		FLIP_DURATION).set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
	await tw_close.finished
	
	# Flip 노드를 새 숫자의 아랫부분으로 바꿈
	flip_node.set_texture(lower_textures[new_value])
	flip_node.position = flip_lower_local_pos
	
	# Flip 노드가 힌지에서 펼쳐지며 새 아랫부분을 보여줌
	var tw_open: Tween = create_tween()
	tw_open.tween_property(flip_pivot_node, "scale:y", 1.0, \
		FLIP_DURATION).set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	await tw_open.finished
	
	# CellLower 노드도 새 숫자로 교체
	cell_lower_node.set_texture(lower_textures[new_value])
	
	# 다 펼쳐지면 Flip은 숨기고 종료
	flip_pivot_node.visible = false
