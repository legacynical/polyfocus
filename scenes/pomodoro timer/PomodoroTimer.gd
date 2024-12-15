class_name PomodoroTimer
extends Node

@onready var timer_elements: VBoxContainer = %TimerElements
@onready var timer_label: Label = %TimerLabel
@onready var focus_time_label: Label = %TotalFocusTime
@onready var timer_button: Button = %TimerButton
@onready var skip_button: Button = %SkipButton
@onready var setting_menu: PanelContainer = %SettingMenu
@onready var setting_menu_scroll: ScrollContainer = %SettingMenuScroll
@onready var task_timer_menu: PanelContainer = %TaskTimerMenu
@onready var task_timer_grid_container: GridContainer = %TTGridContainer
@onready var session_rating: Panel = %SessionRating
@onready var pomo_session: SpinBox = %PomoSession
@onready var break_session: SpinBox = %BreakSession
@onready var long_break_session: SpinBox = %LongBreakSession
@onready var break_session_interval: SpinBox = %BreakSessionInterval
@onready var primer_session: SpinBox = %ProgressivePrimerSession
@onready var neutral_session: SpinBox = %NeutralSession
@onready var focused_session: SpinBox = %FocusedSession
@onready var flow_session: SpinBox = %FlowSession
@onready var timer: Timer = %PomoTimer
@onready var background: Panel = %BackgroundPanel
@onready var focus_color_picker: ColorPickerButton = %FocusColorPicker
@onready var break_color_picker: ColorPickerButton = %BreakColorPicker
@onready var is_progressive_pomo_toggle: TextureButton = %ProgressivePomoToggle
@onready var mode_toggle: TextureButton = %ModeToggle

@onready var saved_game: SavedGame = SavedGame.new()
#@onready var save_file: String = "user://savegame.tres"
@onready var save_file: String = "user://[v0.4.2-beta]savegame.tres"


var default_window_size: Vector2 = Vector2(480, 270)
var default_window_position = null # sets to center of user's primary screen on 1st startup

var is_progressive_pomo_enabled: bool = false
var is_progressive_pomo_break_due: bool = false
var is_switch_mode_on_timeout: bool = true
var is_long_breaks_enabled: bool = true

var is_counting_down: bool = false
var break_session_counter: int = 0
var total_focus_time: int = 0
var session_time: int = 0
var time_left: int = 0
var focus_duration: int = 0
var is_muted: bool = true

enum mode {
	FOCUS,
	BREAK,
	PAUSED
}
var current_mode: mode = mode.FOCUS

func _ready() -> void:
	DisplayServer.window_set_min_size(default_window_size)
	
	setting_menu_scroll.scroll_vertical = 0
	if is_progressive_pomo_enabled:
		reset_timer(primer_session.value)
	else:
		reset_timer(pomo_session.value)
	update_focus_time_label()
	
	#TODO finish transparent mode feature
	# get_tree().get_root().set_transparent_background(true) # sets window transparency
	# DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true) # sets window bar
	# set_semi_transparent(get_tree().get_root())
	
	if not FileAccess.file_exists(save_file):
		save_window()
		save_pomodoro_timer()
		set_default_task_timers()
		save_task_timers()
	load_window()
	load_pomodoro_timer()
	load_task_timers()
	
func _process(_delta: float) -> void:
	if is_counting_down:
		time_left = round(timer.time_left)
		# print(str(timer.time_left) + " -> " + str(time_left))
		update_label()
		if current_mode == mode.FOCUS:
			update_focus_time_label()

# TODO finish transparent mode feature
func set_semi_transparent(node: Node) -> void:
	if node is CanvasItem:
		var visual_node := node as CanvasItem
		visual_node.modulate.a = 0.9
		
	for child in node.get_children():
		set_semi_transparent(child)
	
##### Timer
func update_label() -> void:
	timer_label.text = convert_time(time_left)
	
func update_focus_time_label() -> void:
	if is_counting_down:
		focus_duration = session_time - time_left 
		var current_total_time: int = total_focus_time + focus_duration
		focus_time_label.text = "Total Focus Time [" + convert_time(current_total_time) + "]"
	else:
		update_total_focus_time()
		focus_time_label.text = "Total Focus Time [" + convert_time(total_focus_time) + "]"
		
		
