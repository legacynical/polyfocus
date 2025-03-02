class_name PomodoroTimer
extends Node

@onready var timer_elements: VBoxContainer = %TimerElements
@onready var timer_label: Label = %TimerLabel
@onready var focus_time_label: Label = %TotalFocusTime
@onready var timer_button: Button = %TimerButton
@onready var skip_button: Button = %SkipButton

@onready var quick_timer_menu: PanelContainer = %QuickTimerMenu
@onready var quick_timer_button: Button = %QuickTimerButton

@onready var qt_one_click_start_toggle: TextureButton = %QTOneClickStartToggle

# these two should be the same value
@onready var custom_qt_session_slider: HSlider = %CustomQTSessionSlider
@onready var custom_qt_session_spin_box: SpinBox = %CustomQTSessionSpinBox

@onready var custom_qt_session_label: Label = %CustomQTSessionLabel
@onready var custom_qt_session_start: Button = %CustomQTSessionStart

@onready var setting_menu: PanelContainer = %SettingMenu
@onready var timer_setting_scroll: ScrollContainer = %"Timer Settings"
@onready var pomo_session: SpinBox = %PomoSession
@onready var break_session: SpinBox = %BreakSession
@onready var long_break_toggle: TextureButton = %LongBreakToggle
@onready var long_break_session: SpinBox = %LongBreakSession
@onready var break_session_interval: SpinBox = %BreakSessionInterval
@onready var progressive_pomo_toggle: TextureButton = %ProgressivePomoToggle

@onready var primer_session: SpinBox = %ProgressivePrimerSession
@onready var neutral_session: SpinBox = %NeutralSession
@onready var focused_session: SpinBox = %FocusedSession
@onready var flow_session: SpinBox = %FlowSession
@onready var low_processor_mode_toggle: TextureButton = %LowProcessorModeToggle

@onready var task_timer_menu: PanelContainer = %TaskTimerMenu
@onready var task_timer_grid_container: GridContainer = %TTGridContainer

@onready var session_rating: Panel = %SessionRating
@onready var sr_exit_button: Button = %SRExitButton
@onready var rating_timeout_bar: TextureProgressBar = %RatingTimeoutBar
@onready var distracted_label: Label = %DistractedLabel
@onready var neutral_label: Label = %NeutralLabel
@onready var focused_label: Label = %FocusedLabel
@onready var flow_label: Label = %FlowLabel


@onready var timer: Timer = %PomoTimer
@onready var background: Panel = %BackgroundPanel
@onready var focus_color_picker: ColorPickerButton = %FocusColorPicker
@onready var break_color_picker: ColorPickerButton = %BreakColorPicker
@onready var is_progressive_pomo_toggle: TextureButton = %ProgressivePomoToggle
@onready var mode_toggle: TextureButton = %ModeToggle

@onready var auto_session_extend: OptionButton = %AutoSessionExtend
@onready var rating_timeout: SpinBox = %RatingTimeout

@onready var audio_setting_container: VBoxContainer = %AudioSettingContainer

@onready var polyfocus_version_label: Label = %PolyfocusVersionLabel
@onready var polyfocus_version: String = ProjectSettings.get_setting("application/config/version")


@onready var saved_game: SavedGame = SavedGame.new()
#@onready var save_file: String = "user://savegame.tres"
@onready var save_file: String = "user://[v" + polyfocus_version + "]savegame.tres"


var default_window_size: Vector2 = Vector2(480, 270)
var default_window_position = null # sets to center of user's primary screen on 1st startup

var is_progressive_pomo_enabled: bool = false
var is_progressive_pomo_break_due: bool = false

var is_switch_mode_on_timeout: bool = true # unused, may or may not be implemented

var is_muted: bool = true # used to prevent clicks sfx on some function calls

var break_session_counter: int = 0 # resets to 0 when long breaks toggled on from off
var total_focus_time: int = 0
var focus_duration: int = 0
var session_time: int = 0
var time_left_rounded: int = 0

