"""Extend the courtyard's smooth terraced cliff walls around the front mine."""
import bpy,json
from pathlib import Path
from mathutils import Vector
OUT=Path(r'C:\Users\huske\Desktop\project-mil\artifacts\lobby-layout')
scene=bpy.context.scene
structure=bpy.data.collections['LAYOUT - Export This']
archive=bpy.data.collections['PRE-MINE FLOOR BACKUP - excluded']
guides=bpy.data.collections['PLANNING GUIDES - Do Not Export']
root=bpy.data.objects['EnergyCore_CourtyardLayout']
assert not any(o.name.startswith('Mine enclosure cliff') for o in structure.objects),'Mine is already enclosed'
for ob in list(structure.objects):
 if ob.name.startswith(('Forecourt boundary','Forecourt front boundary')):
  structure.objects.unlink(ob);archive.objects.link(ob)
soil=bpy.data.materials['Cliff - baked orange']
light=bpy.data.materials['Cliff - warm strata']
dark=bpy.data.materials['Cliff - deep strata']
grass=bpy.data.materials['Grass - fresh green']
cap=bpy.data.materials['Grass - checker green']

def box(name,loc,size,mat):
 sx,sy,sz=[v/2 for v in size]
 vertices=[(-sx,-sy,-sz),(sx,-sy,-sz),(sx,sy,-sz),(-sx,sy,-sz),(-sx,-sy,sz),(sx,-sy,sz),(sx,sy,sz),(-sx,sy,sz)]
 faces=[(0,3,2,1),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7),(4,5,6,7)]
 mesh=bpy.data.meshes.new(name);mesh.from_pydata(vertices,[],faces);mesh.update()
 ob=bpy.data.objects.new(name,mesh);structure.objects.link(ob);ob.parent=root
 ob.location=loc;mesh.materials.append(mat)
 attr=mesh.color_attributes.new(name='Color',type='BYTE_COLOR',domain='CORNER')
 mesh.color_attributes.active_color=attr
 for face in mesh.polygons:
  for loop in face.loop_indices:attr.data[loop].color=mat.diffuse_color
 return ob

# Three enclosing sides, matching the existing 18 / 24 / 25+ stud cliff strata.
# Side sections connect directly to the courtyard wall at the entrance end.
for side in [-1,1]:
 for index,(start,end,height) in enumerate([(-282,-236,38),(-236,-190,34),(-190,-144,40)]):
  mid=(start+end)/2;length=end-start
  name=f'Mine enclosure cliff side {side} section {index}'
  box(name+' lower',(side*78,mid,9),(12,length,18),soil)
  box(name+' warm stratum',(side*84,mid,21),(24,length,6),light)
  box(name+' grass shelf',(side*82,mid,24.35),(28,length,1.1),grass)
  box(name+' upper',(side*92,mid,(height+25)/2),(16,length,height-25),soil)
  box(name+' grass crown',(side*92,mid,height+.6),(20,length,1.2),cap)
for index,(x,width,height) in enumerate([(-54,60,38),(0,48,35),(54,60,38)]):
 name=f'Mine enclosure cliff front section {index}'
 box(name+' lower',(x,-288,9),(width,12,18),soil)
 box(name+' warm stratum',(x,-294,21),(width,24,6),light)
 box(name+' grass shelf',(x,-292,24.35),(width,28,1.1),grass)
 box(name+' upper',(x,-302,(height+25)/2),(width,16,height-25),dark)
 box(name+' grass crown',(x,-302,height+.6),(width,20,1.2),cap)
for x in [-76,76]:
 box(f'Mine enclosure cliff corner {x}',(x,-286,17),(10,10,34),light)
 box(f'Mine enclosure cliff corner cap {x}',(x,-286,34.6),(12,12,1.2),grass)

# Preserve the existing open connection; the mine itself remains untouched.
assert tuple(bpy.data.objects['Mine_Placement'].location)==(0,-212,0)
assert bpy.data.objects['Courtyard to mine connection'].dimensions.x==72
manifest=json.loads((OUT/'layout-manifest.json').read_text())
manifest['mine']['enclosure']='Three terraced orange cliff walls with green shelves and crowns, matching the courtyard; lobby entrance remains open'
manifest['mine']['enclosure_height_range']=[34,40]
manifest['overall_layout_size']=[280,484]
(OUT/'layout-manifest.json').write_text(json.dumps(manifest,indent=2))
for ob in scene.objects:ob.select_set(False)
for ob in structure.all_objects:ob.select_set(True)
bpy.context.view_layer.objects.active=root
bpy.ops.export_scene.fbx(filepath=str(OUT/'EnergyCore-CourtyardLayout.fbx'),use_selection=True,
 object_types={'MESH','EMPTY'},axis_forward='-Z',axis_up='Y',global_scale=1,
 apply_unit_scale=True,apply_scale_options='FBX_SCALE_UNITS',colors_type='SRGB',bake_anim=False)
cam=bpy.data.objects['01 Layout overview'];cam.location=(340,-560,720)
cam.rotation_euler=(Vector((0,-65,0))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.ortho_scale=600
cam=bpy.data.objects['02 Top-down plan'];cam.location.y=-70;cam.data.ortho_scale=560
guides.hide_render=False;scene.camera=bpy.data.objects['01 Layout overview']
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'EnergyCore-CourtyardLayout.blend'))
for camera,filename in [('01 Layout overview','courtyard-overview.png'),('02 Top-down plan','courtyard-plan.png')]:
 scene.camera=bpy.data.objects[camera];scene.render.filepath=str(OUT/filename)
 bpy.ops.render.render(write_still=True)
scene.camera=bpy.data.objects['01 Layout overview']
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'EnergyCore-CourtyardLayout.blend'))
report=json.loads((OUT/'validation.json').read_text())
report['mine_enclosed']=True;report['entrance_width']=72
report['enclosure_meshes']=len([o for o in structure.objects if o.name.startswith('Mine enclosure cliff')])
report['mesh_count']=len([o for o in structure.all_objects if o.type=='MESH'])
report['triangles']=sum(len(p.vertices)-2 for o in structure.all_objects if o.type=='MESH' for p in o.data.polygons)
(OUT/'validation.json').write_text(json.dumps(report,indent=2))
print('MINE ENCLOSED: matching orange terraced walls and green caps on three sides; 72-stud lobby entrance stays open')
