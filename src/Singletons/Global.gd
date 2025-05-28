# Copyright (c) 2025 Game Yammer
# This file is licensed under the MIT License
# https://github.com/GameYammer/WorkshopAsyncLoading

extends Node

const GAME_NAME := "Game of Cheese"

var _world : Node3D
var _is_quit_triggered := false

func _ready() -> void:
	# Turn off the generic auto quit handler
	self.get_tree().set_auto_accept_quit(false)

func _notification(what : int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		self.quit()

func start() -> void:
	AsyncInstancer.start()

func quit() -> void:
	if _is_quit_triggered: return
	_is_quit_triggered = true

	# Shut down all the background threads
	AsyncInstancer.stop()

	# Propagate shutdown
	self.get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)

	# Actually quit
	self.get_tree().quit()
