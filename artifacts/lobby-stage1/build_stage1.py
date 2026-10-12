import bpy, math, json
from pathlib import Path
from mathutils import Vector
OUT=Path('/Users/ajdinhusetovic/Desktop/ProjectMilka/artifacts/lobby-stage1')
scene=bpy.data.scenes.new('Energy Core Mining - Stage 1 Layout')
bpy.context.window.scene=scene
scene.unit_settings.system='NONE'
root=bpy.data.collections.new('Stage1_Lobby');scene.collection.children.link(root)
palette={
 'Grass':(80,223,25),'WallOrange':(235,118,26),'WallTop':(71,210,22),
 'Wood':(187,108,47),'Paving':(137,148,160),'PalePath':(211,212,162),
 'WeaponsAccent':(255,182,24),'UpgradeAccent':(164,69,235),'SellAccent':(41,206,72),
 'Cyan':(40,215,238),'Pink':(236,84,176),'DarkGrey':(87,100,115),'White':(245,247,249)
}
def linear(v):
    v=v/255;return v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4
mats={}
for name,rgb in palette.items():
    m=bpy.data.materials.new('S1 '+name);color=tuple(linear(v) for v in rgb)
    m.diffuse_color=(*color,1);m.use_nodes=True
    n=next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED');n.inputs['Base Color'].default_value=(*color,1);n.inputs['Roughness'].default_value=.85
    mats[name]=m
models={};current=None;group_root=None
manifest={'units':'1 Blender unit = 1 Roblox stud','axis':'Blender Z = Roblox Y','mine_opening':{'center':[0,0,0],'width':72,'length':72,'ground_y':0},'groups':{},'palette_rgb':palette}
def group(name):
    global current,group_root
    current=bpy.data.collections.new(name);root.children.link(current)
    group_root=bpy.data.objects.new(name,None);current.objects.link(group_root);models[name]=group_root
    manifest['groups'][name]=[]
    return group_root
def move_obj(o,name,mat):
    o.name=group_root.name+'__'+name
    for c in list(o.users_collection):c.objects.unlink(o)
    current.objects.link(o);o.parent=group_root;o['RobloxName']=name
    if mat:o.data.materials.append(mats[mat])
    return o
def box(name,loc,size,mat):
    bpy.ops.mesh.primitive_cube_add(size=1,location=loc);o=move_obj(bpy.context.object,name,mat);o.dimensions=size
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    manifest['groups'][group_root.name].append({'name':name,'center_blender':list(loc),'size_blender':list(size),'material':mat})
    return o
def cylinder(name,loc,r,depth,mat,vertices=24):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices,radius=r,depth=depth,location=loc);o=move_obj(bpy.context.object,name,mat)
    return o
# Ground top is exactly zero. Four slabs keep the entire 72x72 square empty.
group('LobbyGround')
box('HubGround',(0,-77,-1),(148,82,2),'Grass')
box('WestGround',(-55,0,-1),(38,72,2),'Grass')
box('EastGround',(55,0,-1),(38,72,2),'Grass')
box('NorthGround',(0,45,-1),(148,18,2),'Grass')
group('Paths')
box('MainPath',(0,-77,.08),(12,78,.16),'PalePath')
box('CrossPath',(0,-81,.09),(128,12,.18),'PalePath')
box('ShopApron',(0,-64,.11),(60,10,.22),'Paving')
box('SellApproach',(-20,-90,.12),(20,10,.24),'PalePath')
box('StabilizerApproach',(20,-90,.12),(20,10,.24),'PalePath')
box('LeaderboardApproach',(-43,-77.5,.13),(10,46,.26),'Paving')
cylinder('CentralPlazaRim',(0,-81,.14),10.5,.28,'Paving',32)
cylinder('CentralPlaza',(0,-81,.3),10,.04,'PalePath',32)
# Shared raised grey platform: a single straight row beside the east boundary.
box('AFKPlatform',(56,-70,.5),(16,62,1),'Paving')
box('AFKFrontStep',(46.75,-70,.25),(2.5,62,.5),'Paving')
box('AFKAccessWalk',(43,-70,.12),(5,62,.24),'PalePath')
group('BoundaryWalls')
for side in [-1,1]:
    box('SideWall'+str(side),(side*76,-33,5),(4,174,10),'WallOrange')
    box('SideGreenCap'+str(side),(side*76,-33,10.5),(4.3,174,1),'WallTop')
box('NorthWall',(0,56,5),(156,4,10),'WallOrange')
box('NorthGreenCap',(0,56,10.5),(156,4.3,1),'WallTop')
# Short front returns leave a wide entrance into the compact hub.
for side in [-1,1]:
    box('FrontWall'+str(side),(side*46,-120,5),(60,4,10),'WallOrange')
    box('FrontGreenCap'+str(side),(side*46,-120,10.5),(60,4.3,1),'WallTop')
