import bpy, math, random, json
from pathlib import Path
from mathutils import Vector
random.seed(24)
OUT=Path('/Users/ajdinhusetovic/Desktop/ProjectMilka/artifacts/lobby-v2')
previous=bpy.context.scene
scene=bpy.data.scenes.new('Energy Core - Compact Lobby V2')
scene.unit_settings.system='NONE'
bpy.context.window.scene=scene
root=bpy.data.collections.new('COMPACT LOBBY V2');scene.collection.children.link(root)
materials={}
def mat(name,rgb,emission=0):
    m=bpy.data.materials.new('V2 '+name);m.diffuse_color=(*rgb,1);m.use_nodes=True
    node=next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED')
    node.inputs['Base Color'].default_value=(*rgb,1);node.inputs['Roughness'].default_value=.8
    node.inputs['Emission Color'].default_value=(*rgb,1);node.inputs['Emission Strength'].default_value=emission
    materials[name]=m;return m
lime=mat('Grass',(.19,.7,.025));leaf=mat('Leaf',(.31,.84,.035));cliff=mat('Orange earth',(.78,.32,.065));cliff_light=mat('Earth highlight',(.95,.46,.085))
wood=mat('Booth orange wood',(.74,.30,.07));darkwood=mat('Wood edges',(.47,.16,.035))
navy=mat('Deep blue',(.022,.040,.075));slate=mat('Grey paving',(.33,.44,.56));pale=mat('Sand paths',(.78,.79,.45));white=mat('White',(.97,.98,1))
yellow=mat('Yellow',(.99,.75,.015));orange=mat('Weapon orange',(1,.24,.012));green=mat('Sell green',(.04,.74,.19));purple=mat('Upgrade violet',(.53,.045,.9));cyan=mat('Cyan',(.012,.76,.95),.15);pink=mat('Pink',(1,.035,.48),.12)
red=mat('Leaderboard carpet',(.61,.025,.11));grey=mat('Shaft stone',(.16,.22,.28));black=mat('Pit shadow',(.008,.012,.02));blue=mat('Royal blue',(.035,.25,.85));grey2=mat('Scale mannequin',(.55,.61,.69))
current=None;parent=None;groups={}
def section(name):
    global current,parent
    c=bpy.data.collections.new('V2 '+name);root.children.link(c);current=c
    e=bpy.data.objects.new(name,None);c.objects.link(e);e.empty_display_size=.5;parent=e;groups[name]=e
    return e
def link(o,name,m):
    o.name=name
    for c in list(o.users_collection):c.objects.unlink(o)
    current.objects.link(o);o.parent=parent
    if m:o.data.materials.append(m)
    return o
def box(name,loc,size,m,bevel=0):
    bpy.ops.mesh.primitive_cube_add(size=1,location=loc);o=link(bpy.context.object,name,m);o.dimensions=size
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    if bevel:
        mod=o.modifiers.new('Roblox soft corners','BEVEL');mod.width=bevel;mod.segments=1
        o.modifiers.new('Weighted normals','WEIGHTED_NORMAL')
    return o
def cylinder(name,loc,r,d,m,n=12):
    bpy.ops.mesh.primitive_cylinder_add(vertices=n,radius=r,depth=d,location=loc);return link(bpy.context.object,name,m)
def label(name,body,loc,size,m=white):
    cu=bpy.data.curves.new(name,'FONT');cu.body=body;cu.align_x='CENTER';cu.align_y='CENTER';cu.size=size;cu.extrude=.008
    o=bpy.data.objects.new(name,cu);current.objects.link(o);o.parent=parent;o.location=loc;o.rotation_euler=(math.pi/2,0,0);cu.materials.append(m);return o
def horizontal_label(name,body,loc,size,m):
    o=label(name,body,loc,size,m);o.rotation_euler=(0,0,0);return o
def crystal(name,x,y,z,s,m):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1,radius=s,location=(x,y,z));o=link(bpy.context.object,name,m);o.scale=(.65,.65,1.5);return o
section('Terrain')
box('Compact lobby ground',(0,-77,-1.5),(156,82,3),lime)
box('West mine verge',(-57,0,-1.5),(42,72,3),lime)
box('East mine verge',(57,0,-1.5),(42,72,3),lime)
box('Rear mine verge',(0,45,-1.5),(156,18,3),lime)
# Low, stepped perimeter provides color without enclosing the hub in tall walls.
for side in [-1,1]:
    for y in range(-105,51,20):
        h=10 if y<-40 else 15
        box('Terraced orange boundary',(side*81,y,h/2-1),(7,20,h),cliff)
        box('Green wall top',(side*81,y,h-.5),(7.5,20,1),leaf)
        box('Second cliff tier',(side*86,y,h/2+2),(4,20,h+5),cliff_light)
