extends Node

var music_player: AudioStreamPlayer

func _ready() -> void:
	# Make sure music continues even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Set up the music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)

	# Load and play the music
	var music = load("res://assets/audio/Chill Mining.mp3")
	if music:
		music_player.stream = music

		# Enable looping
		if music is AudioStreamMP3:
			music.loop = true

		# Start at low volume for fade in
		music_player.volume_db = -80.0
		music_player.play()

		# Fade in from 0
		fade_in()
	else:
		push_error("Failed to load music file")

func fade_in(duration: float = 2.0) -> void:
	# Fade in using player volume, not bus volume
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", 0.0, duration)

func fade_out(duration: float = 2.0) -> void:
	# Fade out using player volume, not bus volume
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -80.0, duration)
