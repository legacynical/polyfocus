extends Panel

# Dictionary to hold the journal data
var journal_data: Dictionary = {}

# Path to the save file
var save_file_path: String = "user://save/journals/journal_data.json"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_journal_data()


# Function to save the journal data to a file
func save_journal_data() -> void:
	var file: FileAccess = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(journal_data))
		file.close()

# Function to load the journal data from a file
func load_journal_data() -> void:
	if FileAccess.file_exists(save_file_path):
		var file: FileAccess = FileAccess.open(save_file_path, FileAccess.READ)
		if file:
			var json_data: String = file.get_as_text()
			journal_data = JSON.parse_string(json_data).result
			file.close()

## TODO make a functional entry system
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		var current_time: Dictionary = Time.get_datetime_dict_from_system()
		var date_str: String = (
			str(current_time.year) + "-" + 
			str(current_time.month).pad_zeros(2) + "-" + 
			str(current_time.day).pad_zeros(2))
