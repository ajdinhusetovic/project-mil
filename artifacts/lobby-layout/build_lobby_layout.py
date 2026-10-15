"""Structural lobby shell. Future gameplay objects are reserved footprints only."""
import bpy, math, json, numpy as np
from pathlib import Path
from mathutils import Vector
OUT=Path(r'C:\Users\huske\Desktop\project-mil\artifacts\lobby-layout')
OUT.mkdir(exist_ok=True,parents=True)
(OUT/'textures').mkdir(exist_ok=True)
scene=bpy.data.scenes.new('Energy Core - Courtyard Layout Only')
bpy.context.window.scene=scene
scene.unit_settings.system='NONE'
structure=bpy.data.collections.new('LAYOUT - Export This');scene.collection.children.link(structure)
guides=bpy.data.collections.new('PLANNING GUIDES - Do Not Export');scene.collection.children.link(guides)
presentation=bpy.data.collections.new('CAMERAS AND LIGHTS - Do Not Export');scene.collection.children.link(presentation)
root=bpy.data.objects.new('EnergyCore_CourtyardLayout',None);structure.objects.link(root)
zones=[]

def tile_material(name,rgb,studs=False):
 # Smooth colour only. No stud geometry or embossed texture is generated.
 def linear(c):
  c=c/255
  return c/12.92 if c<=.04045 else ((c+.055)/1.055)**2.4
 m=bpy.data.materials.new(name);m.use_nodes=True
 color=(*[linear(c) for c in rgb],1)
 m.diffuse_color=color
 bs=m.node_tree.nodes['Principled BSDF']
 bs.inputs['Base Color'].default_value=color
 bs.inputs['Roughness'].default_value=.82
 return m

grass=tile_material('Grass - fresh green',(47,186,62),True)
grass2=tile_material('Grass - checker green',(51,194,67),True)
soil=tile_material('Cliff - baked orange',(172,83,38),True)
soilLight=tile_material('Cliff - warm strata',(191,100,46),True)
soilDark=tile_material('Cliff - deep strata',(151,70,32),True)
stone=tile_material('Walkway - cool grey',(151,164,185),True)
stone2=tile_material('Walkway - checker grey',(144,157,179),True)
dark=tile_material('Trim - graphite',(48,66,86))
foundation=tile_material('Reserved plot - neutral slab',(104,127,145),True)
afkfloor=tile_material('Training court - ochre',(222,162,48),True)
afkplot=tile_material('AFK plot - cool inset',(129,149,164),True)
cream=tile_material('Edge - light limestone',(214,224,214))

def box(name,loc,size,mat,collection=structure):
 sx,sy,sz=[v/2 for v in size]
 verts=[(-sx,-sy,-sz),(sx,-sy,-sz),(sx,sy,-sz),(-sx,sy,-sz),(-sx,-sy,sz),(sx,-sy,sz),(sx,sy,sz),(-sx,sy,sz)]
 faces=[(0,3,2,1),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7),(4,5,6,7)]
 mesh=bpy.data.meshes.new(name);mesh.from_pydata(verts,[],faces);mesh.update()
 uv=mesh.uv_layers.new(name='UVMap')
 for poly in mesh.polygons:
  norm=poly.normal
  axes=(0,1) if abs(norm.z)>.5 else ((0,2) if abs(norm.y)>.5 else (1,2))
  for loop in poly.loop_indices:
   v=mesh.vertices[mesh.loops[loop].vertex_index].co+Vector(loc)
   uv.data[loop].uv=(v[axes[0]]/4,v[axes[1]]/4)
 ob=bpy.data.objects.new(name,mesh);collection.objects.link(ob);ob.location=loc;mesh.materials.append(mat)
 if collection==structure: ob.parent=root
 return ob

def label(name,body,loc,size=2):
 data=bpy.data.curves.new(name,'FONT');data.body=body;data.align_x='CENTER';data.align_y='CENTER';data.size=size
 ob=bpy.data.objects.new(name,data);guides.objects.link(ob);ob.location=loc
 data.materials.append(cream);return ob

def reserve(key,kind,x,y,w,d,body,base=foundation):
 # The only visible object here is a flat paving footprint, not a machine or shop.
 box(key+'_Foundation',(x,y,.12),(w,d,.24),dark)
 box(key+'_Inset',(x,y,.255),(w-.75,d-.75,.06),base)
 marker=bpy.data.objects.new(key+'_Placement',None);guides.objects.link(marker)
 marker.location=(x,y,.32);marker.empty_display_type='CUBE';marker.empty_display_size=1
 marker['ReservedSize']=[w,d];marker['FutureObject']=kind
 zones.append({'id':key,'kind':kind,'blender_center':[x,y,.32],'footprint':[w,d],
               'roblox_center':[x,.32,-y]})
 label(key+'_Guide',body,(x,y,.31),1.8 if kind=='AFK' else 2.1)

