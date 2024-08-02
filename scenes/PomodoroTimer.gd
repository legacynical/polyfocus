extends Node

@onready var label = $TimerLabel
@onready var timer = $PomoTimer
@onready var timer_button = $TimerButton

@export var session_time: int

var counting_down: bool = false
var time_left: int

func _ready():
    time_left = session_time
    timer.wait_time = time_left
    update_label()

func _process(_delta):
    if counting_down:
        time_left = timer.time_left
        update_label()

func update_label():
    var minutes = floor(time_left / 60)
    var seconds = int(time_left) % 60
    label.text = "%02d:%02d" % [minutes, seconds]

func _on_timer_button_pressed():
    if timer.is_paused(): # if paused, then unpause and count down
        timer.paused = false
        counting_down = true
        timer_button.text = "PAUSE"
    elif counting_down: # if counting down, then pause
        timer.paused = true
        counting_down = false
        timer_button.text = "RESUME"
    else: # if neither paused and counting down, then start timer and count down
        timer.start()
        counting_down = true
        timer_button.text = "PAUSE"
        
      
        
func _on_pomo_timer_timeout():
    print("countdown complete!")
    reset_timer()
    
    
func reset_timer():
    timer.stop()
    counting_down = false
    timer_button.text = "START"
    time_left = session_time
    update_label()

