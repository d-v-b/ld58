extends RichTextLabel


func _process(delta: float) -> void:
	text = "HIGHEST [color=white]%d[/color]" % Globals.high_score
