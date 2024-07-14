extends Node3D

@onready var player_mesh : MeshInstance3D = $Player/GeneralSkeleton/Booker_7295
@onready var player_animation_player : AnimationPlayer = $Player/AnimationPlayer
@onready var vrms : Node3D = $VRMs
@onready var file_dialog : Node = $FileDialog
var path_external_vrm = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	player_animation_player.play('movement/walk')

func load_vrm_as_player(vrm_name):
	var meshNode = vrms.get_node(vrm_name + "/GeneralSkeleton").get_child(0)
	player_mesh.mesh = meshNode.mesh

func save_vrm_from_pc():
	var gltf: GLTFDocument = GLTFDocument.new()
	var vrm_extension: GLTFDocumentExtension = preload("res://addons/vrm/vrm_extension.gd").new()
	gltf.register_gltf_document_extension(vrm_extension, true)
	
	var state: GLTFState = GLTFState.new()
	# state.handle_binary_image = GLTFState.HANDLE_BINARY_EMBED_AS_BASISU

	# Ensure Tangents is required for meshes with blend shapes as of Godot 4.2.
	# EditorSceneFormatImporter.IMPORT_GENERATE_TANGENT_ARRAYS = 8
	# EditorSceneFormatImporter may not be available in release builds, so hardcode 8 for flags
	var err = gltf.append_from_file(path_external_vrm, state, 8)
	if err != OK:
		gltf.unregister_gltf_document_extension(vrm_extension)
		return null
	
	var generated_scene = gltf.generate_scene(state)
	
	vrms.add_child(generated_scene)
	
	gltf.unregister_gltf_document_extension(vrm_extension)
	
	return generated_scene.name


func _on_file_dialog_file_selected(path):
	path_external_vrm = path
	
	var vrm_name = save_vrm_from_pc()
	
	if vrm_name:
		load_vrm_as_player(vrm_name)

func _input(event):
	if event.is_action_pressed("ui_filedialog_show_hidden"):
		file_dialog.popup_centered()
