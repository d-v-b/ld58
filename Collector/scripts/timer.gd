extends Panel

var time: float = 1 * 60
var minutes: int
var seconds: int
var msec: int

signal timeout

func _ready() -> void:
	start()

func _process(delta: float) -> void:
	if time <= 0:
		time = 0
		stop()
		emit_signal("timeout")
		return
		
	time -= delta
	
	minutes = int(time / 60)
	seconds = int(fmod(time, 60))
	msec = int(fmod(time, 1) * 1000)
	
	$Minutes.text = "%02d:" % minutes
	$Seconds.text = "%02d:" % seconds
	$Msecs.text = "%03d" % msec
	
func stop() -> void:
	set_process(false)

func get_time_formatted() -> String:
	return "%02d:%02d.%03d" % [minutes, seconds, msec]
	
func start() -> void:
	set_process(true)
