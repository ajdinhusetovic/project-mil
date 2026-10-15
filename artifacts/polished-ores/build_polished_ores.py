"""Run in Blender via its local MCP execute_code endpoint. No existing scene is removed."""
import bpy, numpy as np, math, random, json
from pathlib import Path
from mathutils import Vector

OUT = Path(r'C:\Users\huske\Desktop\project-mil\artifacts\polished-ores')
OUT.mkdir(parents=True, exist_ok=True)
TEX = OUT / 'textures'
TEX.mkdir(exist_ok=True)
DEFS = [
 ('Stone','Stone Ore',(91,112,140),None),
 ('Copper','Copper Ore',(66,88,119),(255,144,55)),
 ('ChargedQuartz','Charged Quartz',(43,76,106),(45,224,255)),
 ('Quartz','Quartz Ore',(91,104,143),(235,216,255)),
 ('Ion','Ion Crystal',(66,61,112),(189,93,255)),
 ('Plasma','Plasma Ore',(81,66,81),(255,115,31)),
 ('ReactorShard','Reactor Shard',(49,87,89),(145,255,63)),
 ('Fusion','Fusion Ore',(86,83,104),(255,209,39)),
 ('Antimatter','Antimatter Ore',(72,51,96),(255,78,188)),
 ('Singularity','Singularity Ore',(43,47,83),(112,137,255)),
 ('Omega','Omega Ore',(77,45,67),(255,67,100)),
]
N = 1024
Y, X = np.mgrid[0:N,0:N].astype(np.float32)
X /= N; Y /= N

def noise(rng, cells):
 grid = rng.random((cells+1,cells+1))
 t = np.arange(N)/N*cells
 low = t.astype(int); f = t-low; f=f*f*(3-2*f)
 a=grid[low[:,None],low[None,:]]
 b=grid[low[:,None],low[None,:]+1]
 c=grid[low[:,None]+1,low[None,:]]
 d=grid[low[:,None]+1,low[None,:]+1]
 return ((a*(1-f[None,:])+b*f[None,:])*(1-f[:,None])+
         (c*(1-f[None,:])+d*f[None,:])*f[:,None])-.5

def triangle(img, a,b,c,color):
 pts=np.array([a,b,c])*N
 lo=np.maximum(np.floor(pts.min(axis=0)).astype(int),0)
 hi=np.minimum(np.ceil(pts.max(axis=0)).astype(int)+1,N)
 if np.any(hi<=lo): return
 yy,xx=np.mgrid[lo[1]:hi[1],lo[0]:hi[0]]
 signs=[]
 for p,q in zip(pts,np.roll(pts,-1,axis=0)):
  signs.append((xx-p[0])*(q[1]-p[1])-(yy-p[1])*(q[0]-p[0]))
 mask=(np.minimum.reduce(signs)>=0)|(np.maximum.reduce(signs)<=0)
 img[lo[1]:hi[1],lo[0]:hi[0]][mask]=color

