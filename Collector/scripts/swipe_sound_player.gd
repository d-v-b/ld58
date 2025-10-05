extends AudioStreamPlayer2D

var swipe_sounds: Array[AudioStream] = []
var available_indices: Array[int] = []
var last_played_index: int = -1

func _ready() -> void:
	# Load all swipe sounds
	for i in range(1, 14):  # swipe_1.wav through swipe_13.wav
		var sound = load("res://assets/audio/swipe_%d.wav" % i)
		if sound:
			swipe_sounds.append(sound)

	# Initialize available indices
	reset_pool()

func reset_pool() -> void:
	available_indices.clear()
	for i in range(swipe_sounds.size()):
		if i != last_played_index:
			available_indices.append(i)

func play_random_swipe() -> void:
	if swipe_sounds.is_empty():
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
	stream = swipe_sounds[sound_index]
	play()