for x in range(-70,80,20):
    box('Rear wall',(x,59,7),(20,10,17),cliff)
    box('Rear turf',(x,59,16),(20,10,1),leaf)
section('PlazaAndPaths')
box('Main spawn to mine path',(0,-78,.10),(10,80,.3),pale)
box('Short cross plaza route',(0,-83,.16),(124,9,.34),pale)
box('Shop apron',(0,-66,.23),(51,13,.3),slate)
box('West leaderboard approach',(-43,-89,.25),(43,9,.32),slate)
box('East AFK approach',(45,-92,.27),(38,8,.32),slate)
cylinder('Spawn plaza edging',(0,-82,.3),11.5,.6,slate,20)
cylinder('Spawn plaza surface',(0,-82,.65),10.9,.12,pale,20)
# Simple four-point energy motif flush with the paving.
for angle in [0,math.pi/2,math.pi,math.pi*1.5]:
    o=box('Plaza energy motif',(0,-82,.75),(1.4,9,.05),navy);o.rotation_euler.z=angle+math.pi/4
for y in [-113,-106,-99,-47]:
    for dx,angle in [(-.9,-.6),(.9,.6)]:
        o=box('Small wayfinding arrow',(dx,y,.34),(2,.35,.05),yellow);o.rotation_euler.z=angle
for y in range(-114,-36,6):
    if -94<y<-70:continue
    box('Paving seam',(0,y,.215),(10,.07,.04),slate)
# Mine shell stays aligned to existing grid origin, separate from compact player hub.
section('MineArea')
for x in [-37,37]:box('MineSideWall',(x,0,-12),(2,72,24),grey)
for y in [-37,37]:box('MineEndWall',(0,y,-12),(76,2,24),grey)
box('Illustrative empty pit floor',(0,0,-24.5),(76,76,1),black)
for x in [-37.5,37.5]:
    box('Mine rim',(x,0,.35),(3,78,.7),navy)
    box('Yellow safety stripe',(x,0,.72),(.5,78,.1),yellow)
for y in [-37.5,37.5]:
    box('Mine rim',(0,y,.35),(72,3,.7),navy)
    box('Yellow safety stripe',(0,y,.72),(72,.5,.1),yellow)
# A human-scale gate, rather than a 76-stud monumental sign.
for x in [-7,7]:
    box('Mine entrance post',(x,-42,4.8),(1.5,1.5,9.6),wood,.08)
    box('Mine post shoe',(x,-42,.5),(2,2,1),navy,.05)
box('Mine entrance header',(0,-42,9.8),(18,2,2.8),yellow,.08)
label('Mine sign','MINE',(0,-43.02,9.8),2.2,navy)
for side in [-1,1]:
    for y in [-24,0,24]:
        box('Mine rail post',(side*38.3,y,1.7),(.6,.6,3),yellow)
    for y in [-12,12]:box('Mine low side rail',(side*38.3,y,2.7),(.5,24,.5),navy)
