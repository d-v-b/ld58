extends RayCast2D

@export var mining_length: int = 100

var bob

var _currently_selected_block: MiningBlock
var currently_selected_block: MiningBlock:
	get:
		return _currently_selected_block
	set(block):
		if block == _currently_selected_block:
			return
		if _currently_selected_block:
			_currently_selected_block.selected(false)
		if block:
			block.selected(true)
		_currently_selected_block = block

func _process(delta: float) -> void:
	var mouse_pos := get_local_mouse_position()
	target_position = mouse_pos.normalized() * mining_length
	var collider := get_collider()
	if collider and collider is MiningBlock:
		currently_selected_block = collider
	else:
		currently_selected_block = null