# Raised base, then alternating broad green plates as in the reference courtyard.
box('Courtyard foundation',(0,0,-3.32),(224,288,6),soilDark)
for row in range(24):
 for col in range(20):
  x=-106.4+col*11.2;y=-138+row*12
  box(f'GrassTile_{row:02d}_{col:02d}',(x,y,-.16),(11.2,12,.32),grass if (row+col)%2==0 else grass2)

# A generous central avenue and short perpendicular access branches.
box('Main walkway border',(0,-20,.01),(78,228,.12),dark)
for row in range(19):
 for col in range(6):
  box(f'WalkTile_{row:02d}_{col:02d}',(-30+col*12,-128+row*12,.09),(12,12,.12),stone if (row+col)%2==0 else stone2)
for y in [-78,-18]:
 for side in [-1,1]:
  box(f'Access_{side}_{y}_border',(side*68,y,.015),(64,20,.13),dark)
  box(f'Access_{side}_{y}',(side*68,y,.10),(64,18.8,.12),stone)

# Four side foundations; shops are intentionally absent.
reserve('Shop_WeaponBuying','Weapon buying',-72,-62,42,30,'WEAPON BUYING')
reserve('Shop_Upgrade','Weapon upgrades',72,-62,42,30,'UPGRADES')
reserve('Shop_Selling','Selling',72,-2,42,30,'SELLING')
reserve('CoreStabilizer','Core stabilizer',-72,-2,42,30,'CORE STABILIZER')

# Training plaza at the far end: two rows of five with walkable gaps.
box('AFK court border',(0,104,.025),(208,68,.15),dark)
box('AFK court paving',(0,104,.12),(206,66,.14),afkfloor)
for row,y in enumerate([87,119]):
 for col,x in enumerate([-80,-40,0,40,80]):
  index=row*5+col+1
  reserve(f'AFK_{index:02d}','AFK',x,y,28,20,f'AFK  {index:02d}',afkplot)
label('AFK court heading','10 AFK STATIONS  /  RESERVED',(0,71.5,.32),2.3)

# Opposite wall: four empty leaderboard plots. Walkway stays unobstructed.
box('Leaderboard gallery border',(0,-126,.025),(204,25,.15),dark)
box('Leaderboard gallery',(0,-126,.12),(202,23,.14),stone)
for i,x in enumerate([-75,-25,25,75]):
 reserve(f'Leaderboard_{i+1:02d}','Leaderboard',x,-130,38,12,f'LEADERBOARD {i+1}')
label('Spawn guide','ARRIVAL / OPEN PLAZA',(0,-99,.25),2)

# Orange enclosing cliffs with chunky stepped outlines and bright grass shelves.
# Tallest layer is outermost; all walkable space remains inside x +/-112, y +/-144.
for side in [-1,1]:
 for start,end,h in [(-144,-96,37),(-96,-48,32),(-48,12,39),(12,64,34),(64,144,42)]:
  length=end-start;mid=(start+end)/2
  box(f'Cliff_{side}_{start}_lower',(side*118,mid,9),(12,length,18),soil)
  box(f'Cliff_{side}_{start}_middle',(side*124,mid,21),(24,length,6),soilLight)
  box(f'Cliff_{side}_{start}_grassShelf',(side*122,mid,24.35),(28,length,1.1),grass)
  box(f'Cliff_{side}_{start}_upper',(side*132,mid,(h+25)/2),(16,length,h-25),soil)
  box(f'Cliff_{side}_{start}_crown',(side*132,mid,h+.6),(20,length,1.2),grass2)
for side in [-1,1]:
 for col,(x,w,h) in enumerate([(-90,44,42),(-45,46,36),(0,44,40),(45,46,36),(90,44,42)]):
  y=side*150
  box(f'EndCliff_{side}_{col}_lower',(x,y,10),(w,12,20),soil)
  box(f'EndCliff_{side}_{col}_stratum',(x,side*155,23),(w,22,6),soilLight)
  box(f'EndCliff_{side}_{col}_shelf',(x,side*154,26.5),(w,24,1),grass)
  box(f'EndCliff_{side}_{col}_upper',(x,side*163,(h+27)/2),(w,12,h-27),soilDark if col%2 else soil)
  box(f'EndCliff_{side}_{col}_crown',(x,side*163,h+.6),(w,16,1.2),grass2)

