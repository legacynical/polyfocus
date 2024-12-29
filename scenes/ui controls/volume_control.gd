extends HBoxContainer

@export var bus_name: String

@onready var volume_label = %VolumeLabel
@onready var volume_slider = %VolumeSlider

var bus_index: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)
	volume_slider.value_changed.connect(_on_value_changed)
	
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index)) - 0.25
	volume_label.text = str(volume_slider.value * 100)
	
func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(value) # this sets volume sliders to work more intuitively
	)
	volume_label.text = str(value * 100)