def stone_texture(index,key,base,ore):
 rng=np.random.default_rng(8401+index*97)
 variation=noise(rng,5)*.14+noise(rng,15)*.12+noise(rng,38)*.025
 img=np.clip(np.array(base)/255*(1+variation[:,:,None]),0,1)
 # Quiet broad mineral flakes. Soft stone stays subordinate to saturated ore.
 for _ in range(95):
  center=rng.uniform(.015,.985,2); r=rng.uniform(.008,.063)
  angle=rng.uniform(0,6.28); vertices=[]
  for j in range(5):
   t=angle+j*math.tau/5
   vertices.append(center+np.array([math.cos(t),math.sin(t)])*r*rng.uniform(.7,1.25))
  col=np.array(base)/255*rng.uniform(.91,1.085)
  for j in range(1,4): triangle(img,vertices[0],vertices[j],vertices[j+1],col)
 if ore:
  # Hand-composed distribution: a recognisable main seam, three satellites,
  # and sparse flecks, with breathing room at tile boundaries.
  centers=[(.46,.47,.145),(.28,.63,.079),(.72,.74,.076),(.76,.30,.064),
           (.21,.24,.052),(.49,.84,.037),(.17,.80,.025),(.85,.52,.025),(.52,.16,.028)]
  phase=(index%3)*.18
  for k,(cx,cy,r) in enumerate(centers):
   cx+=rng.uniform(-.023,.023); cy+=rng.uniform(-.023,.023)
   count=6 if k<4 else 5
   radii=rng.uniform(.80,1.14,count)*r
   angles=np.arange(count)*math.tau/count+phase+rng.uniform(-.13,.13,count)
   ring=[np.array((cx+math.cos(t)*rad,cy+math.sin(t)*rad*.82)) for t,rad in zip(angles,radii)]
   center=np.array((cx,cy))
   # Dark mineral recess and a copper-toned rim; no separate mesh per nugget.
   outer=[center+(p-center)*1.16 for p in ring]
   for j in range(count): triangle(img,center,outer[j],outer[(j+1)%count],np.array(base)/255*.47)
   rim=[center+(p-center)*1.055 for p in ring]
   for j in range(count): triangle(img,center,rim[j],rim[(j+1)%count],np.array(ore)/255*.64)
   inner=center+np.array((-.024*r/.145,.026*r/.145))
   for j in range(count):
    # Upper-left light and a pale highlight distinguish each angular facet.
    normal=(ring[j]+ring[(j+1)%count])/2-center
    light=.84+(-normal[0]+normal[1])/r*.23
    color=np.clip(np.array(ore)/255*light,0,1)
    if j==1: color=color*.56+np.ones(3)*.44
    if j==2: color=color*.84+np.ones(3)*.16
    triangle(img,inner,ring[j],ring[(j+1)%count],color)
 else:
  # Low-contrast slate inclusions identify the common block without looking like ore.
  for cx,cy,r in [( .22,.26,.032),(.71,.69,.045),(.31,.76,.025),(.81,.28,.021)]:
   pts=[(cx+math.cos(j*math.tau/5)*r,cy+math.sin(j*math.tau/5)*r) for j in range(5)]
   for j in range(1,4): triangle(img,pts[0],pts[j],pts[j+1],np.array(base)/255*.79)
 # Fine pale borders define the cells without an expensive outline mesh.
 edge=np.minimum.reduce([X,Y,1-X,1-Y])
 rim=np.array(base)/255*.9+.16
 img[edge<.0018]=rim
 shadow=(edge>=.0018)&(edge<.0045)
 img[shadow]*=.91
 rgba=np.ones((N,N,4),np.float32)
 rgba[:,:,:3]=np.clip(img,0,1)
 image=bpy.data.images.new(key+'_BaseColor',width=N,height=N,alpha=False)
 image.colorspace_settings.name='sRGB'
 image.pixels.foreach_set(rgba.ravel())
 image.filepath_raw=str(TEX/(key+'_BaseColor.png'))
 image.file_format='PNG';image.save();image.pack()
 return image

def material(name,color,roughness=.78):
 m=bpy.data.materials.new(name);m.diffuse_color=(*color,1);m.use_nodes=True
 bs=m.node_tree.nodes.get('Principled BSDF')
 bs.inputs['Base Color'].default_value=(*color,1)
 bs.inputs['Roughness'].default_value=roughness
 return m

