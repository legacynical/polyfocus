extends Node

@onready var label: Label = $VBoxContainer/MarginContainer2/TimerLabel
@onready var timer: Timer = $PomoTimer
@onready var timer_button: Button = $VBoxContainer/MarginContainer/TimerButton

@export var session_time: int

var counting_down: bool = false
var time_left: int

func _ready() -> void:
	time_left = session_time
	timer.wait_time = time_left
	update_label()

func _process(_delta: float) -> void:
	if counting_down:
		@warning_ignore("narrowing_conversion")
		time_left = timer.time_left
		update_label()

func update_label() -> void:
	@warning_ignore("integer_division")
	var minutes: int = floor(time_left / 60)
	var seconds: int = time_left % 60
	label.text = "%02d:%02d" % [minutes, seconds]

func _on_timer_button_pressed() -> void:
	if timer.is_paused(): # if paused, then unpause and count down
		timer.paused = false
		counting_down = true
		timer_button.text = "PAUSE"
	elif counting_down: # if counting down, then pause
		timer.paused = true
		counting_down = false
		timer_button.text = "RESUME"
	#TODO: make consistent size images to use for texture button, resume has 1 more char space
	else: # if neither paused and counting down, then start timer and count down
		timer.start()
		counting_down = true
		timer_button.text = "PAUSE"
	
	  
		
func _on_pomo_timer_timeout() -> void:
	print("countdown complete!")
	reset_timer()
	
	
func reset_timer() -> void:
	timer.stop()
	counting_down = false
	timer_button.text = "START"
	time_left = session_time
	update_label()
