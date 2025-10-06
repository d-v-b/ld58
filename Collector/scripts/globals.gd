extends Node

var high_score: int = 0
var score: int = 0

signal score_updated

func add_score(points: int) -> void:
	score += points
	emit_signal("score_updated")
	if score > high_score:
		high_score = score

func reset_score() -> void:
	score = 0
	
