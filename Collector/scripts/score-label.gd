extends RichTextLabel

func _process(delta: float) -> void:
	text = "SCORE [color=white]%d[/color]" % Globals.score
