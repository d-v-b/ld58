extends Label

var displayed_score: int = 0
var target_score: int = 0
var animating: bool = false

func _ready() -> void:
	Globals.score_updated.connect(_on_score_updated)
	
func _on_score_updated() -> void:
	target_score = Globals.score
	animating = true

func _process(delta: float) -> void:
	if animating:
		if displayed_score < target_score:
			displayed_score = min(displayed_score + int(100 * delta), target_score)
		elif displayed_score > target_score:
			displayed_score = max(displayed_score - int(100 * delta), target_score)
		else:
			animating = false
		text = str(displayed_score)
