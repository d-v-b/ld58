extends Node

var high_score: int = 0
var score: int = 0

func add_score(points: int) -> void:
	score += points
	
func reset_score() -> void:
	if score > high_score:
		high_score = score
	score = 0