# Three 10 x 8 kiosks, 8.5 studs high, facing the hub.
def kiosk(key,title,x,m,kind):
    section(key);y=-59
    box(key+' platform',(x,y,.25),(11,9,.5),m,.08)
    box(key+' back wall',(x,y+3.7,3.9),(9.5,.55,6.8),wood,.05)
    for dx in [-4.45,4.45]:
        box(key+' canopy post',(x+dx,y-3.6,4.1),(.6,.6,7.7),wood,.04)
        box(key+' side sill',(x+dx,y,2.2),(.6,7.5,3.4),wood,.04)
    for i in range(5):
        box(key+' striped canopy',(x-4.4+i*2.2,y,8.2),(2.2,9.6,.5),m if i%2==0 else white,.03)
    counter=box(key+'_Counter',(x,y-3.2,2.3),(8.3,1.35,3.4),wood,.05);counter['RobloxName']='Counter'
    box(key+' counter lip',(x,y-3.2,4.05),(8.7,1.7,.22),m,.03)
    box(key+' sign backing',(x,y-4.85,9.8),(11,.35,2.2),navy,.04)
    label(key+' sign',title,(x,y-5.04,9.8),1.18,white)
    # Block vendor scaled to a Roblox avatar.
    box(key+' vendor torso',(x,y+1.2,3.3),(2,1.2,2),blue if kind!='sell' else navy,.05)
    box(key+' vendor head',(x,y+1.2,5),(1.5,1.5,1.5),yellow,.06)
    for dx in [-.45,.45]:
        box(key+' vendor leg',(x+dx,y+1.2,1.65),(.8,.95,1.3),green,.03)
    for dx in [-1.3,1.3]:box(key+' vendor arm',(x+dx,y+1.2,3.3),(.6,.8,1.8),yellow,.03)
    if kind=='weapon':
        box('Weapon display zapper',(x-2.6,y-3,4.55),(2.7,.7,.8),navy,.04)
        box('Weapon display tip',(x-4,y-3,4.55),(.45,.8,.9),cyan,.03)
    elif kind=='upgrade':
        box('Bag upgrade display',(x+2.6,y-3,4.9),(1.5,1,1.8),yellow,.1)
        box('Upgrade bag pocket',(x+2.6,y-3.55,4.6),(1,.15,.6),orange,.02)
    else:
        for dx in [-3,-2,2,3]:box('Ore buyer cash',(x+dx,y-3,4.35),(.7,.5,.4),green)
kiosk('WeaponStore','WEAPONS',-16,orange,'weapon')
kiosk('UpgradeStore','UPGRADES',16,purple,'upgrade')
kiosk('SellStore','SELL ORE',0,green,'sell')
for obj in list(groups['SellStore'].children): obj.location-=Vector((0,-59,0))
groups['SellStore'].location=(-20,-96,0);groups['SellStore'].rotation_euler.z=math.pi/4
# Compact core station near spawn, with a clear empty core socket.
section('Stabilizer');x=20;y=-100
cylinder('Stabilizer platform',(x,y,.3),6,.6,navy,12)
cylinder('Stabilizer purple outline',(x,y,.68),5.55,.14,purple,12)
cylinder('Stabilizer platform top',(x,y,.85),5.15,.18,slate,12)
cylinder('Stabilizer pedestal',(x,y,1.6),2.7,1.3,navy)
cylinder('Stabilizer pedestal collar',(x,y,2.35),2.95,.3,yellow)
cylinder('CoreMount',(x,y,2.65),2.1,.3,cyan)
cylinder('Empty core socket',(x,y,2.84),1.65,.1,navy)
for dx in [-4.1,4.1]:
    box('Stabilizer fork support',(x+dx,y+1.5,4.25),(.8,1.2,7),navy,.06)
    box('Stabilizer lit fork',(x+dx,y+.86,4.5),(.32,.12,5.3),purple,.02)
box('Stabilizer rear arch',(x,y+1.5,7.8),(9,1.2,.8),navy,.06)
box('Stabilizer sign backing',(x,y+1.35,9.2),(14,.4,2),navy,.06)
label('Stabilizer label','CORE STABILIZER',(x,y+1.1,9.2),.95)
label('Stabilizer instructions','PLACE CORE  >  REVEAL',(x,y+1.09,7.95),.53,pink)
# Discrete rarity gems on arch, rather than filling the active socket.
for dx,m in [(-2.2,cyan),(0,purple),(2.2,yellow)]:crystal('Stabilizer reveal showcase',x+dx,y+1.5,6.3,.65,m)
box('Core station console',(x,y-3.8,1.75),(3,1.2,1.8),navy,.08)
box('Core station small screen',(x,y-4.43,2.03),(2,.12,.75),cyan,.03)
# Two short tiers of small AFK pads on the right.
section('AFKTraining')
box('AFK plaza',(48,-84,.25),(37,28,.5),slate)
box('AFK upper tier',(48,-76,1),(37,12,1.5),yellow)
box('AFK step',(48,-82.8,.68),(37,1.8,.7),yellow)
box('AFK path carpet',(48,-85,.53),(35,2,.06),navy)
label('AFK area title','AFK TRAINING',(48,-70,11),2.2)
box('AFK title backing',(48,-69.8,11),(34,.4,3.3),navy,.05)
for idx,(mult,m) in enumerate(zip(['1x','1.5x','3x','5x','8x','12x'],[cyan,green,yellow,purple,pink,orange])):
    x=36+(idx%3)*12;y=-90 if idx<3 else -76;z=.6 if idx<3 else 1.8
    box('AFK '+mult+' pad',(x,y,z+.18),(8.4,8,.36),navy,.06)
    box('AFK '+mult+' colored inset',(x,y,z+.4),(7.65,7.25,.1),m)
    box('AFK '+mult+' training tile',(x,y-1.8,z+.5),(6.5,3.5,.08),slate)
    box('AFK '+mult+' core seat',(x,y+1.8,z+.95),(2.8,2.8,.8),yellow,.08)
    o=box('AFK '+mult+' power cube',(x,y+1.8,z+2.8),(2.15,2.15,2.15),m,.06);o.rotation_euler=(.1,.16,.14)
    label('AFK '+mult+' multiplier',mult+' POWER',(x,y+.4,z+5.1),.85,m)
    label('AFK '+mult+' requirement','FREE' if idx==0 else str([0,1,3,5,8,12][idx])+' REBIRTHS',(x,y+.39,z+4.2),.45,white)
