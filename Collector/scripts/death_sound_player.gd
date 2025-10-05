extends AudioStreamPlayer2D

var death_sounds: Array[AudioStream] = []
var available_indices: Array[int] = []
var last_played_index: int = -1

func _ready() -> void:
	# Load all death sounds
	for i in range(1, 4):  # death_1.wav through death_3.wav
		var sound = load("res://assets/audio/death_%d.wav" % i)
		if sound:
			death_sounds.append(sound)

	# Initialize available indices
	reset_pool()

func reset_pool() -> void:
	available_indices.clear()
	for i in range(death_sounds.size()):
		if i != last_played_index:
			available_indices.append(i)

func play_random_death() -> void:
	if death_sounds.is_empty():
		return

	# If we've used all sounds, reset the pool
	if available_indices.is_empty():
		reset_pool()

	# Pick a random sound from available ones
	var random_idx = randi() % available_indices.size()
	var sound_index = available_indices[random_idx]

	# Remove this sound from available pool
	available_indices.remove_at(random_idx)
	last_played_index = sound_index

	# Play the sound
	stream = death_sounds[sound_index]
	play()
