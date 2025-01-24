extends Control

@export var to_do_edit: LineEdit
@export var to_do_label: RichTextLabel

func _on_line_edit_text_changed(new_text) -> void:
	to_do_label.text = new_text
