class_name SavedGame
extends Resource

@export var default_window_size: Vector2 = Vector2(480, 270)

@export var default_window_position: Vector2
@export var window_position: Vector2
@export var window_size: Vector2

@export var default_focus_color: Color = Color.html("6fbd90")
@export var default_break_color: Color = Color.html("5370a6")

@export var focus_color: Color
@export var break_color: Color
@export var focus_color_presets: Array
@export var break_color_presets: Array
@export var is_progressive_pomo: bool

@export var pomodoro_session: int
@export var break_session: int
@export var long_break_session: int
@export var break_session_counter: int

@export var flow_session: int
@export var focused_session: int
@export var neutral_session: int

@export var total_focus_time_day: int
@export var total_focus_time_week: int
@export var total_focus_time_month: int
@export var total_focus_time_year: int

@export var journals: Array
