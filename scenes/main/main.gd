"""
▶▶▶ main.gd ◀◀◀

- 6개의 DigitCell(시2 + 분2 + 초2)과 구분자(":") 2개를 조합해서
  "HH:MM:SS" 형태의 스플릿 플랩 시계 전체를 완성하는 스크립트

- 역할 두 가지
  1) _layout_cells():	셀들을 가로로 겹치지 않게 배치
  2) _update_time():	1초마다 실제 시스템 시간을 읽어와서 각 셀에 반영
"""

extends Node2D

##################################################
const CELL_SIZE: Vector2 = Vector2(120.0, 90.0)
const CELL_SPACING: float = 8.0

@export var digit_cell_hour_list: Array[DigitCell] = []
@export var digit_cell_minute_list: Array[DigitCell] = []
@export var digit_cell_second_list: Array[DigitCell] = []

@onready var hm_separator_node: Node2D = $Display/HM
@onready var ms_separator_node: Node2D = $Display/MS
@onready var update_timer_node: Timer = $Display/UpdateTimer

##################################################
func _ready() -> void:
	_layout_cells()
	
	"""
	- 코드에서 Timer 옵션을 직접 지정해두면,
	  Inspector 설정을 깜빡 잊어도 항상 같은 동작이 보장됨
	"""
	update_timer_node.wait_time = 1.0
	update_timer_node.autostart = true
	
	# timeout 시그널이 울릴 때마다(1초마다) _update_time()을 호출하도록 연결
	update_timer_node.timeout.connect(_update_time)
	"""
	- autostart는 씬이 새로 트리에 들어갈 때 적용되는 옵션이기 때문에
	  이미 실행 중인 _ready() 함수 안에서 설정만 해서는 타이머가 돌아가지 않음
	- 그래서 start()를 직접 호출하여 확실히 시작 시킴
	"""
	update_timer_node.start()

##################################################
"""
각 숫자 셀의 x좌표를 계산해서 가로로 나란히 배치하는 함수
"""
func _layout_cells() -> void:
	# # 시(Hour) 자리 배치
	for i in digit_cell_hour_list.size():
		digit_cell_hour_list[i].position.x = \
			(CELL_SIZE.x + CELL_SPACING) * i
	
	"""
	- 직전 그룹이 끝나는 x좌표를 변수로 저장해두고,
	  다음 그룹은 그 지점부터 이어서 시작하는 방식으로 계산함
	"""
	# 시(Hour) 그룹이 끝나는 x좌표
	var hour_end_x: float = \
		(CELL_SIZE.x + CELL_SPACING) * digit_cell_hour_list.size()

	hm_separator_node.position.x = hour_end_x
	
	# 분(Minute) 자리 시작 x좌표: 시 그룹 끝 + 구분자 폭 + 간격
	var minute_start_x: float = hour_end_x + CELL_SIZE.x + CELL_SPACING
	for i in digit_cell_minute_list.size():
		digit_cell_minute_list[i].position.x = \
			minute_start_x + (CELL_SIZE.x + CELL_SPACING) * i
	
	# 분(Minute) 그룹이 끝나는 x좌표
	var minute_end_x: float = \
		minute_start_x + (CELL_SIZE.x + CELL_SPACING) * digit_cell_minute_list.size()
	ms_separator_node.position.x = minute_end_x
	
	# 초(Second) 자리 시작 x좌표: 분 그룹 끝 + 구분자 폭 + 간격
	var second_start_x: float = minute_end_x + CELL_SIZE.x + CELL_SPACING
	for i in digit_cell_second_list.size():
		digit_cell_second_list[i].position.x = \
			second_start_x + (CELL_SIZE.x + CELL_SPACING) * i

##################################################
"""
- 1초마다 UpdateTimer의 timeout 시그널에 의해 호출됨
- 시스템의 현재 시간(24시간제)을 읽어와서 각 자리 숫자를
  십의 자리 / 일의 자리로 나눠 해당 DigitCell에 반영

- 예) 현재 시각이 14시일 때
      t.hour / 10 = 1  (정수 나눗셈이라 소수점 버림)
      t.hour % 10 = 4
      → digit_cell_hour_list[0]에는 1, [1]에는 4가 표시됨

- 값이 실제로 바뀐 자리만 DigitCell 내부에서 애니메이션이 실행되고
  (set_digit() 안에서 같은 값이면 그냥 반환하도록 되어 있음)
  안 바뀐 자리는 조용히 무시되므로, 매초 호출해도 초 자리만
  움직이고 시/분은 값이 바뀔 때만 자연스럽게 플립됨
"""
func _update_time() -> void:
	var t: Dictionary = Time.get_time_dict_from_system()
	digit_cell_hour_list[0].set_digit(t.hour / 10)
	digit_cell_hour_list[1].set_digit(t.hour % 10)
	digit_cell_minute_list[0].set_digit(t.minute / 10)
	digit_cell_minute_list[1].set_digit(t.minute % 10)
	digit_cell_second_list[0].set_digit(t.second / 10)
	digit_cell_second_list[1].set_digit(t.second % 10)