func update_total_focus_time() -> void:
	focus_duration = session_time - time_left
	if focus_duration > 0 and session_time > 0:
		print("Adding focus duration: %d seconds" % focus_duration)
		total_focus_time += focus_duration
		session_time -= focus_duration
		print("New total focus time: %d seconds" % total_focus_time)
	
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
	
	if timer.is_paused(): # if paused, then unpause and count down
		timer.paused = false
		is_counting_down = true
		skip_button.visible = true
		timer_button.text = "PAUSE"
	elif is_counting_down: # if counting down, then pause
		timer.paused = true
		is_counting_down = false
		skip_button.visible = false
		timer_button.text = "RESUME"
		if current_mode == mode.FOCUS:
			update_focus_time_label()
	#TODO: make consistent size images to use for texture button, resume has 1 more char space
	else: # if neither paused nor counting down, then start timer and count down
		timer.start()
		is_counting_down = true
		skip_button.visible = true
		timer_button.text = "PAUSE"
		
	timer_button.disabled = false

func _on_skip_button_pressed() -> void:
	AudioManager.click_basic.play()
	switchMode()
	skip_button.visible = false

func updatePanelColor() -> void:
	var new_stylebox: StyleBox = background.get_theme_stylebox("panel").duplicate()
	if current_mode == mode.FOCUS:
		new_stylebox.bg_color = focus_color_picker.color
		background.add_theme_stylebox_override("panel", new_stylebox)
	elif current_mode == mode.BREAK:
		new_stylebox.bg_color = break_color_picker.color
		background.add_theme_stylebox_override("panel", new_stylebox)
	#else:
		#new_stylebox.bg_color = Color.html("999999")
		#background.add_theme_stylebox_override("panel", new_stylebox)

func _on_pomo_timer_timeout() -> void:
	#AudioManager.timer_complete.play()
	if is_progressive_pomo_enabled and current_mode == mode.FOCUS:
		if is_progressive_pomo_break_due:
			switchMode() # updates TFT
		else:
			rate_session() 
	elif is_switch_mode_on_timeout:
		switchMode() # updates TFT
	else:
		pass # would user even want auto mode switch on timeout off?
		
func reset_timer(new_session_time_in_minutes: int) -> void:
	timer.paused = false
	is_counting_down = false
	timer.stop()
	timer_button.text = "START"
	session_time = new_session_time_in_minutes * 60 # conversion to seconds
	timer.wait_time = session_time
	time_left = session_time
	update_label()
	print("reset timer to " + convert_time(time_left))

