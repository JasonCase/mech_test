class_name LightBody extends StaticBody3D

func get_hit(_a,_b,_f) -> void:
	if !has_node("SpotLight3D"): return
	var light: SpotLight3D = $SpotLight3D
	var cover: MeshInstance3D = $CollisionShape3D/MeshInstance3D
	var mesh: Mesh = cover.mesh.duplicate(true)
	var mat: Material = (mesh.material as Material).duplicate(true)

	cover.mesh = mesh
	mesh.material = mat
	mat.emission_enabled = false
	
	light.queue_free()
