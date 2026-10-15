"""Spawn-centred layout: AFK left, four leaderboards right, shops around spawn, mine ahead."""
import bpy, math, json, bmesh
from pathlib import Path
from mathutils import Vector
OUT=Path(r'C:\Users\huske\Desktop\project-mil\artifacts\lobby-crossroads')
OUT.mkdir(parents=True,exist_ok=True)
s=bpy.data.scenes.new('Energy Core - Spawn Crossroads V3')
bpy.context.window.scene=s;s.unit_settings.system='NONE'
layout=bpy.data.collections.new('CROSSROADS LAYOUT - EXPORT');s.collection.children.link(layout)
guides=bpy.data.collections.new('V3 PLANNING GUIDES - NOT EXPORTED');s.collection.children.link(guides)
presentation=bpy.data.collections.new('V3 CAMERAS AND LIGHTS - NOT EXPORTED');s.collection.children.link(presentation)
underground=bpy.data.collections.new('V3 FULL DEPTH SHAFT - EXPORT');layout.children.link(underground)
root=bpy.data.objects.new('EnergyCore_SpawnCrossroads',None);layout.objects.link(root)

def material(name,rgb):
 def linear(c):
  c=c/255
  return c/12.92 if c<=.04045 else ((c+.055)/1.055)**2.4
 m=bpy.data.materials.new('V3 '+name);m.use_nodes=True;m.diffuse_color=(*map(linear,rgb),1)
 bs=m.node_tree.nodes['Principled BSDF'];bs.inputs['Base Color'].default_value=m.diffuse_color
 bs.inputs['Roughness'].default_value=.84
 return m
grass=material('Fresh grass',(43,189,57));grass2=material('Checker grass',(47,197,62))
soil=material('Orange cliff',(191,92,35));stratum=material('Warm cliff stratum',(208,111,47))
soilDark=material('Deep earth',(151,67,29));grey=material('Slate platform',(123,143,166))
grey2=material('Slate top',(153,169,188));dark=material('Graphite trim',(48,64,84))
paving=material('Warm path',(210,207,163));paving2=material('Warm path checker',(203,200,156))
yellow=material('Training court',(219,169,56));white=material('Guide ivory',(245,245,224))
spawnmat=material('Spawn limestone',(224,219,178));cyan=material('Guide arrow',(151,226,226))
zones=[]

def mesh_object(name,verts,faces,mat,collection=layout):
 mesh=bpy.data.meshes.new(name);mesh.from_pydata(verts,[],faces);mesh.update()
 mesh.materials.append(mat)
 attr=mesh.color_attributes.new(name='Color',type='BYTE_COLOR',domain='CORNER');mesh.color_attributes.active_color=attr
 for face in mesh.polygons:
  for loop in face.loop_indices:attr.data[loop].color=mat.diffuse_color
 ob=bpy.data.objects.new(name,mesh);collection.objects.link(ob)
 if collection==layout or collection==underground:ob.parent=root
 return ob

def box(name,loc,size,mat,collection=layout):
 x,y,z=[v/2 for v in size]
 verts=[(-x,-y,-z),(x,-y,-z),(x,y,-z),(-x,y,-z),(-x,-y,z),(x,-y,z),(x,y,z),(-x,y,z)]
 ob=mesh_object(name,verts,[(0,3,2,1),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7),(4,5,6,7)],mat,collection)
 ob.location=loc;return ob

def disc(name,radius,z,depth,mat):
 n=64;v=[(math.cos(i*math.tau/n)*radius,math.sin(i*math.tau/n)*radius,z+level) for level in [-depth/2,depth/2] for i in range(n)]
 f=[tuple(reversed(range(n))),tuple(range(n,2*n))]
 f.extend((i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n))
 return mesh_object(name,v,f,mat)

def label(name,text,x,y,z,size=2,rotation=0):
 data=bpy.data.curves.new(name,'FONT');data.body=text;data.align_x='CENTER';data.align_y='CENTER';data.size=size
 ob=bpy.data.objects.new(name,data);guides.objects.link(ob);ob.location=(x,y,z);ob.rotation_euler.z=rotation
 data.materials.append(white);return ob