# Four boards on a left-side stage, all visible and accessible from the hub.
section('Leaderboards')
box('Leaderboard stage',(-45,-74,.5),(49,15,1),slate)
box('Leaderboard red carpet',(-45,-75,1.03),(46,12,.06),red)
box('Leaderboard front step',(-45,-82,.25),(49,2, .5),slate)
box('Leaderboard gold stage edge',(-45,-81.3,1.1),(46,.3,.12),yellow)
for i,(title,m) in enumerate([('MOST LEVELS',cyan),('MOST MONEY',green),('MOST DAMAGE',orange),('MOST REBIRTHS',purple)]):
    x=-63+i*12;y=-69
    box(title+' stand',(x,y,1.55),(9.9,2,1),darkwood,.04)
    box(title+' frame',(x,y,7.5),(10.1,1,11.5),wood,.07)
    surface=box(title+' DisplaySurface',(x,y-.54,7.25),(9,.12,9.7),navy)
    surface['LeaderboardCategory']=title
    box(title+' category header',(x,y-.63,11.8),(9,.12,2),m)
    label(title+' title',title,(x,y-.71,11.85),.74,white)
    for row in range(5):
        z=9.75-row*1.45
        box(title+' row background',(x,y-.64,z),(8.5,.05,1.22),navy if row%2==0 else darkwood)
        label(title+' rank '+str(row+1),str(row+1),(x-3.45,y-.70,z),.77,[yellow,cyan,orange,white,white][row])
        label(title+' empty player '+str(row+1),'---',(x-1,y-.70,z),.65,white)
        label(title+' empty value '+str(row+1),'--',(x+2.65,y-.70,z),.65,m)
label('Leaderboards area title','LEADERBOARDS',(-45,-69.3,15.8),2.1)
box('Leaderboards title backing',(-45,-69.05,15.8),(45,.35,3.2),navy,.05)
# Scenery kept at the perimeter, not between the player and interactions.
section('Scenery')
for x,y in [(-72,-104),(72,-104),(-72,-48),(72,-47),(-64,32),(65,32),(-43,45),(42,46)]:
    box('Small tree trunk',(x,y,3),(1.6,1.6,6),wood)
    for z,s in [(7.5,7),(11,5),(13.5,3.3)]:box('Small block tree leaves',(x,y,z),(s,s,s*.7),leaf if z==11 else lime,.06)
for x,y in [(-69,-90),(70,-65),(-52,-104),(57,-107),(-53,40),(52,42)]:
    for idx in range(3):crystal('Decorative crystal',x+idx*1.1-1,y+(idx%2)*.7,.9+idx*.25,.65,[cyan,purple,yellow][idx])
for x,y in [(-9,-98),(12,-104),(-13,-73),(22,-76),(-70,-57),(68,-56),(-27,-47),(30,-46),(-66,9),(64,10),(-53,-26),(52,-28)]:
    cylinder('Flower stem',(x,y,.6),.07,1.2,green,5)
    cylinder('Small low poly flower',(x,y,1.2),.35,.16,random.choice([white,pink,yellow]),5)