enum mode {
	FOCUS,
	BREAK,
	PAUSED
}
var current_mode: mode = mode.FOCUS

func _ready() -> void:
	polyfocus_version_label.text = " Polyfocus v" + polyfocus_version + "-beta"
	DisplayServer.window_set_min_size(default_window_size)
	
	timer_setting_scroll.scroll_vertical = 0
	
	timer.paused = true
	if is_progressive_pomo_enabled:
		reset_timer(primer_session.value)
	else:
		reset_timer(pomo_session.value)
	update_total_focus_time()
	
	#TODO finish transparent mode feature
	# get_tree().get_root().set_transparent_background(true) # sets window transparency
	# DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true) # sets window bar
	# set_semi_transparent(get_tree().get_root())
	
	if not FileAccess.file_exists(save_file):
		save_window()
		save_timer_setting()
		save_audio_setting()
		save_quick_timers()
		set_default_task_timers()
		save_task_timers()
	load_window()
	load_timer_setting()
	load_audio_setting()
	load_quick_timers()
	load_task_timers()
	
func _process(_delta: float) -> void:
	if not timer.paused:
		time_left_rounded = round(timer.time_left) 
		update_label()
		match current_mode:
			mode.FOCUS:
				update_total_focus_time()
# TODO finish transparent mode feature
func set_semi_transparent(node: Node) -> void:
	if node is CanvasItem:
		var visual_node := node as CanvasItem
		visual_node.modulate.a = 0.9
		
	for child in node.get_children():
		set_semi_transparent(child)
	
#region Timer
func update_label() -> void:
	timer_label.text = convert_time(time_left_rounded)

func update_total_focus_time() -> void:
	if not timer.paused:
		# important to use session_time instead of timer.wait_time
		focus_duration = session_time - time_left_rounded
		if focus_duration > 0 and session_time > 0:
			print("Adding focus duration: %d seconds" % focus_duration)
			total_focus_time += focus_duration
			session_time -= focus_duration
			print("New total focus time: %d seconds" % total_focus_time)
			focus_time_label.text = "Total Focus Time [" + convert_time(total_focus_time) + "]"
		#var new_total_focus_time: int = total_focus_time + focus_duration
		#focus_time_label.text = "Total Focus Time [" + convert_time(new_total_focus_time) + "]"
	#else: # timer.paused
		## session_time is set to .wait_time on timer reset and is used here to prevent overshoot
		#if focus_duration > 0 and session_time > 0:
			#print("Adding focus duration: %d seconds" % focus_duration)
			#total_focus_time += focus_duration
			#session_time -= focus_duration
			#print("New total focus time: %d seconds" % total_focus_time)
			#focus_time_label.text = "Total Focus Time [" + convert_time(total_focus_time) + "]"
	if current_mode == mode.BREAK:
			print("HOW DID YOU GET HERE? (this should be called only during focus mode??)")		
			print("[SUS] Called from function: ", get_caller_function_name())
			
	
func convert_time(time: int) -> String:
	@warning_ignore("integer_division")
	var hours: int = int(time / 3600)
	var minutes: int = int((time % 3600) / 60) # float() not required as int() also truncates remainder (decimals) for positive floats
	var seconds: int = time % 60
	if hours > 0:
		return "%d:%02d:%02d" % [hours, minutes, seconds]
	else:	
		return "%02d:%02d" % [minutes, seconds]

