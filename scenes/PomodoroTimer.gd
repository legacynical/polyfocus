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
	timer.wait_time = session_time # sets PomoTimer wait time
	time_left = session_time # for TimerLabel processing
	update_label()
	#TODO make this automatically remember user settings in a save
	# manual win pos & size setting for easier debug for now
	DisplayServer.window_set_position(Vector2(1396, 925))
	DisplayServer.window_set_size(Vector2(411, 269))
	
	

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
	reset_timer(session_time)
	
	
func reset_timer(session_time: int) -> void:
	timer.paused = false
	counting_down = false
	timer.stop()
	timer_button.text = "START"
	timer.wait_time = session_time
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
	print("win pos: " + str(DisplayServer.window_get_position()))
	print("win size: " + str(DisplayServer.window_get_size()))


func _on_pomo_session_value_changed(session_time: int) -> void:
	print("session time changed to " + str(%PomoSession.value) + " min")
	session_time = %PomoSession.value * 60
	reset_timer(session_time)
