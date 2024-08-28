extends Label

# Boolean to track day or night
var is_daytime: bool = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var current_time: Dictionary = Time.get_datetime_dict_from_system()
	
	# Extract the hour in 24-hour format
	var hour_24: int = current_time.hour
	
	# Determine if it's AM or PM and convert to 12-hour format
	var period: String = "AM"
	var hour_12: int = hour_24
	if hour_24 >= 12:
		period = "PM"
		if hour_24 > 12:
			hour_12 = hour_24 - 12
	elif hour_24 == 0:
		hour_12 = 12  # Midnight edge case
	
	# Determine if it's daytime or nighttime
	is_daytime = hour_24 >= 6 and hour_24 < 18  # Daytime from 6 AM to 6 PM
	
	# Format the date and time as a string
	var formatted_time: String = (
		str(current_time.year) + "-" + 
		str(current_time.month).pad_zeros(2) + "-" + 
		str(current_time.day).pad_zeros(2) + " " + 
		str(hour_12).pad_zeros(2) + ":" + 
		str(current_time.minute).pad_zeros(2) + ":" + 
		str(current_time.second).pad_zeros(2) + " " + 
		period
	)
	
	# Set the label's text to the formatted time
	text = formatted_time