# closes menus when clicking outside to the background panel
func _on_background_panel_gui_input(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("pt background panel pressed")
			close_pomodoro_menus()

func close_pomodoro_menus() -> void:
	setting_menu.visible = false
	setting_menu_scroll.scroll_vertical = 0
	task_timer_menu.visible = false
	
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
#####


##### SettingMenu
func _on_setting_menu_button_pressed() -> void:
	AudioManager.click_basic.play()
	print("setting menu button pressed")
	if setting_menu.visible:
		setting_menu.visible = false
		setting_menu_scroll.scroll_vertical = 0
	else:
		setting_menu.visible = true
		task_timer_menu.visible = false
		
func _on_pomo_session_value_changed(_custom_time: int) -> void:
	print("pomo session time changed to " + str(pomo_session.value) + " min")
	update_total_focus_time() # prevents desync? hopefully
	if current_mode == mode.FOCUS:
		@warning_ignore("narrowing_conversion")
		session_time = pomo_session.value
		reset_timer(session_time)

func _on_break_session_value_changed(_custom_time: int) -> void:
	print("break session time changed to " + str(break_session.value) + " min")
	if current_mode == mode.BREAK:
		@warning_ignore("narrowing_conversion")
		session_time = break_session.value
		reset_timer(session_time)

func _on_window_reset_button_pressed() -> void:
	load_window()

func _on_window_save_button_pressed() -> void:
	save_window()

func _on_window_default_button_pressed() -> void:
	AudioManager.click_basic.play()
	print("resetting window")
	DisplayServer.window_set_size(default_window_size)
	DisplayServer.window_set_position(default_window_position)
#####


##### TaskTimerMenu
func _on_task_timer_menu_button_pressed() -> void:
	AudioManager.click_basic.play()
	print("task timer menu button pressed")
	if task_timer_menu.visible:
		task_timer_menu.visible = false
	else:
		task_timer_menu.visible = true
		setting_menu.visible = false
		setting_menu_scroll.scroll_vertical = 0
#####

##### SessionRating
func rate_session() -> void:
	AudioManager.alert_1_mb.play()
	update_total_focus_time()
	timer.paused = true
	is_counting_down = false
	#timer_elements.visible = false
	session_rating.visible = true

func _on_flow_pressed() -> void:
	session_resume(flow_session.value)

func _on_focused_pressed() -> void:
	session_resume(focused_session.value)
	
func _on_neutral_pressed() -> void:
	session_resume(neutral_session.value)

func _on_distracted_pressed() -> void:
	AudioManager.click_basic.play()
	AudioManager.distracted.play()
	#timer_elements.visible = true
	session_rating.visible = false
	reset_timer(primer_session.value)
	
func session_resume(extend_time: int) -> void:
	AudioManager.click_basic.play()
	AudioManager.alert_2_mb.play()
	#timer_elements.visible = true
	session_rating.visible = false
	is_progressive_pomo_break_due = true
	reset_timer(extend_time)
	timer.start()
	is_counting_down = true
	timer_button.text = "PAUSE"
#####

##### Progressive Pomo
func _on_progressive_pomo_toggle_toggled(toggled_on: bool) -> void:
	AudioManager.click_basic.play()
	if toggled_on:
		#is_progressive_pomo_toggle.modulate = Color(1, 1, 1) # normal
		is_progressive_pomo_enabled = true
		reset_timer(primer_session.value)
		print("progressive pomo: true")
	else:
		#is_progressive_pomo_toggle.modulate = Color(0.5, 0.1, 0.1) # red
		is_progressive_pomo_enabled = false
		reset_timer(pomo_session.value)
		print("progressive pomo: false")
#####

##### Focus/Break Toggle
func _on_mode_toggle_toggled(_toggled_on: bool) -> void:
	AudioManager.click_basic.play()
	switchMode()

func switchMode() -> void:
	is_progressive_pomo_break_due = false # prevents unintended breaks
	if current_mode == mode.FOCUS: # switches to break
		update_total_focus_time()
		AudioManager.time_to_break_mb.play()
		@warning_ignore("narrowing_conversion")
		break_session_counter += 1
		print("\nbreak counter: " + str(break_session_counter))
		if break_session_counter % int(break_session_interval.value) == 0:
			reset_timer(long_break_session.value)
		else:
			reset_timer(break_session.value)
		current_mode = mode.BREAK
		mode_toggle.modulate = focus_color_picker.color
		print("break mode")
	else: # switches to focus
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
	updatePanelColor()
#####


##### Save/Load 
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

func save_pomodoro_timer() -> void:
	print("\nsaving pomodoro timer:")
	saved_game.focus_color_picker = focus_color_picker.color
	saved_game.break_color_picker = break_color_picker.color
	#TODO focus color presets
	#TODO break color presets
	saved_game.is_progressive_pomo_enabled = is_progressive_pomo_enabled
	
	saved_game.pomodoro_session = pomo_session.value
	saved_game.break_session = break_session.value
	saved_game.long_break_session = long_break_session.value
	saved_game.break_session_interval = break_session_interval.value

	saved_game.primer_session = primer_session.value
	saved_game.neutral_session = neutral_session.value
	saved_game.focused_session = focused_session.value
	saved_game.flow_session = flow_session.value
	ResourceSaver.save(saved_game, save_file)
	
func load_pomodoro_timer() -> void:
	print("\nloading pomodoro timer:")
	var saved_game: SavedGame = load(save_file) as SavedGame
	focus_color_picker.color = saved_game.focus_color_picker
	break_color_picker.color = saved_game.break_color_picker
	#TODO focus color presets
	#TODO break color presets
	is_progressive_pomo_enabled = saved_game.is_progressive_pomo_enabled
	
	pomo_session.value = saved_game.pomodoro_session
	break_session.value = saved_game.break_session
	long_break_session.value = saved_game.long_break_session
	break_session_interval.value = saved_game.break_session_interval

	primer_session.value = saved_game.primer_session
	neutral_session.value = saved_game.neutral_session
	flow_session.value = saved_game.flow_session
	focused_session.value = saved_game.focused_session

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

func _notification(what) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			save_window() # saves window position & size
			save_pomodoro_timer() # saves pomodoro timer settings
			save_task_timers() # saves task timers
			get_tree().quit() # default behavior
		NOTIFICATION_WM_WINDOW_FOCUS_IN:
			pass
		NOTIFICATION_WM_WINDOW_FOCUS_OUT:
			pass
		NOTIFICATION_WM_SIZE_CHANGED:
			pass
# unfocused window not dragging is a known issue that I didn't have to spend a few hours
# troubleshooting what I did wrong...
# issue: https://github.com/godotengine/godot/issues/95577
# pull: https://github.com/godotengine/godot/pull/95606
#####
