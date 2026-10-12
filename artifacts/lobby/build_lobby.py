import bpy, math, random, os
from mathutils import Vector
random.seed(14)
# Preserve the existing scene objects in a hidden collection.
original=bpy.data.collections.new('Original Scene - preserved')
bpy.context.scene.collection.children.link(original)
for obj in list(bpy.context.scene.objects):
    for c in list(obj.users_collection): c.objects.unlink(obj)
    original.objects.link(obj)
original.hide_render=True
original.hide_viewport=True
root=bpy.data.collections.new('ENERGY CORE - Lobby')
bpy.context.scene.collection.children.link(root)
collections={}
def group(name):
    if name not in collections:
        c=bpy.data.collections.new(name);root.children.link(c);collections[name]=c
    return collections[name]
current=group('01 Terrain and Paths')
def place(obj,name,mat):
    obj.name=name
    for c in list(obj.users_collection):c.objects.unlink(obj)
    current.objects.link(obj)
    if mat:obj.data.materials.append(mat)
    return obj
def material(name,color,emit=0):
    m=bpy.data.materials.new(name);m.diffuse_color=(*color,1);m.use_nodes=True
    n=next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
    n.inputs['Base Color'].default_value=(*color,1);n.inputs['Roughness'].default_value=.7
    if emit:n.inputs['Emission Color'].default_value=(*color,1);n.inputs['Emission Strength'].default_value=min(emit,.22)
    return m
grass=material('Grass - vivid lime',(.24,.75,.055));grass2=material('Grass - light',(.45,.9,.10))
soil=material('Cliff - warm terracotta',(.63,.29,.10));soil2=material('Cliff - amber',(.85,.43,.13))
navy=material('Machine - midnight blue',(.035,.065,.15));white=material('Signs - white',(.95,.99,1))
path=material('Paths - lavender blue',(.47,.62,.88));path2=material('Path seams',(.27,.39,.64))
cyan=material('Electric cyan',(.03,.8,1),1.1);purple=material('Electric violet',(.53,.055,.95),.7)
pink=material('Electric pink',(1,.06,.57),.8);gold=material('Golden yellow',(1,.69,.025),.4)
orange=material('Weapon orange',(1,.29,.025));green=material('Sell green',(.08,.8,.32))
wood=material('Warm wood',(.52,.24,.085));stone=material('Shaft slate',(.15,.22,.31));black=material('Shaft darkness',(.008,.015,.03))
def box(name,loc,size,mat,bev=0):
    bpy.ops.mesh.primitive_cube_add(size=1,location=loc);o=place(bpy.context.object,name,mat);o.dimensions=size
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    if bev:
        b=o.modifiers.new('Small clean edges','BEVEL');b.width=bev;b.segments=1
        o.modifiers.new('Weighted corner normals','WEIGHTED_NORMAL')
    return o
def cyl(name,loc,r,depth,mat,verts=12):
    bpy.ops.mesh.primitive_cylinder_add(vertices=verts,radius=r,depth=depth,location=loc);return place(bpy.context.object,name,mat)
def text(name,body,loc,size,mat=white):
    cu=bpy.data.curves.new(name,'FONT');cu.body=body;cu.align_x='CENTER';cu.align_y='CENTER';cu.size=size;cu.extrude=.035;cu.bevel_depth=.01
    o=bpy.data.objects.new(name,cu);current.objects.link(o);o.location=loc;o.rotation_euler=(math.pi/2,0,0);o.data.materials.append(mat);return o
def sign(name,body,x,y,z,w,accent,sub=None):
    box(name+' Board',(x,y,z),(w,1,6),navy,.3)
    box(name+' Top trim',(x,y-.6,z+3),(w,.25,.35),accent)
    text(name+' Label',body,(x,y-.58,z),3.3)
    if sub:text(name+' Subtitle',sub,(x,y-.6,z-4.4),1.45,accent)