def reserve(key,kind,x,y,w,d,height,label_text,facing):
 box(key+'_Foundation',(x,y,height+.10),(w,d,.20),dark)
 box(key+'_Inset',(x,y,height+.22),(w-.65,d-.65,.045),grey2)
 rotation=math.pi/2 if facing=='+X' else (-math.pi/2 if facing=='-X' else (math.pi if facing=='+Y' else 0))
 label(key+'_Guide',label_text,x,y,height+.26,1.6,rotation)
 marker=bpy.data.objects.new(key+'_Placement',None);guides.objects.link(marker);marker.location=(x,y,height+.25)
 marker['Facing']=facing;marker['ReservedSize']=[w,d]
 zones.append({'id':key,'kind':kind,'center':[x,y,height+.25],'footprint':[w,d],'facing':facing})
 # Planning-only arrow explicitly shows every AFK and board facing the spawn.
 if facing in ['+X','-X']:
  sign=1 if facing=='+X' else -1
  ax=x+sign*(w/2+2.3);az=height+.27
  ob=mesh_object(key+'_FacingArrow',[(ax+sign*2,y,az),(ax-sign*1.5,y+1.3,az),(ax-sign*1.5,y-1.3,az)],[(0,1,2)],cyan,guides)

# Broad compact courtyard, instead of a long corridor. All surfaces stay smooth.
box('V3 Courtyard foundation',(0,0,-3.32),(360,260,6),soilDark)
for row in range(20):
 for col in range(30):
  box(f'V3 Grass {row:02d}-{col:02d}',(-174+col*12,-123.5+row*13,-.16),(12,13,.32),grass if (row+col)%2 else grass2)

# Four radial routes meet at a round spawn plaza, following the reference's flow.
box('V3 Front route border',(0,-83,.045),(32,166,.12),dark)
box('V3 Back route border',(0,70,.045),(32,120,.12),dark)
box('V3 Cross route border',(0,0,.045),(180,24,.12),dark)
for row in range(24):
 y=-160+row*12
 for col,x in enumerate([-7,7]):
  box(f'V3 Main path {row}-{col}',(x,y,.13),(14,12,.12),paving if (row+col)%2 else paving2)
box('V3 Left access',(-54,0,.13),(68,20,.12),paving)
box('V3 Right access',(54,0,.13),(68,20,.12),paving)
disc('V3 Spawn plaza border',25.5,.20,.30,dark)
disc('V3 Spawn plaza limestone',24,.40,.20,spawnmat)
label('V3 Spawn guide','SPAWN',0,0,.52,3)
spawn=bpy.data.objects.new('V3_Spawn_Anchor',None);guides.objects.link(spawn);spawn.location=(0,0,.55)

# Three shops and one stabilizer surround spawn. These are paving pads only.
reserve('WeaponBuying','Weapon buying',-49,-50,30,24,0,'WEAPONS','+Y')
reserve('UpgradeShop','Weapon upgrades',-49,50,30,24,0,'UPGRADES','-Y')
reserve('SellingShop','Selling',49,-50,30,24,0,'SELL','+Y')
reserve('CoreStabilizer','Core stabilizer',49,50,30,24,0,'STABILIZER','-Y')
for x in [-49,49]:
 for y in [-28,28]:box(f'V3 Shop spur {x} {y}',(x,y,.12),(16,36,.12),paving)

# LEFT: two stepped rows of five. Every station faces +X, inward toward spawn.
box('V3 AFK terrace base',(-120,0,.30),(80,180,.60),dark)
box('V3 AFK front tier',(-102,0,.80),(28,176,.80),yellow)
box('V3 AFK back tier',(-134,0,1.90),(28,176,2.60),yellow)
for i,(x,top,w) in enumerate([(-82,.4,4),(-86,.8,4),(-117,1.85,2),(-119,2.5,2)]):
 box(f'V3 AFK access step {i}',(x,0,top/2),(w,176,top),grey)
for row,(x,height) in enumerate([(-102,1.2),(-134,3.2)]):
 for col,y in enumerate([-64,-32,0,32,64]):
  i=row*5+col+1
  reserve(f'AFK_{i:02d}','AFK',x,y,20,26,height,f'AFK {i:02d}','+X')
label('V3 AFK bank guide','10 AFK STATIONS',-120,94,.3,3)

# RIGHT: one single row of four side-by-side boards, ALL facing -X to spawn.
box('V3 Leaderboard terrace base',(122,0,.3),(68,180,.6),dark)
box('V3 Leaderboard terrace',(122,0,.8),(64,176,.8),grey)
for i,(x,top) in enumerate([(82,.4),(86,.8)]):
 box(f'V3 Board access step {i}',(x,0,top/2),(4,176,top),grey2)
for i,y in enumerate([-60,-20,20,60]):
 reserve(f'Leaderboard_{i+1:02d}','Leaderboard',122,y,16,32,1.2,f'BOARD {i+1}','-X')
label('V3 Board bank guide','4 LEADERBOARDS',122,94,.3,3)

