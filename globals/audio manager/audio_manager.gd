extends Node

@onready var click_basic: AudioStreamPlayer = %ClickBasic
@onready var timer_complete: AudioStreamPlayer = %TimerComplete
@onready var metal_pipe: AudioStreamPlayer = %MetalPipe
@onready var _40_hz_focus_100: AudioStreamPlayer = %"40hzFocus100" # L100hz R140hz
@onready var _40_hz_focus_250: AudioStreamPlayer = %"40hzFocus250" # L250hz R290hz
@onready var _40_hz_focus_400: AudioStreamPlayer = %"40hzFocus400" # L400hz R440hz
@onready var time_to_focus_mb: AudioStreamPlayer = %TimeToFocusMB
@onready var time_to_break_mb: AudioStreamPlayer = %TimeToBreakMB
@onready var notification_mb: AudioStreamPlayer = %NotificationMB
@onready var alert_1_mb: AudioStreamPlayer = %Alert1MB
@onready var alert_2_mb: AudioStreamPlayer = %Alert2MB
@onready var distracted: AudioStreamPlayer = %Distracted
