extends AudioStreamPlayer2D

var jump_sounds: Array[AudioStream] = []
var available_indices: Array[int] = []
var last_played_index: int = -1

func _ready() -> void:
	# Load all jump sounds
	for i in range(1, 13):  # jump_1.wav through jump_12.wav
		var sound = load("res://assets/audio/jump_%d.wav" % i)
		if sound:
			jump_sounds.append(sound)

	# Initialize available indices
	reset_pool()

func reset_pool() -> void:
	available_indices.clear()
	for i in range(jump_sounds.size()):
		if i != last_played_index:
			available_indices.append(i)

func play_random_jump() -> void:
	if jump_sounds.is_empty():
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
	stream = jump_sounds[sound_index]
	play()