# Front mine forecourt and its real 72x72 opening, with a broad walking ring.
mine_y=-214
for name,z,h,mat in [('V3 Forecourt ground',-.16,.32,grass),('V3 Forecourt soil',-3.32,6,soilDark)]:
 box(name+' west',(-58,-208,z),(44,156,h),mat)
 box(name+' east',(58,-208,z),(44,156,h),mat)
 box(name+' front',(0,-268,z),(72,36,h),mat)
 box(name+' rear',(0,-154,z),(72,48,h),mat)
for x in [-45,45]:box('V3 Mine side apron '+str(x),(x,mine_y,.13),(18,108,.12),grey2)
for y in [-259,-169]:box('V3 Mine end apron '+str(y),(0,y,.13),(72,18,.12),grey2)
box('V3 Mine connector',(0,-145,.135),(28,42,.12),paving)
for x in [-37,37]:box('V3 Mine lip side '+str(x),(x,mine_y,.25),(2,76,.12),dark)
for y in [-251,-177]:box('V3 Mine lip end '+str(y),(0,y,.25),(72,2,.12),dark)
for x in [-37,37]:box('V3 Mine shaft side '+str(x),(x,mine_y,-360),(2,76,720),soilDark,underground)
for y in [-251,-177]:box('V3 Mine shaft end '+str(y),(0,y,-360),(72,2,720),soilDark,underground)
box('V3 Mine bedrock',(0,mine_y,-721),(76,76,2),dark,underground)
zones.append({'id':'Mine','kind':'Mine','center':[0,mine_y,0],'footprint':[72,72],'depth':720,'facing':'+Y'})
label('V3 Mine guide','MINE  /  72 x 72',0,mine_y,.35,3)
# Preview cap makes the top-down plan readable without showing a 720-stud column.
box('V3 Mine preview floor - NOT EXPORTED',(0,mine_y,-22),(72,72,.1),dark,guides)

cliff_serial=0
def cliff(name,x,y,length,axis,height):
 global cliff_serial
 cliff_serial+=1
 # Avoid coplanar faces where the terraced wall sections intersect.
 x+=cliff_serial*.002;y+=cliff_serial*.003;height+=cliff_serial*.004
 # Offsets always extend outwards from the playable floor boundary.
 if axis=='X':
  side=1 if x>0 else -1
  box(name+' lower',(x,y,9),(12,length,18),soil)
  box(name+' warm stratum',(x+side*6,y,21),(24,length,6),stratum)
  box(name+' green shelf',(x+side*4,y,24.4),(28,length,1.2),grass)
  box(name+' upper',(x+side*14,y,(height+25)/2),(16,length,height-25),soil)
  box(name+' grass crown',(x+side*14,y,height+.6),(20,length,1.2),grass2)
 else:
  side=1 if y>0 else -1
  box(name+' lower',(x,y,9),(length,12,18),soil)
  box(name+' warm stratum',(x,y+side*6,21),(length,24,6),stratum)
  box(name+' green shelf',(x,y+side*4,24.4),(length,28,1.2),grass)
  box(name+' upper',(x,y+side*14,(height+25)/2),(length,16,height-25),soil)
  box(name+' grass crown',(x,y+side*14,height+.6),(length,20,1.2),grass2)
 for ob in layout.objects:
  if ob.name.startswith(name+' '):ob.location.z+=cliff_serial*.004

# Smooth terraced orange perimeter wraps both lobby and mine; entrance stays open.
for side in [-1,1]:
 for i,y in enumerate([-104,-52,0,52,104]):cliff(f'V3 Courtyard side {side} {i}',side*186,y,52,'X',36+[2,0,4,0,2][i])
for i,x in enumerate([-144,-72,0,72,144]):cliff(f'V3 Rear wall {i}',x,136,72,'Y',38 if i%2==0 else 34)
for side in [-1,1]:
 cliff(f'V3 Front shoulder {side}',side*122,-136,116,'Y',38)
 for i,y in enumerate([-260,-208,-156]):cliff(f'V3 Mine outer side {side} {i}',side*86,y,52,'X',36 if i%2 else 38)
for i,x in enumerate([-56,0,56]):cliff(f'V3 Mine front {i}',x,-292,56,'Y',36 if i==1 else 38)

assert len(zones)==19
for i,a in enumerate(zones):
 for b in zones[i+1:]:
  ax,ay,_=a['center'];bx,by,_=b['center']
  assert not(abs(ax-bx)<(a['footprint'][0]+b['footprint'][0])/2 and abs(ay-by)<(a['footprint'][1]+b['footprint'][1])/2),(a['id'],b['id'])
