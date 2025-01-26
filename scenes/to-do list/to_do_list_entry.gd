extends Control

@export var to_do_edit: LineEdit
@export var check_box: TextureButton
@export var animation: AnimationPlayer

func _on_texture_button_toggled(toggled_on) -> void:
	if toggled_on:
		animation.play("checkmark")
	else:
		animation.play_backwards("checkmark")
		
