import bpy, json
from pathlib import Path
folder=Path('/Users/ajdinhusetovic/Desktop/ProjectMilka/artifacts/lobby')
root=bpy.data.collections['ENERGY CORE - Lobby']
source=[o for o in root.all_objects if o.type in {'MESH','FONT'}]
print('Inspect:',len(source),'objects;',sum(bool(o.data.color_attributes) for o in source if o.type=='MESH'),'with vertex colors')
original_scene=bpy.context.scene
evaluated_meshes={o:bpy.data.meshes.new_from_object(o.evaluated_get(bpy.context.evaluated_depsgraph_get())) for o in source}
scene=bpy.data.scenes.new('Roblox Color Export')
bpy.context.window.scene=scene
palette={}
for original in source:
    mesh=evaluated_meshes[original]
    obj=bpy.data.objects.new(original.name,mesh);scene.collection.objects.link(obj);obj.matrix_world=original.matrix_world.copy()
    attr=mesh.color_attributes.new(name='Color',type='BYTE_COLOR',domain='CORNER')
    mesh.color_attributes.active_color=attr
    for face in mesh.polygons:
        mat=mesh.materials[face.material_index] if mesh.materials else None
        color=(1,1,1,1)
        if mat:
            node=next((n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED'),None) if mat.use_nodes else None
            color=tuple(node.inputs['Base Color'].default_value) if node else tuple(mat.diffuse_color)
        for loop in face.loop_indices:attr.data[loop].color=color
    srgb=tuple(attr.data[0].color_srgb) if len(attr.data) else (1,1,1,1)
    palette[obj.name]=[round(v*255) for v in srgb[:3]]
    obj.select_set(True)
bpy.context.view_layer.objects.active=obj
bpy.ops.export_scene.fbx(filepath=str(folder/'EnergyCoreLobby-Colored.fbx'),use_selection=True,object_types={'MESH'},apply_unit_scale=False,global_scale=1,axis_forward='-Z',axis_up='Y',use_mesh_modifiers=True,bake_anim=False,colors_type='SRGB')
# A color fallback for either the old or new import; match exporter suffixes.
lines=['-- Select the imported lobby Model, then run in Studio Command Bar in Edit mode.', 'local model = game:GetService("Selection"):Get()[1]', 'assert(model and model:IsA("Model"), "Select the imported lobby Model first")', 'local palette = {']
for name,rgb in sorted(palette.items()):
    # Blender clone adds suffix; original export did too.
    lines.append('    ['+json.dumps(name)+'] = Color3.fromRGB('+','.join(map(str,rgb))+'),')
    base=name.rsplit('.',1)[0] if name.rsplit('.',1)[-1].isdigit() else name
    if base!=name:lines.append('    ['+json.dumps(base)+'] = Color3.fromRGB('+','.join(map(str,rgb))+'),')
lines+=['}', 'local changed = 0', 'for _, part in model:GetDescendants() do', '    if part:IsA("BasePart") then', '        local color = palette[part.Name] or palette[part.Name:gsub("%.%d+$", "")]', '        if color then part.Color = color; changed += 1 end', '    end', 'end', 'print("Applied lobby colors to " .. changed .. " parts")']
(folder/'apply_lobby_colors.lua').write_text('\n'.join(lines)+'\n')
# Inspect reimported FBX to verify vertex-color payload survives serialization.
before=set(bpy.data.objects)
bpy.ops.import_scene.fbx(filepath=str(folder/'EnergyCoreLobby-Colored.fbx'))
imported=[o for o in bpy.data.objects if o not in before and o.type=='MESH']
colored=[o for o in imported if o.data.color_attributes]
assert len(colored)==len(source),(len(colored),len(source))
unique=set()
for o in colored:
    a=o.data.color_attributes[0]
    if len(a.data):unique.add(tuple(round(v,3) for v in a.data[0].color_srgb))
assert len(unique)>10,len(unique)
print('VERIFIED: FBX roundtrip:',len(colored),'colored meshes;',len(unique),'distinct colors')

for obj in list(scene.objects):
    bpy.data.objects.remove(obj,do_unlink=True)
bpy.context.window.scene=original_scene
bpy.data.scenes.remove(scene)
print("Returned to editable original lobby scene")
