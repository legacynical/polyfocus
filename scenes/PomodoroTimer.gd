extends Node

@onready var label: Label = %TimerLabel
@onready var timer: Timer = %PomoTimer
@onready var timer_button: Button = %TimerButton
@onready var setting_menu: PanelContainer = %SettingMenu
@onready var pomo_session: SpinBox = %PomoSession

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


func _on_setting_menu_button_pressed() -> void:
	print("setting menu button pressed")
	if setting_menu.visible:
		setting_menu.visible = false
	else:
		setting_menu.visible = true


func _on_button_pressed() -> void:
	print("test pressed")



func _on_pomo_session_value_changed(value: int) -> void:
	print("timer changed")
	session_time = value
	reset_timer()
