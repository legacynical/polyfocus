extends Control

@onready var date_time_label: Label = %CurrentDateTime

var current_time: Dictionary
var hour_24: int
var hour_12: int
var is_daytime: bool
var period: String = "??"

func _process(_delta: float) -> void:
	current_time = Time.get_datetime_dict_from_system()
	
	# Extract the hour in 24-hour format
	hour_24 = current_time.hour
	hour_12 = hour_24
	period = "AM"
	
	if hour_24 >= 12: # 12:00 ~ 23:59
		if hour_24 > 12: # hours 13 ~ 23
			hour_12 = hour_24 - 12 # converts to 1 ~ 11 PM
			period = "PM"
	elif hour_24 == 0: # 00:00
		hour_12 = 12 # midnight
		
	# Determine if it's daytime or nighttime
	is_daytime = hour_24 >= 6 and hour_24 < 18  # Daytime from 6 AM to 6 PM
	
	# Format the date and time as a string
	#ISO 8601 (YYYY-MM-DDThh:mm:ssZ)
	var formatted_time: String = (
		str(current_time.year) + "-" + 
		str(current_time.month).pad_zeros(2) + "-" + 
		str(current_time.day).pad_zeros(2) + "T" + 
		str(current_time.hour).pad_zeros(2) + ":" + 
		str(current_time.minute).pad_zeros(2) + ":" + 
		str(current_time.second).pad_zeros(2) + "Z"
	)
	
	# Set the label's text to the formatted time
	date_time_label.text = formatted_time
