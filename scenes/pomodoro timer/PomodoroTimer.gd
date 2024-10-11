extends Node

@onready var timer_label: Label = %TimerLabel
@onready var focus_time_label: Label = %TotalFocusTime
@onready var timer_button: Button = %TimerButton
@onready var setting_menu: PanelContainer = %SettingMenu
@onready var session_rating: Panel = %SessionRating
@onready var pomo_session: SpinBox = %PomoSession
@onready var break_session: SpinBox = %BreakSession
@onready var timer: Timer = %PomoTimer
@onready var background: Panel = %BackgroundPanel
@onready var focus_color: ColorPickerButton = %FocusColor
@onready var break_color: ColorPickerButton = %BreakColor
@onready var progressive_pomo_toggle: TextureButton = %ProgressivePomoToggle
@onready var mode_toggle: TextureButton = %ModeToggle


var progressive_pomo: bool = true
var counting_down: bool = false
var total_focus_time: int = 0
var session_time: int = 0
var time_left: int = 0
var focus_duration: int = 0

var current_mode = mode.FOCUS
enum mode {
	FOCUS,
	BREAK,
	PAUSED
}

func _ready() -> void:
	session_time = 300 #initializes to 5 min
	timer.wait_time = session_time # sets PomoTimer wait time
	time_left = session_time # for TimerLabel processing
	update_label()
	update_focus_time_label()
	#TODO make this automatically remember user settings in a save
	# manual win pos & size setting for easier debug for now
	DisplayServer.window_set_position(Vector2(3028, 799))
	DisplayServer.window_set_size(Vector2(406, 265))
	
func _process(_delta: float) -> void:
	if counting_down:
		time_left = round(timer.time_left)
		# print(str(timer.time_left) + " -> " + str(time_left))
		update_label()
		if current_mode == mode.FOCUS:
			update_focus_time_label()

	

func update_label() -> void:
	timer_label.text = convert_time(time_left)
	
func update_focus_time_label() -> void:
	if counting_down:
		focus_duration = session_time - time_left 
		var current_total_time: int = total_focus_time + focus_duration
		focus_time_label.text = "TFT [" + convert_time(current_total_time) + "]"
	else:
		update_total_focus_time()
		focus_time_label.text = "TFT [" + convert_time(total_focus_time) + "]"
		
		
func update_total_focus_time() -> void:
	focus_duration = session_time - time_left
	if focus_duration > 0 and session_time > 0:
		print("Adding focus duration: %d seconds" % focus_duration)
		total_focus_time += focus_duration
		session_time -= focus_duration
		print("New total focus time: %d seconds" % total_focus_time)
	
func convert_time(time: int) -> String:
	@warning_ignore("integer_division")
	var minutes: int = int(floor(time / 60))
	var seconds: int = time % 60
	return "%02d:%02d" % [minutes, seconds]
	
func _on_timer_button_pressed() -> void:
	timer_button.disabled = true
	AudioManager.click_basic.play()
	
	if timer.is_paused(): # if paused, then unpause and count down
		timer.paused = false
		counting_down = true
		timer_button.text = "PAUSE"
	elif counting_down: # if counting down, then pause
		timer.paused = true
		counting_down = false
		timer_button.text = "RESUME"
		if current_mode == mode.FOCUS:
			update_focus_time_label()
	#TODO: make consistent size images to use for texture button, resume has 1 more char space
	else: # if neither paused nor counting down, then start timer and count down
		timer.start()
		counting_down = true
		timer_button.text = "PAUSE"
	#changePanelColor()
	timer_button.disabled = false

func updatePanelColor():
	var new_stylebox = background.get_theme_stylebox("panel").duplicate()
	if current_mode == mode.FOCUS:
		new_stylebox.bg_color = focus_color.color
		background.add_theme_stylebox_override("panel", new_stylebox)
	elif current_mode == mode.BREAK:
		new_stylebox.bg_color = break_color.color
		background.add_theme_stylebox_override("panel", new_stylebox)
	#else:
		#new_stylebox.bg_color = Color.html("999999")
		#background.add_theme_stylebox_override("panel", new_stylebox)

func _on_pomo_timer_timeout() -> void:
	AudioManager.timer_complete.play()
	total_focus_time += session_time
	if progressive_pomo:
		rate_session()
	else:
		reset_timer(session_time)
	
	
func reset_timer(new_session_time: int) -> void:
	timer.paused = false
	counting_down = false
	timer.stop()
	timer_button.text = "START"
	session_time = new_session_time
	timer.wait_time = session_time
	time_left = session_time
	update_label()
	print("reset timer to " + convert_time(time_left))

### SettingMenu
func _on_setting_menu_button_pressed() -> void:
	AudioManager.click_basic.play()
	print("setting menu button pressed")
	if setting_menu.visible:
		setting_menu.visible = false
	else:
		setting_menu.visible = true
	
		
func _on_pomo_session_value_changed(_custom_time: int) -> void:
	print("pomo session time changed to " + str(pomo_session.value) + " min")
	update_total_focus_time() # prevents desync? hopefully
	session_time = pomo_session.value * 60 # minute value to seconds
	reset_timer(session_time)

func _on_break_session_value_changed(_custom_time: int):
	print("break session time changed to " + str(break_session.value) + " min")
	session_time = break_session.value * 60 # minute value to seconds
	reset_timer(session_time)
###

func _on_button_pressed() -> void:
	AudioManager.click_basic.play()
	print("test pressed")
	print("win pos: " + str(DisplayServer.window_get_position()))
	print("win size: " + str(DisplayServer.window_get_size()))

### SessionRating
func rate_session() -> void:
	reset_timer(300)
	session_rating.visible = true

func _on_flow_pressed() -> void:
	session_resume(1800)

func _on_focused_pressed() -> void:
	session_resume(1200)
	
func _on_neutral_pressed() -> void:
	session_resume(600)

func _on_distracted_pressed() -> void:
	AudioManager.click_basic.play()
	session_rating.visible = false
	reset_timer(300)
	
func session_resume(extend_time: int) -> void:
	AudioManager.click_basic.play()
	session_rating.visible = false
	reset_timer(extend_time)
	timer.start()
	counting_down = true
	timer_button.text = "PAUSE"
###

func _on_progressive_pomo_toggle_toggled(toggled_on):
	AudioManager.click_basic.play()
	if toggled_on:
		progressive_pomo_toggle.modulate = Color(1, 1, 1) # normal
		progressive_pomo = true
		print("progressive pomo: true")
	else:
		progressive_pomo_toggle.modulate = Color(0.5, 0.1, 0.1) # red
		progressive_pomo = false
		print("progressive pomo: false")


func _on_mode_toggle_toggled(toggled_on):
	AudioManager.click_basic.play()
	if current_mode == mode.FOCUS:
		update_total_focus_time()
	reset_timer(break_session.value * 60)
	if toggled_on:
		mode_toggle.modulate = Color(1, 1, 1) # normal
		current_mode = mode.FOCUS
		print("focus mode")
	else:
		mode_toggle.modulate = Color(0.5, 0.1, 0.1) # red
		current_mode = mode.BREAK
		print("break mode")
	updatePanelColor()
