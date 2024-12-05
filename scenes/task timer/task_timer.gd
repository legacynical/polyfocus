extends Control

@onready var progress_bar: TextureProgressBar = %TextureProgressBar
@onready var timer_label: Label = %TimerLabel
@onready var task_label: Label = %TaskLabel
@onready var task_timer_button: TextureButton = %TaskTimerButton

const HOLD_THRESHOLD = 500 # in msec

var press_time: int = 0
var is_holding_task_timer_button: bool = false

func _ready() -> void:
	# button.button_down.connect(_on_button_down)
	task_timer_button.button_down.connect(_on_task_timer_button_down)
	task_timer_button.button_up.connect(_on_task_timer_button_up)


func _process(_delta) -> void:
	if is_holding_task_timer_button:
		var hold_duration: int = Time.get_ticks_msec() - press_time
		if hold_duration >= HOLD_THRESHOLD:
			print("[Hold duration: " + str(hold_duration) + "] open task timer settings")
			is_holding_task_timer_button = false # ensures no double action (1/2)
		
func _on_task_timer_timeout() -> void:
	pass # Replace with function body.

func _on_task_timer_button_down() -> void:
	press_time = Time.get_ticks_msec()
	is_holding_task_timer_button = true
	
func _on_task_timer_button_up() -> void:
	if is_holding_task_timer_button: # this fails if hold action already fired (2/2)
		print("[Hold duration: " + str(Time.get_ticks_msec() - press_time) + "] pause/unpause task timer")
	is_holding_task_timer_button = false
