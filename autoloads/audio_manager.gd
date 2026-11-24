extends Node
## Manages background music (persistent across scenes) and sound effects.

var _bgm_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS: int = 8


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.bus = &"Master"
	add_child(_bgm_player)

	for i in MAX_SFX_PLAYERS:
		var player := AudioStreamPlayer.new()
		player.bus = &"Master"
		add_child(player)
		_sfx_players.append(player)


func play_bgm(stream: AudioStream, volume_db: float = 0.0) -> void:
	if stream == null:
		return
	if _bgm_player.stream == stream and _bgm_player.playing:
		return
	_bgm_player.stream = stream
	_bgm_player.volume_db = volume_db
	_bgm_player.play()


func stop_bgm() -> void:
	_bgm_player.stop()


func play_sfx(stream: AudioStream, volume_db: float = 0.0, pitch_variance: float = 0.0) -> void:
	if stream == null:
		return
	for player in _sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
			player.pitch_scale = 1.0 + randf_range(-pitch_variance, pitch_variance) if pitch_variance > 0.0 else 1.0
			player.play()
			return
