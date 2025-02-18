class_name SavedGame
extends Resource

#region save_window() & load_window()
@export var default_window_size: Vector2 = Vector2(480, 270)
@export var default_window_position: Vector2
@export var window_position: Vector2
@export var window_size: Vector2
#endregion

#region save_pomodoro_timer() & load_pomodoro_timer()
@export var default_focus_color: Color = Color.html("6fbd90")
@export var default_break_color: Color = Color.html("5370a6")

@export var focus_color_picker: Color
@export var break_color_picker: Color
# color presets not implemented yet
@export var focus_color_picker_presets: Array
@export var break_color_picker_presets: Array

@export var pomodoro_session: int
@export var break_session: int
@export var long_break_session: int

@export var is_long_breaks_enabled: bool
@export var break_session_interval: int
@export var is_progressive_pomo_enabled: bool
@export var auto_extend_id: int
@export var rating_timeout: int

@export var primer_session: int
@export var neutral_session: int
@export var focused_session: int
@export var flow_session: int
#endregion


#region save_audio_setting() & load_audio_setting()
@export var audio_settings: Array
#endregion

#region save_stats() & load_stats()
#TODO
@export var total_focus_time_day: int
@export var total_focus_time_week: int
@export var total_focus_time_month: int
@export var total_focus_time_year: int
#endregion

#region save_quick_timers() & load_quick_timers()
@export var custom_qt_session: int
@export var is_qt_one_click_start: bool
#endregion

#region save_task_timers() & load_task_timers
#TODO
@export var task_timers: Array
#endregion

#region save_journals() & load_journals
#TODO
@export var journals: Array
#endregion
