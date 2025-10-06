extends Label

var displayed_score: int = 0
var target_score: int = 0
var animating: bool = false

func _ready() -> void:
	Globals.score_updated.connect(_on_score_updated)
	
func _on_score_updated() -> void:
	text = str(Globals.score)
