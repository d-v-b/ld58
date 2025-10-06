extends Node

var high_score: int = 0
var score: int = 0

signal score_updated

func add_score(points: int) -> void:
	score += points
	
func update() -> void:
	emit_signal("score_updated")
	
func reset_score() -> void:
	if score > high_score:
		high_score = score
	score = 0