scene=bpy.data.scenes.new('Energy Core - Polished Ore Collection')
bpy.context.window.scene=scene
scene.unit_settings.system='NONE'
assets=bpy.data.collections.new('11 ORE BLOCKS - EXPORTABLE');scene.collection.children.link(assets)
stage=bpy.data.collections.new('SHOWCASE ONLY - DO NOT IMPORT');scene.collection.children.link(stage)
manifest={'count':len(DEFS),'body_size':[6,6,6],'texture_size':[N,N],'models':[]}
models=[]
for i,(key,title,base,ore) in enumerate(DEFS):
 image=stone_texture(i,key,base,ore)
 m=material(key+'_PolishedStone',tuple(c/255 for c in base))
 tex=m.node_tree.nodes.new('ShaderNodeTexImage');tex.image=image;tex.interpolation='Linear'
 m.node_tree.links.new(tex.outputs['Color'],m.node_tree.nodes['Principled BSDF'].inputs['Base Color'])
 # Six quads, each using the entire tile; rotations break repetition across faces.
 vertices=[(-3,-3,-3),(3,-3,-3),(3,3,-3),(-3,3,-3),(-3,-3,3),(3,-3,3),(3,3,3),(-3,3,3)]
 faces=[(0,3,2,1),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7),(4,5,6,7)]
 mesh=bpy.data.meshes.new(key+'_CubeMesh');mesh.from_pydata(vertices,[],faces);mesh.update()
 uv=mesh.uv_layers.new(name='UVMap')
 corners=[(.001,.001),(.999,.001),(.999,.999),(.001,.999)]
 for p in mesh.polygons:
  for j,loop in enumerate(p.loop_indices): uv.data[loop].uv=corners[(j+p.index)%4]
 ob=bpy.data.objects.new(key,mesh);assets.objects.link(ob);mesh.materials.append(m)
 ob.location=((i%4)*10.8,(i//4)*16,3.65)
 ob['RobloxModelName']=key;ob['MaterialName']=title;ob['MiningBodySize']='6,6,6'
 bevel=ob.modifiers.new('Hairline polished edge','BEVEL');bevel.width=.012;bevel.segments=1
 bevel.affect='EDGES'
 bpy.context.view_layer.objects.active=ob;ob.select_set(True)
 bpy.ops.object.modifier_apply(modifier=bevel.name)
 ob.select_set(False)
 models.append(ob)
 # Export only the asset, centred at the origin, with the colour map embedded.
 old=ob.location.copy();ob.location=(0,0,0);ob.select_set(True)
 bpy.ops.export_scene.fbx(filepath=str(OUT/(key+'.fbx')),use_selection=True,
   object_types={'MESH'},axis_forward='-Z',axis_up='Y',global_scale=1,
   apply_unit_scale=False,bake_anim=False,path_mode='COPY',embed_textures=True,
   use_triangles=True,mesh_smooth_type='FACE')
 ob.location=old;ob.select_set(False)
 triangles=sum(len(p.vertices)-2 for p in mesh.polygons)
 manifest['models'].append({'key':key,'material':title,'fbx':key+'.fbx',
   'texture':'textures/'+key+'_BaseColor.png','triangles':triangles,'dimensions':list(ob.dimensions)})
 print('ORE COMPLETE',key,triangles,flush=True)

def text(name,body,position,size,mat):
 curve=bpy.data.curves.new(name,'FONT');curve.body=body;curve.align_x='CENTER';curve.size=size
 curve.extrude=.001;obj=bpy.data.objects.new(name,curve);stage.objects.link(obj)
 obj.location=position;curve.materials.append(mat);return obj
white=material('Showcase - warm white',(.88,.94,1))
muted=material('Showcase - steel',(.28,.47,.64))
floor=material('Showcase - midnight navy',(.014,.025,.047),.9)
for i,ob in enumerate(models):
 x,y,_=ob.location
 text('Label '+DEFS[i][0],DEFS[i][1].upper(),(x,y-4.6,.035),.48,white)
 text('Number '+DEFS[i][0],f'{i+1:02d}  /  ENERGY CORE',(x,y-5.35,.035),.24,muted)
text('Collection title','ENERGY CORE  /  ORE COLLECTION',(16.2,42,.035),1.05,white)
text('Collection subtitle','11 MATERIALS     /     FACETED MINERALS     /     ROBLOX READY',(16.2,40.65,.035),.38,muted)
bpy.ops.mesh.primitive_plane_add(size=200,location=(16,12,-.01))
plane=bpy.context.object;plane.name='Studio Backdrop'
for col in list(plane.users_collection): col.objects.unlink(plane)
stage.objects.link(plane);plane.data.materials.append(floor)

def area(name,loc,energy,size):
 data=bpy.data.lights.new(name,'AREA');data.energy=energy;data.shape='DISK';data.size=size
 ob=bpy.data.objects.new(name,data);stage.objects.link(ob);ob.location=loc
 ob.rotation_euler=(Vector((16,12,0))-ob.location).to_track_quat('-Z','Y').to_euler()
area('Large softbox',(-4,-12,42),15000,25)
area('Cool fill',(48,16,30),10500,22)
area('Top rim',(10,40,25),12000,18)
world=bpy.data.worlds.new('Ore Studio World');world.use_nodes=True
world.node_tree.nodes['Background'].inputs[0].default_value=(.17,.22,.32,1)
world.node_tree.nodes['Background'].inputs[1].default_value=.5;scene.world=world
camdata=bpy.data.cameras.new('Collection Camera');cam=bpy.data.objects.new('Collection Camera',camdata)
stage.objects.link(cam);cam.location=(41,-50,108)
cam.rotation_euler=(Vector((16.2,18,0))-cam.location).to_track_quat('-Z','Y').to_euler()
camdata.type='ORTHO';camdata.ortho_scale=64;scene.camera=cam
scene.render.engine='CYCLES';scene.cycles.samples=40;scene.cycles.use_denoising=True
scene.render.resolution_x=1800;scene.render.resolution_y=1500;scene.render.resolution_percentage=100
scene.view_settings.view_transform='Standard'
scene.render.image_settings.file_format='PNG';scene.render.filepath=str(OUT/'polished-ores-preview.png')
for ob in scene.objects: ob.select_set(False)
models[0].select_set(True);bpy.context.view_layer.objects.active=models[0]
for screen in bpy.data.screens:
 for area_ui in screen.areas:
  if area_ui.type=='VIEW_3D':
   area_ui.spaces.active.region_3d.view_perspective='CAMERA'
   area_ui.spaces.active.shading.type='MATERIAL'
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2))
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'EnergyCore-PolishedOres.blend'))
print('ALL 11 ASSETS SAVED; rendering collection preview',flush=True)
bpy.ops.render.render(write_still=True)
print('POLISHED ORES FINISHED: '+str(OUT),flush=True)