def crystal(name,x,y,z,s,mat):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1,radius=s,location=(x,y,z));o=place(bpy.context.object,name,mat);o.scale=(.65,.65,1.5);return o
# Four separate ground slabs leave a real 72 x 72 opening at origin.
box('Lobby meadow',(0,-119,-2),(220,166,4),grass)
box('Left mine meadow',(-73,0,-2),(74,72,4),grass)
box('Right mine meadow',(73,0,-2),(74,72,4),grass)
box('Rear meadow',(0,55,-2),(220,38,4),grass)
# Terraced boundary, lower in front for easy visual readability.
for x in [-114,114]:
    for y in range(-186,71,32):
        h=random.choice([12,16,20]);box('Low poly cliff',(x,y,h/2-3),(10,32,h),soil)
        box('Cliff grass cap',(x,y,h-2),(11,32,2),grass2)
        box('Outer cliff tier',(x*1.055,y,h/2+3),(7,32,h+8),soil2)
for x in range(-96,110,32):
    box('Rear cliff',(x,79,10),(32,12,24),soil2);box('Rear green ledge',(x,79,23),(32,13,2),grass2)
box('Spawn meadow extension',(0,-209,-2),(220,14,4),grass)
box('Spawn connecting path',(0,-197,.18),(18,24,.36),path)
# Promenade and clear spokes.
box('Main walk',(0,-111,.17),(18,148,.34),path)
box('Shop cross walk',(0,-57,.18),(166,13,.36),path)
box('Training promenade',(0,-152,.19),(174,12,.38),path)
box('Stabilizer approach',(-45,-100,.19),(80,12,.38),path)
for y in range(-182,-37,8):box('Main walk seam',(0,y,.36),(18,.16,.05),path2)
for x in range(-80,81,8):
    box('Shop walk seam',(x,-57,.39),(.16,13,.05),path2)
    box('AFK walk seam',(x,-152,.41),(.16,12,.05),path2)
cyl('Central hub dark base',(0,-100,.35),18,.7,navy,16)
cyl('Central hub pale paving',(0,-100,.8),16.7,.3,path,16)
cyl('Hub energy ring',(0,-100,1),11,.25,cyan,16)
cyl('Hub inner platform',(0,-100,1.2),10.3,.4,path,16)
for y in [-132,-122,-82,-72]:
    o=box('Direction chevron',(0,y,.44),(3,.6,.1),gold);o.rotation_euler.z=.6
    o=box('Direction chevron',(2.4,y,.44),(3,.6,.1),gold);o.rotation_euler.z=-.6
# Shaft walls with visible strata; depth represents full game shell.
current=group('02 MineArea - Empty Shaft')
for i,(z,h,m) in enumerate([(-15,30,stone)]):
    for x in [-37.5,37.5]:box('Shaft side stratum '+str(i),(x,0,z),(3,72,h),m)
    for y in [-37.5,37.5]:box('Shaft end stratum '+str(i),(0,y,z),(78,3,h),m)
box('Bedrock',(0,0,-31),(78,78,2),black)
for x in [-38,38]:
    box('Mine rim',(x,0,.6),(4,80,1.2),navy,.25)
    box('Mine light trim',(x,0,1.24),(.5,80,.15),gold)
for y in [-38,38]:
    box('Mine rim',(0,y,.6),(72,4,1.2),navy,.25)
    box('Mine light trim',(0,y,1.24),(72,.5,.15),gold)
for x in [-35,35]:
    box('Mine gate pillar',(x,-43,12),(4,4,24),orange,.25)
    box('Gate foot',(x,-43,1.4),(7,7,2.8),navy,.2)
box('Mine gate beam',(0,-43,24),(76,5,6),gold,.4)
sign('Mine','ENERGY MINE',0,-46,25,53,gold,'DIG  /  DISCOVER  /  POWER UP')
for x in [-38,38]:
    for y in [-28,-10,10,28]:
        box('Safety post',(x,y,3),(1,1,4),gold)
    for y in [-19,0,19]:box('Safety rail',(x,y,4),(1,18,1),navy)
