extends RichTextLabel

func _process(delta):
	#text = "SCORE [color=red]%d[/color]" % Globals.score
	text = str(Globals.score)
	#var main = get_node("/root/Main")
	#text = str(main.diamonds_collected, " / ", main.diamonds)
