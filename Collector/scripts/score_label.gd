extends Label

var displayed_score: int = 0
var target_score: int = 0
var animating: bool = false

var sound_player : AudioStreamPlayer

var score_sounds: Array[AudioStream] = []
var available_indices: Array[int] = []
var last_played_index: int = -1

func _ready() -> void:
	sound_player = AudioStreamPlayer.new()
	add_child(sound_player)
	Globals.score_updated.connect(_on_score_updated)
	
	for i in range(1, 7):  # jump_1.wav through jump_12.wav
		var sound = load("res://assets/audio/coin_bag_%d.wav" % i)
		if sound:
			score_sounds.append(sound)
			
	reset_pool()
	
func _on_score_updated() -> void:
	text = str(Globals.score)
	play_random_coin()


func reset_pool() -> void:
	available_indices.clear()
	for i in range(score_sounds.size()):
		if i != last_played_index:
			available_indices.append(i)


func play_random_coin() -> void:
	if available_indices.is_empty():
		reset_pool()

	var random_idx = randi() % available_indices.size()
	var sound_index = available_indices[random_idx]
	available_indices.remove_at(random_idx)
	last_played_index = sound_index

	# Create a new temporary player
	var player := AudioStreamPlayer.new()
	add_child(player)
	player.stream = score_sounds[sound_index]
	player.play()

	# Queue free when done playing
	player.connect("finished", Callable(player, "queue_free"))
