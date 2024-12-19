class_name SavedGame
extends Resource

##### save_window() & load_window()
@export var default_window_size: Vector2 = Vector2(480, 270)
@export var default_window_position: Vector2
@export var window_position: Vector2
@export var window_size: Vector2
#####

##### save_pomodoro_timer() & load_pomodoro_timer()
@export var default_focus_color: Color = Color.html("6fbd90")
@export var default_break_color: Color = Color.html("5370a6")

@export var focus_color_picker: Color
@export var break_color_picker: Color
@export var focus_color_picker_presets: Array
@export var break_color_picker_presets: Array
@export var is_progressive_pomo_enabled: bool

@export var pomodoro_session: int
@export var break_session: int
@export var long_break_session: int
@export var break_session_interval: int

@export var primer_session: int
@export var flow_session: int
@export var focused_session: int
@export var neutral_session: int

@export var auto_extend_id: int
@export var rating_timeout: int
#####

##### save_stats() & load_stats()
#TODO
@export var total_focus_time_day: int
@export var total_focus_time_week: int
@export var total_focus_time_month: int
@export var total_focus_time_year: int
#####

##### save_task_timers() & load_task_timers
#TODO
@export var task_timers: Array
#####

##### save_journals() & load_journals
#TODO
@export var journals: Array
#####
