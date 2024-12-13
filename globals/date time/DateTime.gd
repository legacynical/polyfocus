extends Control

@onready var date_time_label: Label = %CurrentDateTime

var cached_date: Dictionary
var cached_time: Dictionary

var hour_24: int
var hour_12: int
var is_daytime: bool
var period: String = "??"

func _ready() -> void:
	update_date()
	update_time()

func _process(_delta: float) -> void:
	if int(Time.get_ticks_msec() / 1000) % 1 == 0: # get_ticks_msec() has cheap computational cost
		update_time() # called roughly every second instead of frame

func update_date() -> void:
	cached_date = Time.get_date_dict_from_system()

func update_time() -> void:
	cached_time = Time.get_time_dict_from_system()
		# Extract the hour in 24-hour format
	hour_24 = cached_time.hour
	hour_12 = hour_24
	period = "AM"
	
	if hour_24 >= 12: # 12:00 ~ 23:59
		if hour_24 > 12: # hours 13 ~ 23
			hour_12 = hour_24 - 12 # converts to 1 ~ 11 PM
			period = "PM"
	elif hour_24 == 0: # 00:00
		update_date()
		hour_12 = 12 # midnight
		
	# Determine if it's daytime or nighttime
	is_daytime = hour_24 >= 6 and hour_24 < 18  # Daytime from 6 AM to 6 PM
	
	# Set the label's text to the formatted time
	date_time_label.text = format_date_time_string()	

# Format the date and time as a string
#ISO 8601 (YYYY-MM-DDThh:mm:ssZ)
func format_date_time_string() -> String:
	return (
		str(cached_date.year) + "-" + 
		str(cached_date.month).pad_zeros(2) + "-" + 
		str(cached_date.day).pad_zeros(2) + "T" + 
		str(cached_time.hour).pad_zeros(2) + ":" + 
		str(cached_time.minute).pad_zeros(2) + ":" + 
		str(cached_time.second).pad_zeros(2) + "Z"
	)

func _on_button_pressed() -> void:
	print(Time.get_datetime_dict_from_system())
	print(format_date_time_string())
