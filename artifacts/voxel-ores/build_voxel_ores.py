import bpy, random, math, json
from pathlib import Path
from mathutils import Vector
OUT=Path('/Users/ajdinhusetovic/Desktop/ProjectMilka/artifacts/voxel-ores')
OUT.mkdir(parents=True,exist_ok=True)
# Work in a new scene; leave every object in the previous scene intact.
scene=bpy.data.scenes.new('Energy Core - Original Voxel Ores')
bpy.context.window.scene=scene
scene.unit_settings.scale_length=1
assets=bpy.data.collections.new('Export - 11 Ore Blocks');scene.collection.children.link(assets)
presentation=bpy.data.collections.new('Presentation - Do Not Export');scene.collection.children.link(presentation)
DEFS=[
 ('Stone','Stone Ore',(104,121,137),None,'stone'),
 ('Copper','Copper Ore',(81,92,108),(238,128,60),'clusters'),
 ('Quartz','Quartz Ore',(96,110,136),(226,215,255),'clusters'),
 ('ChargedQuartz','Charged Quartz',(39,70,96),(57,224,245),'veins'),
 ('Ion','Ion Crystal',(60,49,93),(180,104,255),'clusters'),
 ('Plasma','Plasma Ore',(69,45,44),(255,126,37),'veins'),
 ('ReactorShard','Reactor Shard',(39,62,55),(134,245,71),'clusters'),
 ('Fusion','Fusion Ore',(80,62,43),(255,204,63),'veins'),
 ('Antimatter','Antimatter Ore',(57,37,70),(255,90,193),'clusters'),
 ('Singularity','Singularity Ore',(36,34,64),(121,122,255),'spiral'),
 ('Omega','Omega Ore',(55,31,41),(255,70,96),'clusters'),
]
def linear(rgb):
 return tuple(c/12.92 if c<=.04045 else ((c+.055)/1.055)**2.4 for c in [v/255 for v in rgb])
def mat(name,rgb):
 m=bpy.data.materials.new(name);m.diffuse_color=(*linear(rgb),1);m.use_nodes=True
 bsdf=next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
 bsdf.inputs['Base Color'].default_value=m.diffuse_color
 bsdf.inputs['Roughness'].default_value=.86
 return m