assert all(z['center'][0]<0 and z['facing']=='+X' for z in zones if z['kind']=='AFK')
assert all(z['center'][0]==122 and z['facing']=='-X' for z in zones if z['kind']=='Leaderboard')
# Front is +Y: AFK is on the player's left while facing the mine.
for ob in list(layout.all_objects)+list(guides.objects):
 ob.location.y=-ob.location.y
 if ob.type=='MESH':
  bm=bmesh.new();bm.from_mesh(ob.data)
  for v in bm.verts:v.co.y=-v.co.y
  bmesh.ops.reverse_faces(bm,faces=list(bm.faces))
  bm.to_mesh(ob.data);bm.free();ob.data.update()
 if 'Facing' in ob and ob['Facing'] in ['+Y','-Y']:
  ob['Facing']='-Y' if ob['Facing']=='+Y' else '+Y'
for zone in zones:
 zone['center'][1]*=-1
 if zone['facing'] in ['+Y','-Y']:zone['facing']='-Y' if zone['facing']=='+Y' else '+Y'
(OUT/'layout-manifest.json').write_text(json.dumps({'layout':'Spawn-centred crossroads V3','units':'1 unit = 1 stud',
 'front_direction':'+Y in Blender; -Z in Roblox','spawn':[0,0,.55],'courtyard_size':[360,260],
 'mine_center':[0,214,0],'reserved_zones':zones,'surface_style':'Smooth flat colour; no studs',
 'objects_included':'Foundations and environmental structure only; no shops, machines, boards or stabilizer props'},indent=2))

# Export geometry only, with colours baked per mesh corner. Keep all old scenes.
for ob in s.objects:ob.select_set(False)
for ob in layout.all_objects:ob.select_set(True)
bpy.context.view_layer.objects.active=root
bpy.ops.export_scene.fbx(filepath=str(OUT/'EnergyCore-SpawnCrossroads.fbx'),use_selection=True,
 object_types={'MESH','EMPTY'},axis_forward='-Z',axis_up='Y',global_scale=1,
 apply_unit_scale=True,apply_scale_options='FBX_SCALE_UNITS',colors_type='SRGB',bake_anim=False)

def camera(name,loc,target,scale):
 data=bpy.data.cameras.new(name);ob=bpy.data.objects.new(name,data);presentation.objects.link(ob)
 ob.location=loc;ob.rotation_euler=(Vector(target)-ob.location).to_track_quat('-Z','Y').to_euler()
 data.type='ORTHO';data.ortho_scale=scale;data.clip_end=2000;return ob
overview=camera('V3 Overview',(380,-540,640),(0,65,0),620)
plan=camera('V3 Plan',(0,72,700),(0,72,0),550)
eye=camera('V3 Spawn facing mine',(0,-45,58),(0,120,0),100)
eye.data.type='PERSP';eye.data.lens=22
world=bpy.data.worlds.new('V3 Sky');world.use_nodes=True
world.node_tree.nodes['Background'].inputs[0].default_value=(.42,.62,.88,1)
world.node_tree.nodes['Background'].inputs[1].default_value=.6;s.world=world
data=bpy.data.lights.new('V3 Sun','SUN');data.energy=2;data.angle=math.radians(18)
ob=bpy.data.objects.new('V3 Sun',data);presentation.objects.link(ob);ob.rotation_euler=(.45,-.40,-.55)
data=bpy.data.lights.new('V3 Skylight','AREA');data.energy=170000;data.shape='DISK';data.size=280
ob=bpy.data.objects.new('V3 Skylight',data);presentation.objects.link(ob);ob.location=(0,-40,220)
s.render.engine='CYCLES';s.cycles.samples=32;s.cycles.use_denoising=True
s.render.resolution_x=1800;s.render.resolution_y=1600;s.render.resolution_percentage=100
s.render.image_settings.file_format='PNG';s.view_settings.view_transform='Standard'
underground.hide_render=True;s.camera=overview
for ob in s.objects:ob.select_set(False)
for screen in bpy.data.screens:
 for area in screen.areas:
  if area.type=='VIEW_3D':area.spaces.active.region_3d.view_perspective='CAMERA';area.spaces.active.shading.type='MATERIAL'
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'EnergyCore-SpawnCrossroads.blend'))
for cam,filename in [(overview,'crossroads-overview.png'),(plan,'crossroads-plan.png'),(eye,'crossroads-spawn-view.png')]:
 s.camera=cam;s.render.filepath=str(OUT/filename);bpy.ops.render.render(write_still=True)
s.camera=plan
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'EnergyCore-SpawnCrossroads.blend'))
print('CROSSROADS V3 COMPLETE: AFK LEFT FACING INWARD; FOUR BOARDS IN ONE ROW RIGHT FACING INWARD; SHOPS AROUND SPAWN; MINE IN FRONT')