group('MineEntrance')
# Rim remains strictly outside |x|<36 and |y|<36.
for x in [-37,37]:box('SideRim'+str(x),(x,0,.35),(2,76,.7),'DarkGrey')
for y in [-37,37]:box('EndRim'+str(y),(0,y,.35),(72,2,.7),'DarkGrey')
for x in [-8,8]:box('EntrancePost'+str(x),(x,-41,4.5),(1.2,1.2,9),'Wood')
box('EntranceSignBlank',(0,-41,9.5),(18,1.5,2),'WeaponsAccent')
# Simple placeholder booths with clear standing and NPC space.
def booth(name,x,y,accent,angle=0):
    e=group(name)
    box('BoothFootprint',(0,0,.17),(14,11,.34),accent)
    box('BackWall',(0,4.7,4),(13, .6,7.7),'Wood')
    for dx in [-6.1,6.1]:
        box('FrontPost'+str(dx),(dx,-4.5,4.8),(.7,.7,9.6),'Wood')
        box('SideWall'+str(dx),(dx,0,1.65),(.7,9.5,3),'Wood')
    box('Counter',(0,-4.3,2),(11.5,1.5,3.6),'Wood')
    box('RoofPlaceholder',(0,0,9.9),(14.5,12,.6),accent)
    box('SignBlank',(0,-6,10.5),(10,.25,1.7),accent)
    e.location=(x,y,0);e.rotation_euler.z=angle
    e['FootprintStuds']='14 x 11';e['HeightStuds']=11.35
booth('WeaponStore',-20,-54,'WeaponsAccent')
booth('UpgradeStore',20,-54,'UpgradeAccent')
booth('SellStore',-23,-97,'SellAccent',math.pi/4)
group('Stabilizer')
box('ReservedSpace',(23,-97,.16),(13,13,.24),'Paving')
box('PlaceholderPedestal',(23,-97,1),(4,4,1.5),'DarkGrey')
box('CoreMount',(23,-97,1.85),(2.8,2.8,.2),'Cyan')
# Exactly five pads. Standing area and decorative cube are distinct meshes.
for i,(name,accent) in enumerate([('AFK_1x','Cyan'),('AFK_1_5x','UpgradeAccent'),('AFK_3x','WeaponsAccent'),('AFK_5x','Pink'),('AFK_8x','SellAccent')]):
    group(name);y=-94+i*12
    box('PadBase',(56,y,1.15),(10,10,.3),'DarkGrey')
    box('StandingArea',(53.7,y,1.34),(4.9,8,.08),accent)
    box('TrainingBlockMount',(58.7,y,1.7),(2.8,2.8,.7),'Wood')
    box('TrainingBlock',(58.7,y,3),(2,2,2),accent)
# Reserve the four boards from the earlier request; rows and text come later in Studio.
group('Leaderboards')
box('ReservedLeaderboardPlatform',(-57,-77.5,.4),(18,46,.8),'Paving')
for i,name in enumerate(['MostLevels','MostMoney','MostDamage','MostRebirths']):
    board=box(name+'BoardPlaceholder',(-62,-94+i*11,5.8),(9.5,.65,10.8),'Wood')
    board.rotation_euler.z=math.pi/2
    board['DisplayFacing']='Right / +X toward plaza'
# Only coarse tree masses locate future decoration zones.
group('TreesAndDecorations')
for i,(x,y) in enumerate([(-68,-102),(-68,-48),(68,-109),(67,-31),(-60,33),(60,33),(-24,47),(26,47)]):
    box('Tree'+str(i)+'Trunk',(x,y,2.5),(1.5,1.5,5),'Wood')
    box('Tree'+str(i)+'Crown',(x,y,7),(6.5,6.5,6),'WallTop')
# View-only editable labels identify placeholders. Never exported or baked into meshes.
group('ReviewGuides')
def text(name,body,loc,size,flat=False):
    cu=bpy.data.curves.new(name,'FONT');cu.body=body;cu.align_x='CENTER';cu.align_y='CENTER';cu.size=size;cu.extrude=0
    o=bpy.data.objects.new('ReviewOnly_'+name,cu);current.objects.link(o);o.parent=group_root;o.location=loc
    if not flat:o.rotation_euler=(math.pi/2,0,0)
    cu.materials.append(mats['DarkGrey']);o.visible_shadow=False;return o
player_guides=[];top_guides=[]
for name,body,loc,size in [
 ('Weapons','WEAPONS',(-20,-60.15,10.5),1.12),('Upgrades','UPGRADES',(20,-60.15,10.5),1.1),
 ('Mine','MINE',(0,-41.8,9.5),1.5),('Training','AFK TRAINING',(56,-39,6),1.35),
 ('Leaderboards','4 LEADERBOARDS',(-61.5,-77.5,12),1.1),('Stabilizer','CORE SPACE',(23,-97,4.5),1),
 ('Sell','SELL',(-23,-97,12),1.2)]:player_guides.append(text(name,body,loc,size))