assets_list=[]
manifest={'units':'1 Blender unit = 1 Roblox stud','body_size':[6,6,6],'models':[]}
for index,(key,label,base,ore,kind) in enumerate(DEFS):
 root=bpy.data.objects.new(key,None);assets.objects.link(root)
 root.location=((index%4-1.5)*9,(index//4)*10,3)
 root['RobloxModelName']=key;root['MaterialName']=label;root['RockBodySize']='6,6,6'
 palette=[]
 for factor in [.84,.94,1.02,1.10]:palette.append(tuple(min(255,round(v*factor)) for v in base))
 if ore:
  palette += [tuple(round(v*.68) for v in ore),ore,tuple(round(v*.55+255*.45) for v in ore)]
 materials=[mat(key+'__Pixel'+str(i),rgb) for i,rgb in enumerate(palette)]
 verts,faces,slots=[],[],[]
 axes=[((1,0,0),(0,1,0),(0,0,1)),((-1,0,0),(0,-1,0),(0,0,1)),
       ((0,1,0),(-1,0,0),(0,0,1)),((0,-1,0),(1,0,0),(0,0,1)),
       ((0,0,1),(1,0,0),(0,1,0)),((0,0,-1),(-1,0,0),(0,1,0))]
 for face_index,(normal,u,v) in enumerate(axes):
  rng=random.Random(74001+index*127+face_index*719)
  ore_pixels=set()
  if ore:
   if kind=='veins':
    y=rng.randint(2,5)
    for x in range(1,7):
     y=max(1,min(6,y+rng.choice([-1,0,1])))
     ore_pixels.add((x,y));ore_pixels.add((x,max(0,y-1)))
     if x%2==0:ore_pixels.add((x,min(7,y+1)))
    for _ in range(5):ore_pixels.add((rng.randint(1,6),rng.randint(1,6)))
   elif kind=='spiral':
    ore_pixels.update([(1,2),(1,3),(1,4),(2,5),(3,5),(4,5),(5,4),(5,3),(4,2),(3,2),(2,3),(3,4),(4,4)])
    for _ in range(5):ore_pixels.add((rng.randint(1,6),rng.randint(1,6)))
   else:
    centres=rng.sample([(2,2),(5,2),(2,5),(5,5)],3)
    shapes=[[(0,0),(1,0),(0,1)],[(0,0),(1,0),(1,1),(-1,0)],[(0,0),(0,1),(1,1),(1,2)]]
    for cx,cy in centres:
     shape=rng.choice(shapes)
     for dx,dy in shape:ore_pixels.add((cx+dx,cy+dy))
     if index>=6:ore_pixels.add((cx-1,cy+1))
  n,t,b=Vector(normal),Vector(u),Vector(v)
  patches=[(rng.randrange(8),rng.randrange(8),rng.randrange(4)) for _ in range(8)]
  for y in range(8):
   for x in range(8):
    if (x,y) in ore_pixels:
     border=any((x+dx,y+dy) not in ore_pixels for dx,dy in [(1,0),(-1,0),(0,1),(0,-1)])
     slot=4 if border and rng.random()<.2 else (6 if rng.random()<.26 else 5)
    else:
     slot=min(patches,key=lambda p:(p[0]-x)**2+(p[1]-y)**2)[2]
     if rng.random()<.08:slot=rng.randrange(4)
    start=len(verts)
    for a,c in [(x,y),(x+1,y),(x+1,y+1),(x,y+1)]:
     verts.append(tuple(n*3+t*(-3+a*.75)+b*(-3+c*.75)))
    faces.append((start,start+1,start+2,start+3));slots.append(slot)
 mesh=bpy.data.meshes.new(key+'__VoxelSurface');mesh.from_pydata(verts,[],faces);mesh.update()
 body=bpy.data.objects.new(key+'__Body',mesh);assets.objects.link(body);body.parent=root
 for m in materials:mesh.materials.append(m)
 for poly,slot in zip(mesh.polygons,slots):poly.material_index=slot;poly.use_smooth=False
 attr=mesh.color_attributes.new(name='Color',type='BYTE_COLOR',domain='CORNER');mesh.color_attributes.active_color=attr
 for poly in mesh.polygons:
  color=materials[poly.material_index].diffuse_color
  for loop in poly.loop_indices:attr.data[loop].color=color
 mesh.calc_loop_triangles()
 assert all(abs(v-6)<1e-5 for v in body.dimensions), (key,tuple(body.dimensions))
 assert len(mesh.loop_triangles)==768
 assets_list.append((root,body))
 manifest['models'].append({'key':key,'material':label,'triangles':768,'palette_rgb':palette,'fbx':key+'.fbx'})
# Presentation assets stay outside the export collection.
def label(body,loc):
 cu=bpy.data.curves.new('Label','FONT');cu.body=body;cu.align_x='CENTER';cu.size=.65
 ob=bpy.data.objects.new(body,cu);presentation.objects.link(ob);ob.location=loc;ob.rotation_euler=(math.pi/2,0,0)
 cu.materials.append(mat('PresentationText',(230,239,250)))
for root,body in assets_list:label(root['MaterialName'],root.location+Vector((0,-3.5,-2.5)))
world=bpy.data.worlds.new('Ore Studio World');world.use_nodes=True;scene.world=world
bg=next(n for n in world.node_tree.nodes if n.type=='BACKGROUND');bg.inputs['Color'].default_value=(.035,.045,.065,1);bg.inputs['Strength'].default_value=.7
light_types=[e.identifier for e in bpy.types.Light.bl_rna.properties['type'].enum_items]
for name,loc,energy,size in [('Key',(-18,-22,32),4200,22),('Fill',(22,-4,18),2400,18),('Rim',(2,32,24),3500,18)]:
 data=bpy.data.lights.new(name,type=next(t for t in light_types if t=='AREA'));data.energy=energy;data.shape='DISK';data.size=size
 ob=bpy.data.objects.new(name,data);presentation.objects.link(ob);ob.location=loc;ob.rotation_euler=(Vector((0,10,3))-ob.location).to_track_quat('-Z','Y').to_euler()
camdata=bpy.data.cameras.new('Ore Overview');cam=bpy.data.objects.new('Ore Overview',camdata);presentation.objects.link(cam)
cam.location=(35,-48,44);cam.rotation_euler=(Vector((0,10,2.8))-cam.location).to_track_quat('-Z','Y').to_euler();camdata.type='ORTHO';camdata.ortho_scale=46;scene.camera=cam
scene.render.resolution_x=1600;scene.render.resolution_y=1200;scene.render.resolution_percentage=100
scene.render.image_settings.file_format=next(e.identifier for e in scene.render.image_settings.bl_rna.properties['file_format'].enum_items if e.identifier=='PNG')
scene.render.filepath=str(OUT/'voxel-ores-preview.png')
# Export each body at origin; do not include the presentation layout or labels.
for root,body in assets_list:
 for ob in bpy.context.selected_objects:ob.select_set(False)
 original=root.location.copy();root.location=(0,0,0)
 root.select_set(True);body.select_set(True);bpy.context.view_layer.objects.active=body
 bpy.context.view_layer.update()
 try:
  bpy.ops.export_scene.fbx(filepath=str(OUT/(root.name+'.fbx')),use_selection=True,object_types={'MESH','EMPTY'},global_scale=1,apply_unit_scale=True,apply_scale_options='FBX_SCALE_UNITS',axis_forward='-Z',axis_up='Y',colors_type='SRGB',bake_anim=False,use_mesh_modifiers=True)
 finally:root.location=original
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2))
for ob in bpy.context.selected_objects:ob.select_set(False)
for root,body in assets_list:body.select_set(True)
bpy.context.view_layer.objects.active=assets_list[0][1]
bpy.context.view_layer.update()
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'EnergyCore-OriginalVoxelOres.blend'))
print('CREATED: 11 original voxel ore blocks. All rock bodies exactly 6x6x6, 768 triangles each. Separate FBX files saved.')
