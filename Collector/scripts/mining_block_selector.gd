extends Node

class_name MiningBlockSelector

var _current: MiningBlock
var current: MiningBlock:
	get:
		return _current
	set(block):
		if block == _current:
			return
		if _current:
			_current.selected(false)
		if block:
			block.selected(true)
		_current = block
