extends Node

@export var player: Node3D
@export var camera_rig: Node3D
@export var host: String = "127.0.0.1"
@export var port: int = 9001
@export var send_interval: float = 0.05

var udp := PacketPeerUDP.new()
var timer: float = 0.0
var last_payload: Dictionary = {}

func _ready():
	if player == null:
		player = get_node("../Player")
	if camera_rig == null:
		camera_rig = get_node("../View")

	if player != null and camera_rig != null:
		udp.connect_to_host(host, port)
		print("Telemetry stream ready: ", host, ":", port)
	else:
		print("Telemetry stream disabled: player or camera not found")

func _process(delta):
	if player == null or camera_rig == null:
		return

	# Jump presses are sent immediately so they are never missed between position samples.
	if Input.is_action_just_pressed("jump"):
		send_frame(true)

	timer -= delta
	if timer <= 0.0:
		timer = send_interval
		send_frame(false)

func send_frame(jump_pressed: bool):
	var pos = player.global_position
	var rot = camera_rig.global_rotation_degrees

	var payload_data := {
		"x": snapped(pos.x, 0.001),
		"y": snapped(pos.y, 0.001),
		"z": snapped(pos.z, 0.001),
		"camera_x": snapped(rot.x, 0.001),
		"camera_y": snapped(rot.y, 0.001),
		"camera_z": snapped(rot.z, 0.001),
		"jump": jump_pressed,
	}

	if payload_data == last_payload and not jump_pressed:
		return

	last_payload = payload_data
	var payload = JSON.stringify(payload_data)

	udp.put_packet(payload.to_utf8_buffer())
