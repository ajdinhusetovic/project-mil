import bpy, json
from pathlib import Path
from mathutils import Vector
OUT=Path('/Users/ajdinhusetovic/Desktop/ProjectMilka/artifacts/lobby-finished')
original_scene=bpy.context.scene
root=bpy.data.collections['EnergyCoreMining_Lobby']
excluded=set()
for name in ['ReviewGuides','Presentation']:
    if bpy.data.collections.get(name):excluded.update(bpy.data.collections[name].all_objects)
source=[o for o in root.all_objects if o not in excluded and o.type in {'MESH','EMPTY'}]
meshes=[o for o in source if o.type=='MESH']
original_scene.unit_settings.system='NONE'
bpy.context.view_layer.update()
deps=bpy.context.evaluated_depsgraph_get()
mesh_data={o:bpy.data.meshes.new_from_object(o.evaluated_get(deps)) for o in meshes}
worlds={o:o.matrix_world.copy() for o in source}
names={o:o.name for o in source}
for o in source:o.name='__EXPORT_SOURCE__'+names[o]
scene=bpy.data.scenes.new('Colored lobby export');scene.unit_settings.system='NONE';bpy.context.window.scene=scene
model=bpy.data.objects.new('EnergyCoreMiningLobby',None);scene.collection.objects.link(model)
clones={}
for original in source:
    o=bpy.data.objects.new(names[original],mesh_data.get(original));scene.collection.objects.link(o);clones[original]=o
    for key in original.keys():
        if key!='_RNA_UI':
            try:o[key]=original[key]
            except Exception:pass
for original,o in clones.items():
    o.parent=clones.get(original.parent,model)
    o.matrix_parent_inverse=original.matrix_parent_inverse.copy();o.matrix_basis=original.matrix_basis.copy()
bpy.context.view_layer.update()
for original,o in clones.items():
    if original.type!='MESH':continue
    assert max(abs(worlds[original][i][j]-o.matrix_world[i][j]) for i in range(4) for j in range(4))<1e-4,original.name
    mesh=o.data
    attr=mesh.color_attributes.get('Color') or mesh.color_attributes.new(name='Color',type='BYTE_COLOR',domain='CORNER');mesh.color_attributes.active_color=attr
    for face in mesh.polygons:
        mat=mesh.materials[face.material_index] if mesh.materials else None
        color=mat.diffuse_color if mat else (1,1,1,1)
        for loop in face.loop_indices:attr.data[loop].color=color
    mesh.calc_loop_triangles();assert len(mesh.loop_triangles)<10000,(o.name,len(mesh.loop_triangles))
for o in scene.objects:o.select_set(True)
bpy.context.view_layer.objects.active=model
path=OUT/'EnergyCoreMining-COLORED.fbx'
bpy.ops.export_scene.fbx(filepath=str(path),use_selection=True,object_types={'MESH','EMPTY'},global_scale=1,apply_unit_scale=True,apply_scale_options='FBX_SCALE_UNITS',axis_forward='-Z',axis_up='Y',colors_type='SRGB',use_mesh_modifiers=True,bake_anim=False,use_custom_props=False)
# Check color payload survives serialization and that unit scale is preserved.
before=set(bpy.data.objects)
bpy.ops.import_scene.fbx(filepath=str(path))
imported=[o for o in bpy.data.objects if o not in before and o.type=='MESH']
assert len(imported)==len(meshes),(len(imported),len(meshes))
assert all(o.data.color_attributes for o in imported),'Missing vertex color payload'
colors=set()
for o in imported:
    a=o.data.color_attributes[0]
    for index in range(0,len(a.data),max(1,len(a.data)//4)):colors.add(tuple(round(v,3) for v in a.data[index].color_srgb[:3]))
assert len(colors)>20,len(colors)
bpy.context.view_layer.update()
forward=next(o for o in imported if o.name.startswith('Paths__ForwardToMine'))
assert abs(forward.dimensions.x-12)<.01,tuple(forward.dimensions)
print('VERIFIED:',len(imported),'separate colored meshes;',len(colors),'colors; forward path width',round(forward.dimensions.x,3),'units. Max triangle count below 10,000 per mesh.')
for o in list(scene.objects):bpy.data.objects.remove(o,do_unlink=True)
bpy.context.window.scene=original_scene;bpy.data.scenes.remove(scene)
for o,name in names.items():o.name=name
print('EXPORTED:',str(path),'bytes:',path.stat().st_size)
