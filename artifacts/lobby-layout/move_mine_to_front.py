"""Place the mine in an adjoining front forecourt; keep central lobby unobstructed."""
import bpy,json
from pathlib import Path
from mathutils import Vector
OUT=Path(r'C:\Users\huske\Desktop\project-mil\artifacts\lobby-layout')
scene=bpy.context.scene
structure=bpy.data.collections['LAYOUT - Export This']
guides=bpy.data.collections['PLANNING GUIDES - Do Not Export']
root=bpy.data.objects['EnergyCore_CourtyardLayout']
archive=bpy.data.collections['PRE-MINE FLOOR BACKUP - excluded']
assert bpy.data.objects['Mine shaft - west'].location.y==0, 'Front mine already moved'

def archive_object(ob):
 structure.objects.unlink(ob);archive.objects.link(ob)

# Undo the center opening by restoring the original complete floor plates.
for ob in list(structure.objects):
 if '_MineCut_' in ob.name: archive_object(ob)
for ob in list(archive.objects):
 if '_MineCut_' not in ob.name:
  archive.objects.unlink(ob);structure.objects.link(ob)

def box(name,loc,size,material):
 sx,sy,sz=[v/2 for v in size]
 vertices=[(-sx,-sy,-sz),(sx,-sy,-sz),(sx,sy,-sz),(-sx,sy,-sz),(-sx,-sy,sz),(sx,-sy,sz),(sx,sy,sz),(-sx,sy,sz)]
 faces=[(0,3,2,1),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7),(4,5,6,7)]
 mesh=bpy.data.meshes.new(name);mesh.from_pydata(vertices,[],faces);mesh.update()
 ob=bpy.data.objects.new(name,mesh);structure.objects.link(ob);ob.parent=root
 ob.location=loc;mesh.materials.append(material);return ob

mine_y=-212
for ob in structure.objects:
 if ob.name.startswith(('Mine plaza -','Mine lip -','Mine shaft -','Mine bedrock')):
  ob.location.y+=mine_y
bpy.data.objects['Mine_Placement'].location.y=mine_y
bpy.data.objects['Mine planning label'].location.y=mine_y

# An opening through every front wall stratum connects the forecourt to the lobby.
for ob in list(structure.objects):
 if not ob.name.startswith('EndCliff_-1_'):continue
 x,y,z=ob.location;w,d,h=ob.dimensions
 if x+w/2<=-50 or x-w/2>=50:continue
 for side,(a,b) in enumerate([(x-w/2,min(x+w/2,-50)),(max(x-w/2,50),x+w/2)]):
  if b-a>.001:box(ob.name+f'_EntranceCut_{side}',((a+b)/2,y,z),(b-a,d,h),ob.data.materials[0])
 archive_object(ob)

grass=bpy.data.materials['Grass - fresh green']
soil=bpy.data.materials['Cliff - deep strata']
stone=bpy.data.materials['Walkway - cool grey']
dark=bpy.data.materials['Trim - graphite']

# Rectangular rings leave the mine interior completely empty all the way down.
for name,base,height,mat in [('Front forecourt soil',-3.32,6,soil),('Front forecourt grass',-.16,.32,grass)]:
 box(name+' west',(-54,mine_y-1,base),(36,138,height),mat)
 box(name+' east',(54,mine_y-1,base),(36,138,height),mat)
 box(name+' front',(0,mine_y-53,base),(72,34,height),mat)
 box(name+' rear',(0,mine_y+52,base),(72,32,height),mat)
box('Courtyard to mine connection',(0,-147,.195),(72,34,.08),stone)
for x in [-71,71]:
 box('Forecourt boundary '+str(x),(x,mine_y,1),(2,140,2),soil)
 box('Forecourt boundary grass '+str(x),(x,mine_y,2.2),(2.3,140,.4),grass)
box('Forecourt front boundary',(0,mine_y-69,1),(140,2,2),soil)
box('Forecourt front boundary grass',(0,mine_y-69,2.2),(140,2.3,.4),grass)

