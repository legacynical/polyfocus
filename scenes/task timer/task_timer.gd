extends Control

@onready var progress_bar: TextureProgressBar = %TextureProgressBar
@onready var timer_label: Label = %TimerLabel
@onready var task_label: Label = %TaskLabel
@onready var task_timer_button: TextureButton = %TaskTimerButton
@onready var timer: Timer = %TaskTimer

const HOLD_THRESHOLD = 500 # in msec

var press_time: int = 0
var is_holding_task_timer_button: bool = false

var is_counting_down: bool = false
var session_time: int = 0
var time_left: int = 0
var task_duration: int = 0



func _ready() -> void:
	# button.button_down.connect(_on_button_down)
	task_timer_button.button_down.connect(_on_task_timer_button_down)
	task_timer_button.button_up.connect(_on_task_timer_button_up)
	
	session_time = 300 #initializes to 5 min
	timer.wait_time = session_time # sets PomoTimer wait time
	time_left = session_time # for TimerLabel processing
	update_label()

func _process(_delta) -> void:
	if is_holding_task_timer_button:
		var hold_duration: int = Time.get_ticks_msec() - press_time
		if hold_duration >= HOLD_THRESHOLD:
			print("[Hold duration: " + str(hold_duration) + "] open task timer settings")
			is_holding_task_timer_button = false # ensures no double action (1/2)
	if is_counting_down:
		time_left = round(timer.time_left)
		update_label()

func update_label() -> void:
	timer_label.text = convert_time(time_left)

func convert_time(time: int) -> String:
	@warning_ignore("integer_division")
	var minutes: int = int(floor(time / 60))
	var seconds: int = time % 60
	return "%02d:%02d" % [minutes, seconds]

func task_timer_pause_unpause() -> void:
	task_timer_button.disabled = true
	AudioManager.click_basic.play()
	
	if timer.is_paused(): # if paused, then unpause and count down
		timer.paused = false
		is_counting_down = true
		print("task timer unpaused")
		#skip_button.visible = true
		#timer_button.text = "PAUSE"
	elif is_counting_down: # if counting down, then pause
		timer.paused = true
		is_counting_down = false
		print("task timer paused")
		#skip_button.visible = false
		#timer_button.text = "RESUME"
	#TODO: make consistent size images to use for texture button, resume has 1 more char space
	else: # if neither paused nor counting down, then start timer and count down
		timer.start()
		is_counting_down = true
		print("task timer started")
		#skip_button.visible = true
		#timer_button.text = "PAUSE"
	task_timer_button.disabled = false

func _on_task_timer_timeout() -> void:
	pass # Replace with function body.

func _on_task_timer_button_down() -> void:
	press_time = Time.get_ticks_msec()
	is_holding_task_timer_button = true
	
func _on_task_timer_button_up() -> void:
	if is_holding_task_timer_button: # this fails if hold action already fired (2/2)
		print("[Hold duration: " + str(Time.get_ticks_msec() - press_time) + "] pause/unpause task timer")
		task_timer_pause_unpause()
	is_holding_task_timer_button = false