# Player scale reference is excluded from the export.
section('PresentationOnly')
x=6;y=-87
box('5.5 stud avatar torso',(x,y,3),(2,1,2),blue,.04)
box('5.5 stud avatar head',(x,y,4.8),(1.5,1.5,1.4),yellow,.08)
for dx in [-.52,.52]:box('Scale avatar leg',(x+dx,y,1.5),(.9,1,2),navy,.04)
for dx in [-1.5,1.5]:box('Scale avatar arm',(x+dx,y,3),(.9,1,2),yellow,.04)
label('Scale reference label','5.5 STUD PLAYER',(x,y-.75,6.1),.55,white)
# Rendering and two viewpoints.
world=bpy.data.worlds.new('V2 blue sky');world.use_nodes=True;scene.world=world
n=next(n for n in world.node_tree.nodes if n.type=='BACKGROUND');n.inputs['Color'].default_value=(.4,.67,.95,1);n.inputs['Strength'].default_value=.7
bpy.ops.object.light_add(type='SUN',location=(0,-40,100));sun=link(bpy.context.object,'V2 daylight',None);sun.data.energy=2;sun.data.angle=.08;sun.rotation_euler=(.3,-.4,-.4)
def camera(name,pos,target,lens=35,ortho=None):
    bpy.ops.object.camera_add(location=pos);o=link(bpy.context.object,name,None);o.rotation_euler=(Vector(target)-o.location).to_track_quat('-Z','Y').to_euler();o.data.clip_end=1000
    o.data.lens=lens
    if ortho:o.data.type='ORTHO';o.data.ortho_scale=ortho
    return o
overview=camera('V2 Overview',(145,-235,190),(0,-34,0),ortho=238)
spawn=camera('V2 Spawn View',(0,-135,38),(0,-76,3),lens=16)
player=camera('V2 Player View',(0,-115,7),(0,-65,4),lens=18)
scene.camera=overview
try:scene.render.engine='CYCLES'
except TypeError:pass
scene.cycles.samples=32
scene.render.resolution_x=1800;scene.render.resolution_y=1500;scene.render.resolution_percentage=100
scene.view_settings.view_transform='Standard'
scene['ArtScale']='1 Blender unit = 1 Roblox stud. Kiosks: 11x9 footprint, 8.5 roof height. AFK pads: 8.4x8.'
scene['Mine']='72x72 empty opening centered at origin; 24-stud preview shell. Existing Roblox runtime owns full depth and ore blocks.'
scene['Leaderboards']='Four art display boards with blank rows. Live data binding belongs to Roblox.'
# Vertex color every mesh so export is not dependent on Blender shader interpretation.
for o in root.all_objects:
    if o.type!='MESH':continue
    mesh=o.data;attr=mesh.color_attributes.new(name='Color',type='BYTE_COLOR',domain='CORNER');mesh.color_attributes.active_color=attr
    for face in mesh.polygons:
        color=mesh.materials[face.material_index].diffuse_color
        for idx in face.loop_indices:attr.data[idx].color=color
for area in bpy.context.screen.areas:
    if area.type=='VIEW_3D':
        r=area.spaces.active.region_3d;r.view_rotation=overview.rotation_euler.to_quaternion();r.view_location=(0,-35,0);r.view_distance=230;r.view_perspective='ORTHO'
        area.spaces.active.clip_end=1500;area.spaces.active.shading.type='MATERIAL'
scene.render.filepath=str(OUT/'compact-overview.png')
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'EnergyCoreLobby-V2.blend'))
bpy.ops.render.render(write_still=True)
scene.camera=player;scene.render.resolution_x=1800;scene.render.resolution_y=1000;scene.render.filepath=str(OUT/'player-view.png')
bpy.ops.render.render(write_still=True)
scene.camera=spawn;scene.render.resolution_y=1100;scene.render.filepath=str(OUT/'spawn-view.png')
bpy.ops.render.render(write_still=True)
scene.camera=overview;scene.render.resolution_y=1500;scene.render.filepath=str(OUT/'compact-overview.png')
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'EnergyCoreLobby-V2.blend'))
print('V2 built:',len(root.all_objects),'objects. 11x9 kiosks, 8.4x8 AFK, four leaderboard boards. Overview and player view rendered.')
