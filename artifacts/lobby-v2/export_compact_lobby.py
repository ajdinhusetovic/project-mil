import bpy, json, math
from pathlib import Path
from mathutils import Vector
OUT=Path('/Users/ajdinhusetovic/Desktop/ProjectMilka/artifacts/lobby-v2')
original_scene=bpy.context.scene
original_scene.unit_settings.system='NONE'
root=bpy.data.collections['COMPACT LOBBY V2']
excluded=set(bpy.data.collections['V2 PresentationOnly'].all_objects)
source=[o for o in root.all_objects if o not in excluded and o.type in {'MESH','FONT','EMPTY'}]
source_meshes=[o for o in source if o.type in {'MESH','FONT'}]
deps=bpy.context.evaluated_depsgraph_get()
meshes={o:bpy.data.meshes.new_from_object(o.evaluated_get(deps)) for o in source_meshes}
original_names={o:o.name for o in source}
# Free names so the exported hierarchy retains meaningful group names.
for o in source:o.name='__V2_SOURCE__'+original_names[o]
export_scene=bpy.data.scenes.new('V2 export validation');bpy.context.window.scene=export_scene
export_scene.unit_settings.system='NONE'
model=bpy.data.objects.new('EnergyCoreLobbyV2',None);export_scene.collection.objects.link(model)
clones={};palette={}
for original in source:
    name=original_names[original]
    if name.startswith('CoreMount'):name='CoreMount'
    data=meshes[original] if original in meshes else None
    obj=bpy.data.objects.new(name,data);export_scene.collection.objects.link(obj);clones[original]=obj
    obj.matrix_basis=original.matrix_basis.copy();obj.matrix_parent_inverse=original.matrix_parent_inverse.copy()
    if data is not None:
        attr=data.color_attributes.get('Color') or data.color_attributes.new(name='Color',type='BYTE_COLOR',domain='CORNER')
        data.color_attributes.active_color=attr
        for face in data.polygons:
            color=data.materials[face.material_index].diffuse_color if data.materials else (1,1,1,1)
            for idx in face.loop_indices:attr.data[idx].color=color
        srgb=attr.data[0].color_srgb if len(attr.data) else (1,1,1,1)
        palette[obj.name]=[round(c*255) for c in srgb[:3]]
for original,obj in clones.items():obj.parent=clones.get(original.parent,model)
bpy.context.view_layer.update()
for obj in export_scene.objects:obj.select_set(True)
bpy.context.view_layer.objects.active=model
path=OUT/'EnergyCoreLobby-V2-Colored.fbx'
bpy.ops.export_scene.fbx(filepath=str(path),use_selection=True,object_types={'MESH','EMPTY'},apply_unit_scale=True,global_scale=1,apply_scale_options='FBX_SCALE_UNITS',axis_forward='-Z',axis_up='Y',bake_anim=False,colors_type='SRGB',use_custom_props=True)
(OUT/'palette.json').write_text(json.dumps(palette,indent=2))
# Validate color payload and dimensions after reimport into Blender.
before=set(bpy.data.objects)
bpy.ops.import_scene.fbx(filepath=str(path))
imported=[o for o in bpy.data.objects if o not in before and o.type=='MESH']
assert len(imported)==len(source_meshes),(len(imported),len(source_meshes))
assert all(o.data.color_attributes for o in imported),'Missing vertex colors'
bpy.context.view_layer.update()
import_counter=next(o for o in imported if o.name.startswith('WeaponStore_Counter'))
assert abs(import_counter.dimensions.x-8.3)<.01,tuple(import_counter.dimensions)
colors=set(tuple(round(v,3) for v in o.data.color_attributes[0].data[0].color_srgb) for o in imported if len(o.data.color_attributes[0].data))
assert len(colors)>=15,len(colors)
print('VERIFIED:',len(imported),'colored meshes,',len(colors),'colors; counter width',round(import_counter.dimensions.x,3),'units. FBX Unit Scale used.')
for o in list(export_scene.objects):bpy.data.objects.remove(o,do_unlink=True)
bpy.context.window.scene=original_scene;bpy.data.scenes.remove(export_scene)
for o,name in original_names.items():o.name=name
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'EnergyCoreLobby-V2.blend'))
print('Export complete; editable V2 lobby active in Blender.')