# Shops are separate collections and counter objects retain integration names.
def shop(key,title,x,y,accent,icon):
    global current
    current=group('03 Shop - '+key)
    box(key+' Deck',(x,y,.6),(30,24,1.2),accent,.4)
    box(key+' Rear wall',(x,y+9,7),(28,2,13),accent,.3)
    for dx in [-13,13]:
        box(key+' Pillar',(x+dx,y-9,8),(2,2,16),wood,.2)
        box(key+' Side',(x+dx,y+2,4),(2,12,7),wood,.2)
    for i in range(6):box(key+' Canopy stripe',(x-12.5+i*5,y,16),(5,26,2),accent if i%2==0 else white,.12)
    box(key+' Counter',(x,y-7,4),(24,4,6),navy,.3)
    box(key+' Countertop',(x,y-7,7.2),(25,5,.6),gold,.15)
    sign(key,title,x,y-12,22,34,accent)
    if icon=='weapon':
        box('Display zapper body',(x,y,10),(12,3,3),navy,.3)
        box('Display zapper muzzle',(x-6,y,10),(2,3.5,3.5),cyan,.2)
        box('Display zapper handle',(x+3,y,7.7),(2,2,4),orange,.2)
    elif icon=='bag':
        box('Display upgrade bag',(x,y+2,9),(7,4,8),gold,.6)
        box('Bag front pocket',(x,y-.2,7),(5,.6,3),orange,.2)
        box('Bag handle',(x,y+2,14),(3,1,1),navy,.2)
    else:
        for dx in [-6,0,6]:crystal('Ore sale display',x+dx,y,9,2,gold)
        # Blocky vendor.
        box('Ore Buyer torso',(x,y+3,7),(4,2.5,5),green,.2)
        box('Ore Buyer head',(x,y+3,11),(3,3,3),gold,.2)
        for dx in [-1.2,1.2]:box('Ore Buyer leg',(x+dx,y+3,3.3),(1.6,2,3),navy)
shop('WeaponStore','WEAPONS',-66,-37,orange,'weapon')
shop('UpgradeStore','UPGRADES',66,-37,purple,'bag')
shop('SellStore','SELL ORE',66,-89,green,'sell')
# Hero stabilizer with a clear empty core mount and reveal space.
current=group('04 Stabilizer')
x,y=-64,-101
cyl('Stabilizer outer deck',(x,y,.7),18,1.4,navy)
cyl('Stabilizer violet ring',(x,y,1.5),16.5,.3,purple)
cyl('Stabilizer inner deck',(x,y,1.8),15.4,.4,path)
cyl('Stabilizer pedestal',(x,y,4),7,4,navy)
cyl('Stabilizer gold collar',(x,y,6),7.6,.8,gold)
cyl('CoreMount',(x,y,6.8),4.7,.8,cyan)
cyl('CoreMount placement recess',(x,y,7.3),3.7,.3,navy)
for dx in [-11,11]:
    box('Stabilizer support',(x+dx,y+3,10),(3,4,18),navy,.5)
    box('Stabilizer light',(x+dx,y+.8,11),(1.2,.5,12),purple,.15)
box('Stabilizer overhead',(x,y+3,20),(25,5,4),navy,.5)
box('Stabilizer overhead light',(x,y+.4,19),(18,.3,1),pink)
sign('Stabilizer','CORE STABILIZER',x,y+1,26,42,purple,'PLACE CORE  >  STABILIZE  >  REVEAL')
# Showcase silhouettes on rear display, leaving active mount empty.
for i,m in enumerate([cyan,purple,gold]):
    crystal('Reveal preview core',x-6+i*6,y+4,15,1.5,m)
box('Stabilizer console',(x,y-10,4),(9,4,4),navy,.4)
box('Console screen',(x,y-12.05,4.5),(6,.2,2),cyan,.1)
text('Place prompt','PLACE CORE',(x,y-12.2,4.5),.8,navy)
# Five compact bright training reactors with clear progression.
for idx,(mult,m) in enumerate(zip(['1x','1.5x','3x','5x','8x'],[cyan,purple,gold,pink,green])):
    current=group('05 AFK '+mult)
    x=-72+idx*36;y=-173
    box('AFK '+mult+' Base',(x,y,.75),(28,25,1.5),navy,.4)
    box('AFK '+mult+' Accent deck',(x,y,1.55),(25,22,.25),m,.15)
    box('AFK '+mult+' Standing area',(x,y-5,1.8),(20,10,.25),path,.15)
    cyl('AFK '+mult+' Reactor plinth',(x,y+4,3.1),5.5,2.6,gold)
    o=box('AFK '+mult+' Floating power cube',(x,y+4,8),(5.5,5.5,5.5),m,.3);o.rotation_euler=(.15,.25,.25)
    for dx in [-11,11]:box('AFK '+mult+' Edge light',(x+dx,y,1.8),(.45,21,.4),m)
    sign('AFK '+mult,mult+' AFK TRAINING',x,y+9,16,31,m,'FREE' if idx==0 else str([0,1,3,7,15][idx])+' REBIRTHS')
