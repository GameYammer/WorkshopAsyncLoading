# Copyright (c) 2025 Game Yammer
# This file is licensed under the MIT License
# https://github.com/GameYammer/WorkshopAsyncLoading

extends Node3D

@onready var _items := $Cheeses
@onready var _raptor := preload("res://src/Raptor/Raptor.tscn")
@onready var _cheese := preload("res://src/Cheese/Cheese.tscn")

func _init() -> void:
	Global._world = self

func _ready() -> void:
	Global.start()

	# Every 1 second show FPS in the title and label
	var timer := Timer.new()
	Global.add_child(timer)
	var err := timer.connect(&"timeout", Callable(self, &"_on_timer_fps_timeout"))
	assert(err == OK)
	timer.set_wait_time(1.0)
	timer.set_one_shot(false)
	timer.start()
	timer.emit_signal("timeout")

func _on_timer_fps_timeout() -> void:
	var godot_debug := "DEBUG" if OS.is_debug_build() else "RELEASE"
	var fps := Engine.get_frames_per_second()
	var title := "%s (Engine: %s) | FPS: %s" % [Global.GAME_NAME, godot_debug, fps]
	self.get_window().set_title(title)


func _on_button_quit_pressed() -> void:
	Global.quit()

var _total_time := 0
var _total_count := 0
func _on_button_make_cheese_async_pressed() -> void:
	_total_time = 0
	_total_count = 0

	# Remove exiting items
	for items in _items.get_children():
		items.get_parent().remove_child(items)
		items.queue_free()

	const TOTAL_TO_ADD := 30
	for i in TOTAL_TO_ADD:
		var cb := func(cheese) -> void:
			var start := Time.get_ticks_usec()
			var r := 3.0
			var pos := Vector3(
				randf_range(-r, r),
				1.0,
				randf_range(-r, r),
			)
			cheese.transform.origin = _items.to_local(pos)
			cheese.rotation_degrees = Vector3(
				randf_range(0, 360),
				randf_range(0, 360),
				randf_range(0, 360),
			)
			_items.add_child(cheese)
			var end := Time.get_ticks_usec()
			_total_time += (end - start)
			_total_count += 1
			#print(total_count)
			if _total_count == TOTAL_TO_ADD:
				print("Adding cheese async took %d usec" % [_total_time])
		AsyncInstancer.create_async("res://src/Cheese/Cheese.tscn", cb)


func _on_button_make_cheese_sync_pressed() -> void:
	_total_time = 0
	_total_count = 0

	# Remove exiting items
	for items in _items.get_children():
		items.get_parent().remove_child(items)
		items.queue_free()

	var scene : PackedScene = _cheese
	const TOTAL_TO_ADD := 30
	for i in TOTAL_TO_ADD:
		var start := Time.get_ticks_usec()
		var r := 3.0
		var pos := Vector3(
			randf_range(-r, r),
			1.0,
			randf_range(-r, r),
		)
		var cheese = scene.instantiate()
		cheese.transform.origin = _items.to_local(pos)
		cheese.rotation_degrees = Vector3(
			randf_range(0, 360),
			randf_range(0, 360),
			randf_range(0, 360),
		)
		_items.add_child(cheese)
		var end := Time.get_ticks_usec()
		_total_time += (end - start)
		_total_count += 1
		if _total_count == TOTAL_TO_ADD:
			print("Adding cheese sync took %d usec" % [_total_time])


func _on_button_make_raptor_sync_pressed() -> void:
	_total_time = 0
	_total_count = 0

	# Remove exiting items
	for items in _items.get_children():
		items.get_parent().remove_child(items)
		items.queue_free()

	var scene : PackedScene = _raptor
	const TOTAL_TO_ADD := 2
	for i in TOTAL_TO_ADD:
		var start := Time.get_ticks_usec()
		var r := 3.0
		var pos := Vector3(
			randf_range(-r, r),
			0.0,
			randf_range(-r, r),
		)
		#var s := Time.get_ticks_usec()
		var raptor = scene.instantiate()
		#var e := Time.get_ticks_usec()
		#print("instantiate took %d usec" % [e - s])
		raptor.transform.origin = _items.to_local(pos)
		_items.add_child(raptor)
		var end := Time.get_ticks_usec()
		_total_time += (end - start)
		_total_count += 1
		if _total_count == TOTAL_TO_ADD:
			print("Adding raptor sync took %d usec" % [_total_time])


func _on_button_make_raptor_async_pressed() -> void:
	_total_time = 0
	_total_count = 0

	# Remove exiting items
	for items in _items.get_children():
		items.get_parent().remove_child(items)
		items.queue_free()

	const TOTAL_TO_ADD := 2
	for i in TOTAL_TO_ADD:
		var cb := func(raptor) -> void:
			var start := Time.get_ticks_usec()
			var r := 3.0
			var pos := Vector3(
				randf_range(-r, r),
				0.0,
				randf_range(-r, r),
			)
			raptor.transform.origin = _items.to_local(pos)
			_items.add_child(raptor)
			var end := Time.get_ticks_usec()
			_total_time += (end - start)
			_total_count += 1
			#print(total_count)
			if _total_count == TOTAL_TO_ADD:
				print("Adding raptor async took %d usec" % [_total_time])
		AsyncInstancer.create_async("res://src/Raptor/Raptor.tscn", cb)
