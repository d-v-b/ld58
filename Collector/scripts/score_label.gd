extends Label

func _ready() -> void:
	Globals.new_score.connect(_new_score)

#func _process(delta):
	#text = str(Globals.score)

func _new_score():
	text = str(Globals.score)
