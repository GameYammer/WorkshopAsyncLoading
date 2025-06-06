# Copyright (c) 2025 Game Yammer
# This file is licensed under the MIT License
# https://github.com/GameYammer/WorkshopAsyncLoading

extends Node

var _is_running := false
var _thread : Thread
var _mutex : Mutex
var _semaphore : Semaphore
var _to_inst := []
var _resource_cache := {}

func create_async(scene_path : String, cb : Callable) -> void:
	var entry := {
		"scene_path" : scene_path,
		"cb" : cb,
	}

	_mutex.lock()
	_to_inst.push_back(entry)
	_mutex.unlock()

	_semaphore.post()

func start() -> void:
	if _is_running: return

	_thread = Thread.new()
	_mutex = Mutex.new()
	_semaphore = Semaphore.new()
	var err := _thread.start(_run_instancer_thread, Thread.PRIORITY_LOW)
	assert(err == OK)
	_is_running = true

func stop() -> void:
	if not _is_running: return
	_is_running = false

	if _semaphore:
		_semaphore.post()

	if _thread:
		_thread.wait_to_finish()
		_thread = null

	_to_inst.clear()

func _run_instancer_thread() -> void:
	while _is_running:
		_semaphore.wait()

		var has_entries := true
		while has_entries:
			_mutex.lock()
			var entry = _to_inst.pop_front()
			_mutex.unlock()

			if entry:
				var scene_path : String = entry["scene_path"]
				var cb : Callable = entry["cb"]
				var scene := self._get_resource(scene_path)
				var inst = scene.instantiate()
				cb.call_deferred(inst)
			else:
				has_entries = false

func _get_resource(resource_path : String) -> Resource:
	# Load and cache the resource if not already cached
	if not _resource_cache.has(resource_path):
		_resource_cache[resource_path] = ResourceLoader.load(resource_path)

	return _resource_cache[resource_path]