for name,body,loc,size in [
 ('MineTop','72 x 72\nEMPTY OPENING',(0,0,2),4),('WeaponsTop','WEAPONS',(-20,-54,12),1.55),
 ('UpgradesTop','UPGRADES',(20,-54,12),1.5),('SellTop','SELL',(-23,-97,12),1.8),
 ('CoreTop','CORE\nSPACE',(23,-97,3),1.6),('AFKTop','5 AFK PADS',(56,-35,4),1.6),
 ('BoardsTop','4 BOARDS >',(-57,-51,12),1.8),('SpawnTop','SPAWN / PLAZA',(0,-81,2),1.25)]:top_guides.append(text(name,body,loc,size,True))
bpy.data.objects['ReviewOnly_Leaderboards'].rotation_euler=(math.pi/2,0,math.pi/2)
# Audit every art mesh's world bounding box for intrusion into the mine opening.
bpy.context.view_layer.update()
intruders=[]
for o in root.all_objects:
    if o.type!='MESH':continue
    coords=[o.matrix_world@Vector(v) for v in o.bound_box]
    xmin,xmax=min(v.x for v in coords),max(v.x for v in coords)
    ymin,ymax=min(v.y for v in coords),max(v.y for v in coords)
    if xmin<36-1e-5 and xmax>-36+1e-5 and ymin<36-1e-5 and ymax>-36+1e-5:intruders.append(o.name)
assert not intruders,intruders
required=['LobbyGround','Paths','BoundaryWalls','TreesAndDecorations','WeaponStore','UpgradeStore','SellStore','Stabilizer','AFK_1x','AFK_1_5x','AFK_3x','AFK_5x','AFK_8x']
assert all(name in models for name in required)
assert sum(name.startswith('AFK_') for name in models)==5
# Presentation contains no character mesh, no shaft, no underground floor.
group('Presentation')
world=bpy.data.worlds.new('Stage1 sky');world.use_nodes=True;scene.world=world
bg=next(n for n in world.node_tree.nodes if n.type=='BACKGROUND');bg.inputs['Color'].default_value=(.4,.65,.9,1);bg.inputs['Strength'].default_value=.8
bpy.ops.object.light_add(type='SUN',location=(0,-80,80));sun=move_obj(bpy.context.object,'Sun',None);sun.data.energy=1.6;sun.data.angle=.09;sun.rotation_euler=(.3,-.45,-.2)
def cam(name,loc,target,lens=22,ortho=None):
    bpy.ops.object.camera_add(location=loc);o=move_obj(bpy.context.object,name,None);o.rotation_euler=(Vector(target)-o.location).to_track_quat('-Z','Y').to_euler();o.data.lens=lens;o.data.clip_end=1000
    if ortho:o.data.type='ORTHO';o.data.ortho_scale=ortho
    return o
# Normal eye-height view from south approach plus a view from inside the plaza.
spawn_cam=cam('PlayerHeightSpawn',(0,-115,5.5),(0,-55,5.5),lens=15)
plaza_cam=cam('PlayerHeightPlaza',(0,-85,5.5),(18,-54,5.5),lens=16)
top_cam=cam('Overhead',(0,-30,190),(0,-30,0),ortho=215)
# Direct downward camera should keep north at the top.
top_cam.rotation_euler=(0,0,0)
scene.view_settings.view_transform='Standard'
try:scene.render.engine='CYCLES'
except TypeError:pass
scene.cycles.samples=24
scene.render.resolution_percentage=100
for o in top_guides:o.hide_render=True
for camera,filename in [(spawn_cam,'player-height-spawn.png'),(plaza_cam,'player-height-plaza.png')]:
    scene.camera=camera;scene.render.resolution_x=1800;scene.render.resolution_y=1000;scene.render.filepath=str(OUT/filename);bpy.ops.render.render(write_still=True)
for o in player_guides:o.hide_render=True
for o in top_guides:o.hide_render=False
scene.camera=top_cam;scene.render.resolution_x=1800;scene.render.resolution_y=1800;scene.render.filepath=str(OUT/'overhead-layout.png');bpy.ops.render.render(write_still=True)
for o in top_guides:o.hide_render=True
# Keep readable player labels in editable Blender view only.
for o in player_guides:o.hide_render=False
scene.camera=spawn_cam
for a in bpy.context.screen.areas:
    if a.type=='VIEW_3D':
        a.spaces.active.clip_end=1000;r=a.spaces.active.region_3d;r.view_location=(0,-30,0);r.view_distance=210;r.view_rotation=top_cam.rotation_euler.to_quaternion();r.view_perspective='ORTHO';a.spaces.active.shading.type='MATERIAL'
scene['Stage']='1 - layout placeholders only. Await user feedback before details or full export.'
scene['MineAudit']='PASS: no art mesh overlaps the 72x72 opening. No shaft/floor/ore geometry.'
scene['ReviewLabels']='Editable font guides only. Exclude ReviewGuides from any export. Roblox signs authored separately.'
(OUT/'layout-manifest.json').write_text(json.dumps(manifest,indent=2))
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'EnergyCoreMining-Stage1.blend'))
print('STAGE 1 COMPLETE. Mine intrusion audit PASS. 5 AFK groups. 3 separate Counters. 1 CoreMount. No full-lobby export. Awaiting layout feedback.')
