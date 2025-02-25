extends Label

@onready var polyfocus_version: String = ProjectSettings.get_setting("application/config/version")

# Called when the node enters the scene tree for the first time.
func _ready():
	self.text = "v" + polyfocus_version
