"""
▶▶▶ sound_manager.gd ◀◀◀

- 효과음 재생을 전담하는 매니저 스크립트
- 재생할 때마다 AudioStreamPlayer를 새로 생성해서 재생하고,
  재생이 끝나면 스스로 삭제되도록 만들어
  여러 셀이 동시에 플립해도 소리가
  서로 끊기지 않고 겹쳐서 들리게 함
"""

extends Node

##################################################
# 스플릿 플랩 셀이 넘어갈 때 재생할 효과음 파일
const FLAP_CLACK_STREAM: AudioStream = \
	preload("res://audio/sfx/flap_clack.wav")

##################################################
"""
- 외부에서 호출하는 함수로, 호출될 때마다
  새로운 AudioStreamPlayer를 만들어 flap_clack 사운드를 재생함

- 기존처럼 플레이어 하나를 재사용하지 않는 이유:
  플레이어가 하나뿐이면 재생 중에 또 play()가 호출될 경우
  이전 소리가 끊기고 새 소리로 덮어써짐
  (여러 셀이 동시에 플립할 때 소리가 뚝뚝 끊기는 원인)

- 매번 새로 만들면 각 소리가 서로 독립적으로 끝까지 재생되어
  동시에 여러 개가 겹쳐 들리는 자연스러운 효과가 남
"""
func play_flap_clack_sound() -> void:
	var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(sfx_player)
	sfx_player.stream = FLAP_CLACK_STREAM
	
	# finished 시그널이 울리면 스스로를 큐에 넣어 삭제
	# 매번 새로 만든 노드가 계속 쌓이지 않도록 정리해주는 부분
	sfx_player.finished.connect(sfx_player.queue_free)
	
	sfx_player.play()