func _on_timer_button_pressed() -> void:
	timer_button.disabled = true
	AudioManager.click_basic.play()
	
	# .is_paused() method checks if the timer is paused and whether locally or globally (useful for scene/node pauses)
	# for this use case, we care about local timer pause state so we use .paused
	if timer.paused: # if paused...
		timer.paused = false #...then unpause
		skip_button.visible = true
		quick_timer_button.visible = false
		timer_button.text = "PAUSE"
	elif not timer.paused: # if not paused...
		timer.paused = true #...then pause
		skip_button.visible = false
		quick_timer_button.visible = true
		timer_button.text = "RESUME"
		#if current_mode == mode.FOCUS:
			#update_total_focus_time()
	#TODO: make consistent size images to use for texture button, resume has 1 more char space
	else: # if neither paused nor counting down, then start timer and count down
		# timer.start() # does not unpause, but will start countdown if .paused = false
			# sets .is_stopped() = false
			# resets running timers time_left with new duration or default wait time
		skip_button.visible = true
		timer_button.text = "PAUSE"
		
	timer_button.disabled = false

func _on_skip_button_pressed() -> void:
	AudioManager.click_basic.play()
	switch_mode()


func update_panel_color() -> void:
	var new_stylebox: StyleBox = background.get_theme_stylebox("panel").duplicate()
	match current_mode:
		mode.FOCUS:
			new_stylebox.bg_color = focus_color_picker.color
			background.add_theme_stylebox_override("panel", new_stylebox)
		mode.BREAK:
			new_stylebox.bg_color = break_color_picker.color
			background.add_theme_stylebox_override("panel", new_stylebox)
	#else:
		#new_stylebox.bg_color = Color.html("999999")
		#background.add_theme_stylebox_override("panel", new_stylebox)

func _on_pomo_timer_timeout() -> void:
	#AudioManager.timer_complete.play()
	match current_mode:
		mode.FOCUS:
			if not is_progressive_pomo_enabled or is_progressive_pomo_break_due:
				switch_mode()
			else:
				rate_session()
		mode.BREAK:
			if is_switch_mode_on_timeout: # user non-changeable true
				switch_mode() # would user even want auto mode switch on timeout off?
				
func reset_timer(new_session_time_in_minutes: int, is_auto_start_enabled: bool = false) -> void:
	print("resetting timer to: ", new_session_time_in_minutes, " min")
	timer.paused = true
	timer_button.text = "START"
	skip_button.visible = false
	session_time = new_session_time_in_minutes * 60 # conversion to seconds
	print("resetting timer to: ", session_time, " sec")
	timer.start(session_time)
	print("timer wait_time: ", timer.wait_time)
	print("timer time_left: ", timer.time_left)
		# this also sets both .wait_time and .time_left to session_time
		# this does not unpause the timer
	time_left_rounded = round(timer.time_left)
	update_label()
	print("reset timer to " + convert_time(int(timer.time_left)))
	quick_timer_button.visible = true

	if is_auto_start_enabled: # auto starts timer after timer reset
		timer.paused = false
		timer_button.text = "PAUSE"
		skip_button.visible = true
		quick_timer_button.visible = false

