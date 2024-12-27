extends Control

@onready var background_panel: TextureRect = %BackgroundPanel
@onready var progress_bar: TextureProgressBar = %TextureProgressBar
@onready var timer_label: Label = %TimerLabel
@onready var task_label: Label = %TaskLabel
@onready var status_label: Label = %StatusLabel
@onready var task_timer_button: TextureButton = %TaskTimerButton
@onready var timer: Timer = %TaskTimer
@onready var task_timer_quick_menu: PanelContainer = %TaskTimerQuickMenu
@onready var task_timer_setting_menu: PanelContainer = %TaskTimerSettingMenu

@onready var color_picker_button: ColorPickerButton = %ColorPickerButton
@onready var task_label_edit: LineEdit = %TaskLabelEdit
@onready var task_session: SpinBox = %TaskSession

const HOLD_THRESHOLD = 500 # in msec

var press_time: int = 0
var is_holding_task_timer_button: bool = false

var session_time_in_minutes: int = 15 # used for resetting task_session.value
var session_time: int = 0
var time_left_rounded: int = 0
var task_duration: int = 0

#var edit_color: Color = Color(0.067, 1.0, 0.0, 1.0)
#var edit_text: String = "coding"
#var edit_time: int = 15

func _ready() -> void:
	# button.button_down.connect(_on_button_down)
	task_timer_button.button_down.connect(_on_task_timer_button_down)
	task_timer_button.button_up.connect(_on_task_timer_button_up)
	
	background_panel.material.set_shader_parameter("fill_color", Color(0.2, 0.2, 0.2, 0.8))

	#reset_task_timer(task_session.value)

func _process(_delta) -> void:
	##TODO: pretty sure I can just move this to _on_task_timer_button_up()
	if is_holding_task_timer_button:
		var hold_duration: int = Time.get_ticks_msec() - press_time
		if hold_duration >= HOLD_THRESHOLD:
			AudioManager.click_basic.play()
			task_timer_quick_menu.visible = true
			print("[Hold duration: " + str(hold_duration) + "] open task timer settings")
			is_holding_task_timer_button = false # ensures no double action (1/2)
	if not timer.paused:
		time_left_rounded = round(timer.time_left)
		update_task_label()
		update_task_progress_bar()

func _on_task_timer_button_down() -> void:
	press_time = Time.get_ticks_msec()
	is_holding_task_timer_button = true
	
func _on_task_timer_button_up() -> void:
	if is_holding_task_timer_button: # this fails if hold action already fired (2/2)
		AudioManager.click_basic.play()
		print("[Hold duration: " + str(Time.get_ticks_msec() - press_time) + "] pause/unpause task timer")
		task_timer_pause_unpause()
	is_holding_task_timer_button = false

func update_task_label() -> void:
	timer_label.text = convert_time(time_left_rounded)

func convert_time(time: int) -> String:
	@warning_ignore("integer_division")
	var hours: int = int(time / 3600)
	var minutes: int = int((time % 3600) / 60) # float() not required as int() also truncates remainder (decimals) for positive floats
	var seconds: int = time % 60
	if hours > 0:
		return "%d:%02d:%02d" % [hours, minutes, seconds]
	else:	
		return "%2d:%02d" % [minutes, seconds]
	
	
func update_task_progress_bar() -> void:
	progress_bar.max_value = session_time
	progress_bar.value = time_left_rounded
	
func task_timer_pause_unpause() -> void:
	task_timer_button.disabled = true
	if background_panel.z_index == 1:
		AudioManager.alert_2_mb.play()
		background_panel.z_index = 0
		timer_label.visible = true
		task_label.z_index = 0
		status_label.z_index = 0
		status_label.text = "START"
		
		task_timer_button.disabled = false
		return
		
	AudioManager.click_basic.play()
	if timer.paused:
		timer.paused = false
		print("task timer unpaused")
		status_label.text = "PAUSE"
	elif not timer.paused: # if counting down, then pause
		timer.paused = true
		print("task timer paused")
		status_label.text = "RESUME"
	#TODO: make consistent size images to use for texture button, resume has 1 more char space
	else: # if neither paused nor counting down, then start timer and count down
		print("task timer started")
		status_label.text = "PAUSE"
	task_timer_button.disabled = false

func _on_task_timer_timeout() -> void:
	AudioManager.alert_1_mb.play()
	reset_task_timer(task_session.value)
	background_panel.z_index = 1
	timer_label.visible = false
	task_label.z_index = 1
	status_label.z_index = 1
	status_label.text = "COMPLETED"

func reset_task_timer(new_session_time_in_minutes: int) -> void:
	timer.paused = true
	status_label.text = "START"
	session_time = new_session_time_in_minutes * 60
	timer.start(session_time)
	
	time_left_rounded = round(timer.time_left)
	update_task_label()
	update_task_progress_bar()
	print("reset task timer to " + convert_time(int(timer.time_left)))

#region Quick Menu
func _on_qm_exit_pressed(is_muted: bool = false) -> void:
	if not is_muted:
		AudioManager.click_basic.play()
	task_timer_quick_menu.visible = false

func _on_qm_edit_pressed() -> void:
	AudioManager.click_basic.play()
	task_timer_setting_menu.visible = true
	
func _on_qm_reset_pressed() -> void:
	AudioManager.click_basic.play()
	reset_task_timer(task_session.value)
	task_timer_quick_menu.visible = false
#endregion
##END Quick Menu

#region Setting Menu
func _on_sm_exit_pressed(is_muted: bool = false) -> void:
	if not is_muted:
		AudioManager.click_basic.play()
	reset_setting_menu()
	task_timer_setting_menu.visible = false

func _on_sm_confirm_pressed(is_muted: bool = false) -> void:
	if not is_muted:
		AudioManager.click_basic.play()
	task_timer_quick_menu.visible = false
	task_timer_setting_menu.visible = false
	set_setting_values(color_picker_button.color, task_label_edit.text, task_session.value)
	#TODO apply and save settings
#endregion
##END Setting Menu

func set_setting_values(color: Color, text: String, session: int) -> void:
	color_picker_button.color = color
	task_label_edit.text = text
	task_session.value = session
	progress_bar.tint_progress = color_picker_button.color
	print("[set_setting_values] tint_progress set to: ", color_picker_button.color)
	task_label.text = task_label_edit.text
	print("[set_setting_values] text set to: ", task_label_edit.text)
	print("[set_setting_values] resetting timer")
	reset_task_timer(task_session.value)

func reset_setting_menu() -> void:
	color_picker_button.color = progress_bar.tint_progress
	task_label_edit.text = task_label.text
	task_session.value = session_time_in_minutes