# Move all four board footprints onto side galleries, leaving the front route clear.
manifest=json.loads((OUT/'layout-manifest.json').read_text())
for ob in list(structure.objects):
 if ob.name in ['Leaderboard gallery','Leaderboard gallery border']:archive_object(ob)
for side in [-1,1]:
 box('Leaderboard side gallery '+str(side),(side*82,-109,.12),(46,48,.14),stone)
positions=[(-82,-119),(-82,-99),(82,-119),(82,-99)]
for index,(x,y) in enumerate(positions):
 key=f'Leaderboard_{index+1:02d}'
 z=next(z for z in manifest['reserved_zones'] if z['id']==key)
 ox,oy,_=z['blender_center'];delta=Vector((x-ox,y-oy,0))
 for name in [key+'_Foundation',key+'_Inset',key+'_Guide',key+'_Placement']:
  bpy.data.objects[name].location+=delta
 z['blender_center']=[x,y,.32];z['roblox_center']=[x,.32,-y]
mine=next(z for z in manifest['reserved_zones'] if z['kind']=='Mine')
mine['blender_center']=[0,mine_y,0];mine['roblox_center']=[0,0,-mine_y]
manifest['mine'].update({'center':[0,mine_y,0],'roblox_center':[0,0,-mine_y],
 'location':'Front forecourt outside courtyard','courtyard_center':'Open and restored',
 'forecourt_size':[144,140]})
manifest['overall_layout_size']=[280,454]
for i,a in enumerate(manifest['reserved_zones']):
 for b in manifest['reserved_zones'][i+1:]:
  ax,ay,_=a['blender_center'];bx,by,_=b['blender_center']
  assert not(abs(ax-bx)<(a['footprint'][0]+b['footprint'][0])/2 and abs(ay-by)<(a['footprint'][1]+b['footprint'][1])/2),(a['id'],b['id'])
(OUT/'layout-manifest.json').write_text(json.dumps(manifest,indent=2))

# Refresh corner colours on the new geometry; no textured materials are exported.
for ob in structure.all_objects:
 if ob.type!='MESH':continue
 mesh=ob.data
 attr=mesh.color_attributes.get('Color') or mesh.color_attributes.new(name='Color',type='BYTE_COLOR',domain='CORNER')
 mesh.color_attributes.active_color=attr
 for face in mesh.polygons:
  color=mesh.materials[face.material_index].diffuse_color
  for loop in face.loop_indices:attr.data[loop].color=color
 assert not any(n.type=='TEX_IMAGE' for m in mesh.materials if m and m.use_nodes for n in m.node_tree.nodes),ob.name
cam=bpy.data.objects['01 Layout overview'];cam.location=(320,-520,570)
cam.rotation_euler=(Vector((0,-50,0))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.ortho_scale=560
cam=bpy.data.objects['02 Top-down plan'];cam.location=(0,-52,650);cam.data.ortho_scale=540
for ob in scene.objects:ob.select_set(False)
for ob in structure.all_objects:ob.select_set(True)
bpy.context.view_layer.objects.active=root
bpy.ops.export_scene.fbx(filepath=str(OUT/'EnergyCore-CourtyardLayout.fbx'),use_selection=True,
 object_types={'MESH','EMPTY'},axis_forward='-Z',axis_up='Y',global_scale=1,
 apply_unit_scale=True,apply_scale_options='FBX_SCALE_UNITS',colors_type='SRGB',bake_anim=False)
guides.hide_render=False;scene.camera=bpy.data.objects['01 Layout overview']
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'EnergyCore-CourtyardLayout.blend'))
for camera,filename in [('01 Layout overview','courtyard-overview.png'),('02 Top-down plan','courtyard-plan.png'),('03 Courtyard eye level','courtyard-eye-level.png')]:
 scene.camera=bpy.data.objects[camera];guides.hide_render=camera=='03 Courtyard eye level'
 scene.render.filepath=str(OUT/filename);bpy.ops.render.render(write_still=True)
guides.hide_render=False;scene.camera=bpy.data.objects['01 Layout overview']
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'EnergyCore-CourtyardLayout.blend'))
print('FRONT MINE FINISHED: center open, no studs, all 19 footprints non-overlapping')