# closes pomo menus when clicking outside to the background panel
func _on_background_panel_gui_input(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("pt background panel pressed")
			close_pomodoro_menus()

func close_pomodoro_menus() -> void:
	setting_menu.visible = false
	timer_setting_scroll.scroll_vertical = 0
	task_timer_menu.visible = false
	quick_timer_menu.visible = false

func is_long_break_due() -> bool:
	return break_session_counter % int(break_session_interval.value) == 0
#endregion
##END Timer

#region QuickTimer
func _on_quick_timer_button_pressed() -> void:
	AudioManager.alert_1_mb.play()
	quick_timer_menu.visible = true

func _on_qt_one_click_start_toggle_toggled(toggled_on: bool, is_muted: bool = false) -> void:
	if not is_muted:
		AudioManager.click_basic.play()
	qt_one_click_start_toggle.set_pressed_no_signal(toggled_on)

func _on_custom_qt_session_slider_value_changed(value: int) -> void:
	custom_qt_session_spin_box.value = value
	
func _on_custom_qt_session_spin_box_value_changed(value: int) -> void:
	custom_qt_session_slider.value = value
	custom_qt_session_label.text = convert_time(value * 60)
	
##TODO I can probably make this code more concise like with task timers and also add customizeable
## preset quick timers but also probably not worth the effort
func _on_min_5_button_pressed() -> void:
	set_quick_timer(5)
func _on_min_10_button_pressed() -> void:
	set_quick_timer(10)
func _on_min_15_button_pressed() -> void:
	set_quick_timer(15)
func _on_min_20_button_pressed() -> void:
	set_quick_timer(20)
func _on_min_25_button_pressed() -> void:
	set_quick_timer(25)
func _on_min_30_button_pressed() -> void:
	set_quick_timer(30)
func _on_min_35_button_pressed() -> void:
	set_quick_timer(35)
func _on_min_40_button_pressed() -> void:
	set_quick_timer(40)
func _on_min_45_button_pressed() -> void:
	set_quick_timer(45)
func _on_min_50_button_pressed() -> void:
	set_quick_timer(50)
func _on_min_55_button_pressed() -> void:
	set_quick_timer(55)
func _on_hr_1_button_pressed() -> void:
	set_quick_timer(60)

func _on_custom_qt_session_start_pressed():
	if custom_qt_session_spin_box.value > 0:
		reset_timer(custom_qt_session_spin_box.value, true)
	AudioManager.click_basic.play()
	quick_timer_menu.visible = false
	
func _on_subtract_l_pressed() -> void:
	edit_quick_timer(-10)
func _on_subtract_m_pressed() -> void:
	edit_quick_timer(-5)
func _on_subtract_s_pressed() -> void:
	edit_quick_timer(-1)
func _on_add_s_pressed() -> void:
	edit_quick_timer(1)
func _on_add_m_pressed() -> void:
	edit_quick_timer(5)
func _on_add_l_pressed() -> void:
	edit_quick_timer(10)

func edit_quick_timer(edit_value: int) -> void:
	AudioManager.click_basic.play()
	custom_qt_session_spin_box.value += edit_value

func set_quick_timer(reset_time_in_minutes: int) -> void:	
	AudioManager.click_basic.play()
	if qt_one_click_start_toggle.button_pressed:
		reset_timer(reset_time_in_minutes, true)
		quick_timer_menu.visible = false
	else:
		custom_qt_session_spin_box.value = reset_time_in_minutes
#endregion
##END QuickTimer

#region Timer Settings Menu
func _on_setting_menu_button_pressed() -> void:
	AudioManager.click_basic.play()
	print("setting menu button pressed")
	if setting_menu.visible:
		setting_menu.visible = false
		timer_setting_scroll.scroll_vertical = 0
	else:
		setting_menu.visible = true
		task_timer_menu.visible = false
		
func _on_pomo_session_value_changed(_custom_time: int) -> void:
	print("pomo session time changed to " + str(pomo_session.value) + " min")
	if current_mode == mode.FOCUS and not is_progressive_pomo_enabled:
		reset_timer(pomo_session.value)

func _on_break_session_value_changed(_custom_time: int) -> void:
	print("break session time changed to " + str(break_session.value) + " min")
	if current_mode == mode.BREAK and not is_long_break_due():
		@warning_ignore("narrowing_conversion")
		reset_timer(break_session.value)

func _on_long_break_session_value_changed(_custom_time: int) -> void:
	print("long break session time changed to " + str(long_break_session.value) + " min")
	if current_mode == mode.BREAK and is_long_break_due():
		reset_timer(long_break_session.value)
func _on_window_reset_button_pressed() -> void:
	load_window()

func _on_window_save_button_pressed() -> void:
	save_window()

func _on_window_default_button_pressed() -> void:
	AudioManager.click_basic.play()
	print("resetting window")
	DisplayServer.window_set_size(default_window_size)
	DisplayServer.window_set_position(default_window_position)

func _on_long_break_toggle_toggled(toggled_on: bool, is_muted: bool = false) -> void:
	if not is_muted:
		AudioManager.click_basic.play()
	if toggled_on:
		break_session_counter = 0
		print("reset break session counter")
	long_break_toggle.set_pressed_no_signal(toggled_on)
		
func _on_low_processor_mode_toggle_toggled(toggled_on: bool, is_muted: bool = false) -> void:
	if not is_muted:
		AudioManager.click_basic.play()
	low_processor_mode_toggle.set_pressed_no_signal(toggled_on) # prevents toggle emit when changing pressed state
	OS.set_low_processor_usage_mode(toggled_on)
	print("low processor mode: ",OS.is_in_low_processor_usage_mode())

		

#endregion
##END Timer Settings Menu

#region TaskTimerMenu
func _on_task_timer_menu_button_pressed() -> void:
	AudioManager.click_basic.play()
	print("task timer menu button pressed")
	if task_timer_menu.visible:
		task_timer_menu.visible = false
	else:
		task_timer_menu.visible = true
		setting_menu.visible = false
		timer_setting_scroll.scroll_vertical = 0

# closes task timer menus when clicking on empty grid container space
func _on_tt_grid_container_gui_input(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("tt grid container pressed")
			close_task_timer_quick_menus()
			
func close_task_timer_quick_menus() -> void:
	for task_timer_control in task_timer_grid_container.get_children():
		print(task_timer_control)
		task_timer_control.get_node("TaskTimer")._on_sm_exit_pressed(is_muted)
		task_timer_control.get_node("TaskTimer")._on_qm_exit_pressed(is_muted)
#endregion
##END TaskTimerMenu

#region SessionRating
func rate_session() -> void:
	AudioManager.alert_1_mb.play()
	timer.paused = true
	flow_label.text = "+%dm" % flow_session.value
	focused_label.text = "+%dm" % focused_session.value
	neutral_label.text = "+%dm" % neutral_session.value
	distracted_label.text = "↺%dm" % primer_session.value
	session_rating.visible = true
	
	var rating_timeout_timer = get_tree().create_timer(rating_timeout.value)
	rating_timeout_bar.max_value = rating_timeout.value
	while rating_timeout_timer.time_left > 0:
		rating_timeout_bar.value = rating_timeout_timer.time_left
		await get_tree().create_timer(0.1).timeout
	
	sr_exit_button.disabled = true
	if session_rating.visible: # if SR isn't closed yet, then auto extend
		match auto_session_extend.get_selected_id():
			0:
				_on_distracted_pressed()
			1:
				_on_neutral_pressed()
			2:
				_on_focused_pressed()
			3:
				_on_flow_pressed()
	sr_exit_button.disabled = false	

func _on_sr_exit_button_pressed() -> void:
	session_rating.visible = false
	_on_distracted_pressed()
	
func _on_flow_pressed() -> void:
	session_resume(flow_session.value)

func _on_focused_pressed() -> void:
	session_resume(focused_session.value)
	
func _on_neutral_pressed() -> void:
	session_resume(neutral_session.value)

func _on_distracted_pressed() -> void:
	AudioManager.distracted.play()
	session_rating.visible = false
	reset_timer(primer_session.value)
	
func session_resume(extend_time: int) -> void:
	AudioManager.click_basic.play()
	AudioManager.alert_2_mb.play()
	session_rating.visible = false
	is_progressive_pomo_break_due = true
	reset_timer(extend_time, true) # resets timer by extend_time and starts timer
#endregion
##END SessionRating

#region ProgressivePomo
func _on_progressive_pomo_toggle_toggled(toggled_on: bool, is_muted: bool = false) -> void:
	if not is_muted:
		AudioManager.click_basic.play()
	progressive_pomo_toggle.set_pressed_no_signal(toggled_on)
	if toggled_on:
		is_progressive_pomo_enabled = true
		match current_mode:
			mode.FOCUS:
				reset_timer(primer_session.value)
			mode.BREAK:
				pass
		print("progressive pomo: true")
	else:
		is_progressive_pomo_enabled = false
		match current_mode:
			mode.FOCUS:
				reset_timer(pomo_session.value)
			mode.BREAK:
				pass
		print("progressive pomo: false")
#endregion
##END ProgressivePomo

#region Focus/Break Toggle
func _on_mode_toggle_toggled(_toggled_on: bool) -> void:
	AudioManager.click_basic.play()
	switch_mode()

func switch_mode() -> void:
	is_progressive_pomo_break_due = false # prevents unintended breaks
	skip_button.visible = false
	match current_mode:
		mode.FOCUS: # switches to break
			AudioManager.time_to_break_mb.play()
			@warning_ignore("narrowing_conversion")
			break_session_counter += 1
			print("\nbreak counter: " + str(break_session_counter))
			if is_long_break_due() and long_break_toggle.is_pressed():
				reset_timer(long_break_session.value)
			else:
				reset_timer(break_session.value)
			current_mode = mode.BREAK
			mode_toggle.modulate = focus_color_picker.color
			print("break mode")
		mode.BREAK: # switches to focus
			AudioManager.time_to_focus_mb.play()
			@warning_ignore("narrowing_conversion")
			print("")
			if is_progressive_pomo_enabled:
				reset_timer(primer_session.value)
			else:
				reset_timer(pomo_session.value)
			current_mode = mode.FOCUS
			mode_toggle.modulate = break_color_picker.color
			print("focus mode")
	update_panel_color()
#endregion
##END Focus/Break Toggle



#region Save/Load 
func save_window() -> void:
	print("\nsaving window:")
	print_window_stats()
	saved_game.window_position = DisplayServer.window_get_position()
	saved_game.window_size = DisplayServer.window_get_size()
	if default_window_position == null:
		saved_game.default_window_position = DisplayServer.window_get_position()
		print("default window pos saved: " + str(saved_game.default_window_position))
	else:
		saved_game.default_window_position = default_window_position
	ResourceSaver.save(saved_game, save_file)
	
func load_window() -> void:
	print("\nloading window:")
	var saved_game: SavedGame = load(save_file) as SavedGame
	DisplayServer.window_set_position(saved_game.window_position)
	DisplayServer.window_set_size(saved_game.window_size)
	default_window_position = saved_game.default_window_position
	print_window_stats()

func print_window_stats() -> void:
	print(" ⌈Window Stats")
	print(" |win pos: " + str(DisplayServer.window_get_position()))
	print(" |win size: " + str(DisplayServer.window_get_size()))
	print(" ⌊default win pos: " + str(default_window_position))

func save_timer_setting() -> void:
	print("\nsaving timer setting:")
	saved_game.focus_color_picker = focus_color_picker.color
	saved_game.break_color_picker = break_color_picker.color
	#TODO focus color presets
	#TODO break color presets
	
	saved_game.pomodoro_session = pomo_session.value
	saved_game.break_session = break_session.value
	saved_game.long_break_session = long_break_session.value

	saved_game.long_break_toggle = long_break_toggle.button_pressed
	saved_game.break_session_interval = break_session_interval.value
	saved_game.is_progressive_pomo_enabled = progressive_pomo_toggle.button_pressed
	saved_game.auto_extend_id = auto_session_extend.selected
	saved_game.rating_timeout = rating_timeout.value

	saved_game.primer_session = primer_session.value
	saved_game.neutral_session = neutral_session.value
	saved_game.focused_session = focused_session.value
	saved_game.flow_session = flow_session.value
	
	saved_game.low_processor_mode_toggle = low_processor_mode_toggle.button_pressed

	ResourceSaver.save(saved_game, save_file)
	
func load_timer_setting() -> void:
	print("\nloading timer setting:")
	var saved_game: SavedGame = load(save_file) as SavedGame
	focus_color_picker.color = saved_game.focus_color_picker
	break_color_picker.color = saved_game.break_color_picker
	#TODO focus color presets
	#TODO break color presets
	
	pomo_session.value = saved_game.pomodoro_session
	break_session.value = saved_game.break_session
	long_break_session.value = saved_game.long_break_session
	
	_on_long_break_toggle_toggled(saved_game.long_break_toggle, is_muted)
	break_session_interval.value = saved_game.break_session_interval
	_on_progressive_pomo_toggle_toggled(saved_game.is_progressive_pomo_enabled, is_muted)
	auto_session_extend.selected = saved_game.auto_extend_id
	rating_timeout.value = saved_game.rating_timeout
	
	primer_session.value = saved_game.primer_session
	neutral_session.value = saved_game.neutral_session
	focused_session.value = saved_game.focused_session
	flow_session.value = saved_game.flow_session
	
	_on_low_processor_mode_toggle_toggled(saved_game.low_processor_mode_toggle, is_muted)
	
func save_quick_timers() -> void:
	print("\nsaving quick timers:")
	saved_game.is_qt_one_click_start = qt_one_click_start_toggle.button_pressed
	saved_game.custom_qt_session = custom_qt_session_spin_box.value
	ResourceSaver.save(saved_game, save_file)
	
func load_quick_timers() -> void:
	print("\nloading quick timers:")
	var saved_game: SavedGame = load(save_file) as SavedGame
	_on_qt_one_click_start_toggle_toggled(saved_game.is_qt_one_click_start, is_muted)
	custom_qt_session_spin_box.value = saved_game.custom_qt_session
	custom_qt_session_slider.value = saved_game.custom_qt_session

func save_task_timers() -> void:
	print("\nsaving task timers:")
	var new_task_timers: Array = []
	for task_timer_control in task_timer_grid_container.get_children():
		print(task_timer_control)
		var task_timer_settings: Dictionary = {
			"Control Node": task_timer_control.name,
			"ProgressBar Color": task_timer_control.get_node("TaskTimer").progress_bar.tint_progress,
			"TaskLabel Text": task_timer_control.get_node("TaskTimer").task_label.text,
			"TaskSession Time": task_timer_control.get_node("TaskTimer").task_session.value
		}
		print("task timer settings: " + str(task_timer_settings))
		new_task_timers.append(task_timer_settings)
	saved_game.task_timers = new_task_timers
	print("saved task timers: " + str(saved_game.task_timers))
	ResourceSaver.save(saved_game, save_file)

func load_task_timers() -> void:
	print("\nloading task timers:")
	var saved_game: SavedGame = load(save_file) as SavedGame

	print("total saved timers: " + str(saved_game.task_timers.size()))
	for i in range(saved_game.task_timers.size()):
		var task_timer_settings: Dictionary = saved_game.task_timers[i]
		#adding/removing instances can be cumbersome with saving/loading... 
		#...will make a static but simple implementation for now
		
		#var control_node = Control.new()
		#var task_timer_instance = task_timer.instantiate()
		
		#print("loading task timer at index: ", i)
		#task_timer_grid_container.add_child(control_node)
		#control_node.name = "TaskTimerControl%d" % i
		#control_node.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_FILL
		#control_node.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_FILL
		
		#control_node.add_child(task_timer_instance)
		
		#task_timer_instance.progress_bar.tint_progress = task_timer_settings["ProgressBar Color"]
		#task_timer_instance.task_label.text = task_timer_settings["TaskLabel Text"]
		#task_timer_instance.task_session.value = task_timer_settings["TaskSession Time"]
		print("loading task timer at index: ", i)
		var target_timer: Control = task_timer_grid_container.get_child(i).get_node("TaskTimer") as Control
		print("  control: ", task_timer_grid_container.get_child(i))
		print("    control: ", task_timer_grid_container.get_child(i).get_node("TaskTimer"))
		target_timer.color_picker_button.color = task_timer_settings["ProgressBar Color"]
		print("      ProgressBar Color: ", task_timer_settings["ProgressBar Color"])
		target_timer.task_label_edit.text = task_timer_settings["TaskLabel Text"]
		print("      TaskLabel Text: ", task_timer_settings["TaskLabel Text"])
		target_timer.task_session.value = task_timer_settings["TaskSession Time"]
		print("      TaskSession Time: ", task_timer_settings["TaskSession Time"])
		target_timer._on_sm_confirm_pressed(is_muted)

func set_default_task_timers() -> void:
	task_timer_grid_container.get_child(0).get_node("TaskTimer").set_setting_values(Color.html("59B300"), "Language", 15)
	task_timer_grid_container.get_child(1).get_node("TaskTimer").set_setting_values(Color.html("2874A6"), "Chess", 15)
	task_timer_grid_container.get_child(2).get_node("TaskTimer").set_setting_values(Color.html("F7DC6F"), "Drawing", 15)
	task_timer_grid_container.get_child(3).get_node("TaskTimer").set_setting_values(Color.html("FFFFFF"), "Piano", 15)
	task_timer_grid_container.get_child(4).get_node("TaskTimer").set_setting_values(Color.html("F5B041"), "Reading", 20)
	task_timer_grid_container.get_child(5).get_node("TaskTimer").set_setting_values(Color.html("E67AB8"), "Writing", 20)
	task_timer_grid_container.get_child(6).get_node("TaskTimer").set_setting_values(Color.html("82E0AA"), "Cleaning", 20)
	task_timer_grid_container.get_child(7).get_node("TaskTimer").set_setting_values(Color.html("5DADE2"), "Laundry", 80)

func save_audio_setting() -> void:
	print("\nsaving audio settings:")
	var new_audio_settings: Array = []
	for volume_container in audio_setting_container.get_children():
		print(volume_container)
		var audio_settings: Dictionary = {
			"Volume Container": volume_container.name,
			"Bus": volume_container.get_node("volume_control").bus_name,
			"Volume": int(volume_container.get_node("volume_control").volume_label.text),
		}
		print("audio settings: " + str(audio_settings))
		new_audio_settings.append(audio_settings)
	saved_game.audio_settings = new_audio_settings
	print("saved audio settings: " + str(saved_game.audio_settings))
	ResourceSaver.save(saved_game, save_file)
	
func load_audio_setting() -> void:
	print("\nloading audio settingss:")
	var saved_game: SavedGame = load(save_file) as SavedGame
	
	print("total saved audio settings: " + str(saved_game.audio_settings.size()))
	for i in range(saved_game.audio_settings.size()):
		var saved_audio_settings: Dictionary = saved_game.audio_settings[i]
		print("loading audio setting at index: ", i)
		var target_volume_control: HBoxContainer = audio_setting_container.get_child(i).get_node("volume_control") as HBoxContainer
		print("  control: ", audio_setting_container.get_child(i))
		print("    control: ", audio_setting_container.get_child(i).get_node("volume_control"))
		target_volume_control.set_volume(saved_audio_settings["Volume"])
		print("setting audio bus [", saved_audio_settings["Bus"],"] volume to ", saved_audio_settings["Volume"])
		
func _notification(what) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			save_window() # saves window position & size
			save_timer_setting() # saves pomodoro timer settings
			save_audio_setting() # saves audio settings
			save_quick_timers() # saves quick timer settings
			save_task_timers() # saves task timers
			get_tree().quit() # default behavior
		NOTIFICATION_WM_WINDOW_FOCUS_IN:
			pass
		NOTIFICATION_WM_WINDOW_FOCUS_OUT:
			pass
		NOTIFICATION_WM_SIZE_CHANGED:
			pass
#endregion
##END Save/Load

# unfocused window not dragging is a known issue that I didn't have to spend a few hours
# troubleshooting what I did wrong...
# issue: https://github.com/godotengine/godot/issues/95577
# pull: https://github.com/godotengine/godot/pull/95606

#region DEBUG
func get_caller_function_name():
	var stack = get_stack()
	if stack.size() > 1:
		# stack[0] is the current function, stack[1] is the caller
		return stack[1]["function"]
	return "Unknown"

func _on_debug_pressed() -> void:
	print("what's up")
#endregion
##END DEBUG