# Spawn and scenery.
current=group('06 Spawn and Decorations')
cyl('Spawn dark deck',(0,-202,.6),12,1.2,navy,12)
cyl('Spawn cyan pad',(0,-202,1.3),10.8,.2,cyan,12)
text('Spawn welcome','ENERGY CORE',(0,-211,5),3.8,white)
for x,y in [(-97,-30),(97,-25),(-96,-73),(98,-124),(-96,-135),(-93,32),(91,39),(-60,57),(51,59)]:
    box('Tree trunk',(x,y,6),(3.5,3.5,12),wood,.3)
    for z,s in [(13,14),(19,11),(24,7)]:box('Block tree canopy',(x,y,z),(s,s,s*.65),grass2 if z==19 else grass,.4)
for x,y in [(-48,49),(50,48),(-95,-111),(97,-63),(-91,-185),(94,-185)]:
    for i in range(3):crystal('Landscape crystal',x+i*2.2-2,y+(i%2)*2,2+i*.6,2.2,[cyan,purple,gold][i])
for i in range(45):
    x=random.choice([-1,1])*random.uniform(24,100);y=random.uniform(-141,62)
    if abs(y)<43 and abs(x)<44:continue
    if any(abs(x-a)<22 and abs(y-b)<25 for a,b in [(-66,-37),(66,-37),(66,-89),(-64,-101)]):continue
    cyl('Flower stem',(x,y,1),.18,2,green,5)
    cyl('Block flower',(x,y,2),.8,.35,random.choice([white,pink,gold]),5)
# Render setup; original lighting and camera remain preserved.
current=group('07 Presentation')
scene=bpy.context.scene
scene.world.use_nodes=True
bg=next(n for n in scene.world.node_tree.nodes if n.type=='BACKGROUND');bg.inputs['Color'].default_value=(.38,.66,.95,1);bg.inputs['Strength'].default_value=.65
bpy.ops.object.light_add(type='SUN',location=(0,-100,150));sun=place(bpy.context.object,'Lobby sunlight',None);sun.rotation_euler=(.35,-.5,-.35);sun.data.energy=2.2;sun.data.angle=.12
bpy.ops.object.camera_add(location=(220,-350,280));cam=place(bpy.context.object,'Lobby overview camera',None)
cam.rotation_euler=(Vector((0,-65,0))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.type='ORTHO';cam.data.ortho_scale=352;cam.data.clip_end=2000;scene.camera=cam
try:scene.render.engine='CYCLES'
except TypeError:pass
scene.cycles.samples=32
scene.render.resolution_x=1600;scene.render.resolution_y=1400;scene.render.resolution_percentage=100
scene.view_settings.view_transform='Standard'
for area in bpy.context.screen.areas:
    if area.type=='VIEW_3D':
        area.spaces.active.clip_end=3000
        area.spaces.active.region_3d.view_distance=310
        area.spaces.active.region_3d.view_location=(0,-70,0)
        area.spaces.active.shading.type='MATERIAL'
# Scene geometry uses studs; Blender Z is Roblox Y.
scene['Roblox Scale']='1 Blender unit = 1 Roblox stud; Z up; 72 x 72 empty mine opening at origin'
scene['Integration']='Art only. Runtime mine blocks, prompts and AFK logic remain in Roblox.'
scene.render.filepath='/Users/ajdinhusetovic/Desktop/ProjectMilka/artifacts/lobby/lobby-preview.png'
bpy.ops.wm.save_as_mainfile(filepath='/Users/ajdinhusetovic/Desktop/ProjectMilka/artifacts/lobby/EnergyCoreLobby.blend')
print('Built lobby:',len(root.all_objects),'objects. Mine opening: 72x72 at origin. Saved EnergyCoreLobby.blend')