# Corner columns make the cliff joins intentional, without adding any props.
for x in [-114,114]:
 for y in [-146,146]:
  box(f'Corner buttress {x} {y}',(x,y,17),(10,10,34),soilLight)
  box(f'Corner grass cap {x} {y}',(x,y,34.6),(12,12,1.2),grass)

# Bake the textured scene into exports. The importer must retain textures.
for ob in scene.objects: ob.select_set(False)
for ob in structure.all_objects: ob.select_set(True)
bpy.context.view_layer.objects.active=root
bpy.ops.export_scene.fbx(filepath=str(OUT/'EnergyCore-CourtyardLayout.fbx'),use_selection=True,
 object_types={'MESH','EMPTY'},axis_forward='-Z',axis_up='Y',global_scale=1,
 apply_unit_scale=True,apply_scale_options='FBX_SCALE_UNITS',path_mode='COPY',embed_textures=True,bake_anim=False)

def camera(name,location,target,ortho):
 data=bpy.data.cameras.new(name);ob=bpy.data.objects.new(name,data);presentation.objects.link(ob)
 ob.location=location;ob.rotation_euler=(Vector(target)-ob.location).to_track_quat('-Z','Y').to_euler()
 data.type='ORTHO';data.ortho_scale=ortho;data.clip_end=2000
 return ob
overview=camera('01 Layout overview',(270,-370,440),(0,5,0),440)
top=camera('02 Top-down plan',(0,0,600),(0,0,0),400)
walk=camera('03 Courtyard eye level',(0,-105,13),(0,115,15),110)
walk.data.type='PERSP';walk.data.lens=22
scene.camera=overview
world=bpy.data.worlds.new('Courtyard sky');world.use_nodes=True
world.node_tree.nodes['Background'].inputs[0].default_value=(.42,.62,.88,1)
world.node_tree.nodes['Background'].inputs[1].default_value=.6;scene.world=world
sun=bpy.data.lights.new('Warm afternoon sun','SUN');sun.energy=2;sun.angle=math.radians(18)
ob=bpy.data.objects.new('Warm afternoon sun',sun);presentation.objects.link(ob)
ob.rotation_euler=(math.radians(23),math.radians(-25),math.radians(-30))
fill=bpy.data.lights.new('Broad sky fill','AREA');fill.energy=140000;fill.shape='DISK';fill.size=220
ob=bpy.data.objects.new('Broad sky fill',fill);presentation.objects.link(ob);ob.location=(0,-20,190)
scene.render.engine='CYCLES';scene.cycles.samples=32;scene.cycles.use_denoising=True
scene.render.resolution_x=1800;scene.render.resolution_y=1600;scene.render.resolution_percentage=100
scene.view_settings.view_transform='Standard'
scene.render.image_settings.file_format='PNG'
assert(len([z for z in zones if z['kind']=='AFK'])==10)
assert(len([z for z in zones if z['kind']=='Leaderboard'])==4)
for i,a in enumerate(zones):
 for b in zones[i+1:]:
  ax,ay,_=a['blender_center'];bx,by,_=b['blender_center']
  overlap=abs(ax-bx)<(a['footprint'][0]+b['footprint'][0])/2 and abs(ay-by)<(a['footprint'][1]+b['footprint'][1])/2
  assert not overlap,(a['id'],b['id'])
(OUT/'layout-manifest.json').write_text(json.dumps({'interior_size':[224,288],
 'units':'1 Blender unit = 1 Roblox stud','reserved_zones':zones,
 'export_contains':'Structural floor, paving, curbs and terraced walls only',
 'excluded':'No machines, shop buildings, stabilizer, leaderboard objects, UI or gameplay scripts'},indent=2))
for ob in scene.objects:ob.select_set(False)
for screen in bpy.data.screens:
 for area in screen.areas:
  if area.type=='VIEW_3D':
   area.spaces.active.region_3d.view_perspective='CAMERA'
   area.spaces.active.shading.type='MATERIAL'
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'EnergyCore-CourtyardLayout.blend'))
scene.render.filepath=str(OUT/'courtyard-overview.png');bpy.ops.render.render(write_still=True)
scene.camera=top;scene.render.filepath=str(OUT/'courtyard-plan.png');bpy.ops.render.render(write_still=True)
guides.hide_render=True;scene.camera=walk
scene.render.filepath=str(OUT/'courtyard-eye-level.png');bpy.ops.render.render(write_still=True)
guides.hide_render=False;scene.camera=overview
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'EnergyCore-CourtyardLayout.blend'))
print('LAYOUT COMPLETE: 10 AFK / 3 shops / 1 stabilizer / 4 leaderboards; 18 non-overlapping footprints')
