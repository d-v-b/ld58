extends RichTextLabel

func _process(delta):
	text = "SCORE [color=red]%d[/color]" % get_node("/root/Game").score
