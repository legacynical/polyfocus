class_name SaverLoader
extends Node

@onready var entry_title: LineEdit = %EntryTitle
@onready var entry_date: Label = %CurrentDateTime
@onready var entry_text: TextEdit = %EntryText

# file paths doc
# https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html

func _ready() -> void:
	load_journal()

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


func _on_save_pressed() -> void:
	save_journal()
	print("saved journal entry")

func _on_load_pressed() -> void:
	load_journal()
	print("loaded journal entry")
