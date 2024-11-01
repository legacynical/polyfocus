extends Panel

# Dictionary to hold the journal data
var journal_data: Dictionary = {}

@onready var entry_title: LineEdit = %EntryTitle
@onready var entry_date: Label = %CurrentDateTime
@onready var entry_text: TextEdit = %EntryText

# Path to the save file
var save_file_path: String = "user://save/journals/journal_data.json"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#save_journal_data()
	#load_journal_data()
	pass

# Function to save the journal data to a file
func save_journal_data() -> void:
	var file: FileAccess = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(journal_data))
		file.close()

func save_journal() -> void:
	# Godot guarantees write access to user:// when exporting
	var file: FileAccess = FileAccess.open("user://journal_entry.json", FileAccess.WRITE)
	
	var saved_entry: Dictionary = {}
	
	saved_entry["entry_title"] = entry_title.text
	saved_entry["entry_date"] = entry_date.text
	saved_entry["entry_text"] = entry_text.text
	
	# attempts to convert any Godot variable into JSON
	var json: String = JSON.stringify(saved_entry)
	file.store_string(json)
	file.close()
	
func load_journal() -> void:
	var file: FileAccess = FileAccess.open("user://journal_entry.json", FileAccess.READ)
	
	# reads whole file into a string
	var json: String = file.get_as_text()
	
	# retrieves saved dictionary
	var saved_entry: Dictionary = JSON.parse_string(json)
	
	entry_title.text = saved_entry["entry_title"]
	entry_date.text = saved_entry["entry_date"]
	entry_text.text = saved_entry["entry_text"] 
	
	file.close()	
# Function to load the journal data from a file
#func load_journal_data() -> void:
	#if FileAccess.file_exists(save_file_path):
		#var file: FileAccess = FileAccess.open(save_file_path, FileAccess.READ)
		#if file:
			#var json_data: String = file.get_as_text()
			#journal_data = JSON.parse_string(json_data).result
			#file.close()

## TODO make a functional entry system
