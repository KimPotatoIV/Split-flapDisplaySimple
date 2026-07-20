"""
▶▶▶ sound_manager.gd ◀◀◀

- 효과음 재생을 전담하는 매니저 스크립트
"""

extends Node

##################################################
# 스플릿 플랩 셀이 넘어갈 때 재생할 효과음 파일
const FLAP_CLACK_STREAM: AudioStream = \
	preload("res://audio/sfx/flap_clack.wav")

# 소리를 재생할 노드로 미리 씬 트리에 배치하지 않고 코드로 직접 생성해서 붙임
var sfx_player: AudioStreamPlayer

##################################################
func _ready() -> void:
	# AudioStreamPlayer 노드를 코드로 직접 생성해서 자식으로 추가함
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)

##################################################
"""
- 외부에서 호출하는 함수로, 호출될 때마다
  flap_clack 사운드를 스트림으로 지정하고 즉시 재생
"""
func play_flap_clack_sound() -> void:
	sfx_player.stream = FLAP_CLACK_STREAM
	sfx_player.play()
