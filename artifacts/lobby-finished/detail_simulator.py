import bpy, math, random, json
from pathlib import Path
from mathutils import Vector
OUT=Path('/Users/ajdinhusetovic/Desktop/ProjectMilka/artifacts/lobby-finished')
random.seed(51)
s=bpy.context.scene
assert s.name.startswith('Energy Core Mining - Stage 1 Layout')
s.name='Energy Core Mining - Stud Simulator'
root=bpy.data.collections['Stage1_Lobby'];root.name='EnergyCoreMining_Lobby'
def lin(v):
    v=v/255;return v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4
palette={}
for m in bpy.data.materials:
    if m.name.startswith('S1 '):
        palette[m.name]=m

def material(name,rgb):
    m=bpy.data.materials.new('Simulator '+name);m.diffuse_color=(*[lin(v) for v in rgb],1);m.use_nodes=True
    n=next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED');n.inputs['Base Color'].default_value=m.diffuse_color;n.inputs['Roughness'].default_value=.86
    return m
white=material('White stripes',(250,251,248));orange=material('Orange stripes',(255,143,19));wood=material('Warm booth wood',(218,132,52));woodlite=material('Wood trim',(235,155,70));stone=material('Pale paving tiles',(220,220,175));stone2=material('Paving alternate',(210,213,166));curb=material('Grey stone curb',(138,153,166));dark=material('Leaderboard panel',(42,49,54));rock=material('Small grey rocks',(155,165,160));blade=material('Grass tufts',(44,181,27));flowergold=material('Flower centres',(255,212,39))
for key,rgb in [('Grass',(75,235,26)),('WallOrange',(248,132,33)),('WallTop',(63,221,24))]:
    m=bpy.data.materials['S1 '+key];m.diffuse_color=(*[lin(v) for v in rgb],1);n=next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED');n.inputs['Base Color'].default_value=m.diffuse_color
for o in bpy.data.collections['WeaponStore'].objects[:]:
    if o.type=='MESH' and 'S1 Wood' in [m.name for m in o.data.materials]:o.data.materials[0]=wood
for name in ['UpgradeStore','SellStore','TreesAndDecorations','BoundaryWalls','MineEntrance']:
    for o in bpy.data.collections[name].objects:
        if o.type=='MESH' and o.data.materials and o.data.materials[0].name=='S1 Wood':o.data.materials[0]=wood

def collection(name):return bpy.data.collections[name],bpy.data.objects[name]
def obj_link(o,name,coll,parent,mat):
    o.name=parent.name+'__'+name
    for c in list(o.users_collection):c.objects.unlink(o)
    coll.objects.link(o);o.parent=parent
    if mat:o.data.materials.append(mat)
    o['RobloxName']=name
    return o

def box(name,loc,size,coll,parent,mat,bevel=0):
    bpy.ops.mesh.primitive_cube_add(size=1,location=loc);o=obj_link(bpy.context.object,name,coll,parent,mat);o.dimensions=size
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    if bevel:
        b=o.modifiers.new('Tiny block edge','BEVEL');b.width=bevel;b.segments=1
        o.modifiers.new('Weighted normal','WEIGHTED_NORMAL')
    return o
# Mesh stud patches are separate objects per surface, not a joined map.
def cubes_mesh(name,items,coll,parent,mat):
    verts=[];faces=[]
    # Each boss omits the invisible underside.
    corners=[(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),(-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1)]
    for centre,size in items:
        base=len(verts)
        verts.extend([(centre[0]+a*size[0]/2,centre[1]+b*size[1]/2,centre[2]+c*size[2]/2) for a,b,c in corners])
        faces.extend([tuple(base+i for i in f) for f in [(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)]])
    if not verts:return None
    mesh=bpy.data.meshes.new(name);mesh.from_pydata(verts,[],faces);mesh.update()
    o=bpy.data.objects.new(name,mesh);coll.objects.link(o);o.name=parent.name+'__'+name;o.parent=parent;o.data.materials.append(mat);o['RobloxName']=name
    return o

def values(lo,hi,step,inset):
    p=lo+inset
    while p<=hi-inset+1e-5:
        yield p;p+=step

def studs_surface(name,centre,size,face,coll,parent,mat,step=1.8,w=.63,h=.12):
    x,y,z=centre;sx,sy,sz=size;items=[]
    if face=='top':
        for a in values(x-sx/2,x+sx/2,step,.7):
            for b in values(y-sy/2,y+sy/2,step,.7):items.append(((a,b,z+sz/2+h/2),(w,w,h)))
    elif face in ['left','right']:
        dx=(-1 if face=='left' else 1)*(sx/2+h/2)
        for a in values(y-sy/2,y+sy/2,step,.7):
            for b in values(z-sz/2,z+sz/2,step,.7):items.append(((x+dx,a,b),(h,w,w)))
    elif face in ['front','back']:
        dy=(-1 if face=='front' else 1)*(sy/2+h/2)
        for a in values(x-sx/2,x+sx/2,step,.7):
            for b in values(z-sz/2,z+sz/2,step,.7):items.append(((a,y+dy,b),(w,h,w)))
    return cubes_mesh(name,items,coll,parent,mat)
# Studded grass follows the original four hole-free slabs.
coll,parent=collection('LobbyGround')
for o in list(coll.objects):
    if o.type=='MESH':studs_surface(o['RobloxName']+'Studs',tuple(o.location),tuple(o.dimensions),'top',coll,parent,o.data.materials[0],2,.65,.1)
# Raised square wall studs face into the arena.
coll,parent=collection('BoundaryWalls')
for o in list(coll.objects):
    if o.type!='MESH':continue
    n=o['RobloxName']
    if 'GreenCap' in n:studs_surface(n+'Studs',tuple(o.location),tuple(o.dimensions),'top',coll,parent,o.data.materials[0],1.8,.63,.12)
    elif n.startswith('SideWall'):studs_surface(n+'Studs',tuple(o.location),tuple(o.dimensions),'right' if o.location.x<0 else 'left',coll,parent,o.data.materials[0],1.8,.63,.14)
    elif n=='NorthWall':studs_surface(n+'Studs',tuple(o.location),tuple(o.dimensions),'front',coll,parent,o.data.materials[0],1.8,.63,.14)
    elif n.startswith('FrontWall'):studs_surface(n+'Studs',tuple(o.location),tuple(o.dimensions),'back',coll,parent,o.data.materials[0],1.8,.63,.14)
# Tile all existing paths while retaining their exact footprint and access routes.
coll,parent=collection('Paths')
path_objects=[bpy.data.objects['Paths__'+n] for n in ['MainPath','CrossPath','ShopApron','SellApproach','StabilizerApproach','LeaderboardApproach','AFKAccessWalk']]
rects=[(o.location.x-o.dimensions.x/2,o.location.x+o.dimensions.x/2,o.location.y-o.dimensions.y/2,o.location.y+o.dimensions.y/2) for o in path_objects]
tile_studs=[]
for x in range(-72,73,4):
    for y in range(-114,-35,4):
        if not any(a+1.9<=x<=b-1.9 and c+1.9<=y<=d-1.9 for a,b,c,d in rects):continue
        if math.hypot(x,y+81)<12.6:continue
        # Grey accents on vendor and leaderboard aprons; pale tiles on main routes.
        m=curb if (-69<=y<=-59 and -30<=x<=30) or (-48<=x<=-38 and -100<=y<=-55) else (stone if (x//4+y//4)%3 else stone2)
        box('Tile', (x,y,.28),(3.84,3.84,.1),coll,parent,m,.025)
        for dx in [-1.2,0,1.2]:
            for dy in [-1.2,0,1.2]:tile_studs.append(((x+dx,y+dy,.375),(.43,.43,.085)))
cubes_mesh('PathTileStuds',tile_studs,coll,parent,stone)
# Border the main avenue, leaving intersections and plaza approaches open.
for x in [-6.35,6.35]:
    for lo,hi in [(-116,-94),(-69,-38)]:box('MainPathCurb',(x,(lo+hi)/2,.2),(.7,hi-lo,.4),coll,parent,curb,.045)
for y in [-87.35,-74.65]:
    for lo,hi in [(-48,-11.5),(11.5,40.5)]:box('CrossPathCurb',((lo+hi)/2,y,.19),(hi-lo,.65,.38),coll,parent,curb,.035)
# Thin rings define the circular plaza; no obstructions in its centre.
def annulus(name,x,y,z,r1,r2,mat,coll,parent,n=48):
    vs=[];fs=[]
    for r in [r1,r2]:
        for i in range(n):vs.append((x+r*math.cos(2*math.pi*i/n),y+r*math.sin(2*math.pi*i/n),z))
    for i in range(n):j=(i+1)%n;fs.append((i,j,n+j,n+i))
    me=bpy.data.meshes.new(name);me.from_pydata(vs,[],fs);me.update();o=bpy.data.objects.new(name,me);coll.objects.link(o);o.parent=parent;o.data.materials.append(mat);o.name=parent.name+'__'+name;return o
annulus('PlazaBorder',0,-81,.36,9.5,10.5,curb,coll,parent)
annulus('PlazaFineInnerRing',0,-81,.365,8.9,9.04,woodlite,coll,parent)
# A modest star inlay inspired by the simple simulator spawn motif.
vs=[(0,-81,.37)]
for i in range(16):
    r=2.2 if i%2==0 else .7;a=2*math.pi*i/16;vs.append((r*math.cos(a),-81+r*math.sin(a),.37))
fs=[(0,i+1,((i+1)%16)+1) for i in range(16)]
me=bpy.data.meshes.new('SmallSpawnInlay');me.from_pydata(vs,[],fs);o=bpy.data.objects.new('Paths__SmallSpawnInlay',me);coll.objects.link(o);o.parent=parent;me.materials.append(curb)
plaza_studs=[]
for x in values(-9,9,1.6,.2):
    for dy in values(-9,9,1.6,.2):
        if 2.8<math.hypot(x,dy)<8.8:plaza_studs.append(((x,-81+dy,.395),(.43,.43,.085)))
cubes_mesh('PlazaStuds',plaza_studs,coll,parent,stone)
# Booths: stripe strips, counter tops, framed wooden panels, small recognizable wares.
for name,color in [('WeaponStore',bpy.data.materials['S1 WeaponsAccent']),('UpgradeStore',bpy.data.materials['S1 UpgradeAccent']),('SellStore',bpy.data.materials['S1 SellAccent'])]:
    coll,parent=collection(name)
    roof=bpy.data.objects[name+'__RoofPlaceholder'];bpy.data.objects.remove(roof,do_unlink=True)
    for i in range(5):
        stripmat=(orange if i%2==0 else color) if name=='WeaponStore' else (color if i%2==0 else white)
        o=box('RoofStripe'+str(i),(-5.8+2.9*i,0,9.9),(2.9,12,.6),coll,parent,stripmat,.035)
        studs_surface('RoofStripeStuds'+str(i),tuple(o.location),tuple(o.dimensions),'top',coll,parent,stripmat,1.5,.52,.1)
    box('RoofFrontFascia',(0,-6,9.55),(14.5,.35,.5),coll,parent,woodlite,.035)
    box('CounterTop',(0,-4.3,3.96),(12.2,2,.22),coll,parent,woodlite,.05)
    for z in [.75,2.95]:box('CounterWoodRail'+str(z),(0,-5.075,z),(11.7,.18,.18),coll,parent,woodlite,.025)
    for x in [-3.7,0,3.7]:box('CounterPanelDivider'+str(x),(x,-5.09,1.85),(.16,.15,2.25),coll,parent,woodlite,.02)
    for dx in [-6.1,6.1]:
        box('PostFoot'+str(dx),(dx,-4.5,.4),(1.1,1.1,.8),coll,parent,woodlite,.04)
        studs_surface('SideWallStuds'+str(dx),(dx,0,1.65),(.7,9.5,3),'left' if dx<0 else 'right',coll,parent,wood,1.5,.48,.1)
    studs_surface('CounterStuds',(0,-4.3,2),(11.5,1.5,3.6),'front',coll,parent,wood,1.5,.48,.1)
    box('BackPanelFrame',(0,4.3,5),(7,.14,3.8),coll,parent,woodlite)
    box('BlankBackPanel',(0,4.20,5),(6.6,.12,3.4),coll,parent,wood)
    sign=bpy.data.objects[name+'__SignBlank'];sign['RobloxName']='SignPanel';sign.name=name+'__SignPanel'
    if name=='WeaponStore':
        box('SmallGunDisplay',(-3.5,-4.3,4.6),(3,.75,.8),coll,parent,dark,.035)
        box('SmallGunCyanTip',(-5,-4.3,4.6),(.45,.85,.85),coll,parent,bpy.data.materials['S1 Cyan'],.025)
        box('SmallGunGrip',(-2.6,-4.3,4.25),(.55,.55,.7),coll,parent,wood,.025)
    elif name=='UpgradeStore':
        box('BagDisplay',(3,-4.3,4.8),(1.5,1,1.6),coll,parent,color,.08)
        box('BagDisplayPocket',(3,-4.85,4.5),(1,.14,.6),coll,parent,woodlite,.02)
        box('BagDisplayHandle',(3,-4.3,5.7),(.65,.4,.2),coll,parent,dark)
    else:
        for i in range(3):box('CashStack'+str(i),(-3+i*1.2,-4.3,4.22),(1,.65,.3+i*.1),coll,parent,color)
# AFK stations retain exact footprint, with small studded cubes and standing tiles.
for name in ['AFK_1x','AFK_1_5x','AFK_3x','AFK_5x','AFK_8x']:
    coll,parent=collection(name)
    area=bpy.data.objects[name+'__StandingArea'];cube=bpy.data.objects[name+'__TrainingBlock']
    for face in ['top','front','right','left','back']:studs_surface('TrainingBlockStuds'+face,tuple(cube.location),tuple(cube.dimensions),face,coll,parent,cube.data.materials[0],.8,.28,.075)
    studs_surface('StandingAreaStuds',tuple(area.location),tuple(area.dimensions),'top',coll,parent,area.data.materials[0],1.1,.42,.08)
    mount=bpy.data.objects[name+'__TrainingBlockMount'];mount.data.materials[0]=woodlite
    x,y,z=area.location
    box('StandingOutlineA',(x-2.42,y,1.44),(.18,8,.1),coll,parent,white)
    box('StandingOutlineB',(x+2.42,y,1.44),(.18,8,.1),coll,parent,white)
# Small, simple core pedestal rather than elaborate machinery.
coll,parent=collection('Stabilizer')
box('CorePedestalBaseTrim',(23,-97,.43),(4.5,4.5,.35),coll,parent,curb,.06)
for dx in [-1.25,1.25]:box('CoreMountEdgeX',(23+dx,-97,2.01),(.3,2.8,.12),coll,parent,bpy.data.materials['S1 WeaponsAccent'])
for dy in [-1.25,1.25]:box('CoreMountEdgeY',(23,-97+dy,2.01),(2.2,.3,.12),coll,parent,bpy.data.materials['S1 WeaponsAccent'])
box('SmallCoreConsole',(23,-99.55,.8),(2.2,1,.9),coll,parent,curb,.045)
box('SmallCoreConsoleAccent',(23,-100.07,.95),(1.3,.08,.3),coll,parent,bpy.data.materials['S1 Cyan'])
# Leaderboards remain right-facing. Blank inset surfaces are ready for editable Roblox signs.
coll,parent=collection('Leaderboards')
for i,(name,color) in enumerate([('MostLevels',bpy.data.materials['S1 Cyan']),('MostMoney',bpy.data.materials['S1 SellAccent']),('MostDamage',orange),('MostRebirths',bpy.data.materials['S1 UpgradeAccent'])]):
    y=-94+i*11
    existing=bpy.data.objects['Leaderboards__'+name+'BoardPlaceholder'];existing.data.materials[0]=wood
    panel=box(name+'DisplaySurface',(-61.62,y,5.8),(.1,8.7,9.9),coll,parent,dark)
    panel['LeaderboardCategory']=name
    box(name+'HeaderAccent',(-61.54,y,10.3),(.1,8.5,1.3),coll,parent,color)
    for row in range(5):box(name+'RowInset'+str(row),(-61.53,y,8.75-row*1.6),(.08,8.3,1.4),coll,parent,dark if row%2==0 else curb)
    for edge in [-4.55,4.55]:box(name+'FrameSide',(-61.50,y+edge,5.8),(.25,.3,10.7),coll,parent,woodlite)
    box(name+'BoardFoot',(-62,y,.62),(1.8,10,.42),coll,parent,woodlite)
# Trees get a second square tier and studded leaves, staying at the original positions.
coll,parent=collection('TreesAndDecorations')
for i in range(8):
    crown=bpy.data.objects['TreesAndDecorations__Tree'+str(i)+'Crown'];x,y,z=crown.location;crown.dimensions=(6.5,6.5,4);crown.location.z=7
    bpy.context.view_layer.objects.active=crown;crown.select_set(True);bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);crown.select_set(False)
    upper=box('Tree'+str(i)+'UpperCrown',(x,y,10.4),(4.4,4.4,2.8),coll,parent,bpy.data.materials['S1 WallTop'])
    for tier in [crown,upper]:
        for face in ['top','front','back','left','right']:studs_surface(tier['RobloxName']+'Studs'+face,tuple(tier.location),tuple(tier.dimensions),face,coll,parent,tier.data.materials[0],1.4,.5,.12)
# Flower and grass clusters sit off the walking surfaces and at tree bases.
spots=[(-68,-90),(-68,-79),(-67,-57),(-47,-104),(-35,-107),(-11,-101),(11,-102),(37,-105),(69,-102),(69,-84),(69,-60),(67,-44),(-35,-45),(35,-45),(-55,40),(51,41),(-18,49),(19,49),(-67,8),(66,12)]
for idx,(x,y) in enumerate(spots):
    for j in range(3):
        px=x+random.uniform(-1.1,1.1);py=y+random.uniform(-1.1,1.1)
        box('GrassTuft'+str(idx)+'_'+str(j),(px,py,.48),(.25,.7,.9),coll,parent,blade)
        box('GrassTuftCross'+str(idx)+'_'+str(j),(px,py,.36),(.7,.25,.65),coll,parent,blade)
    if idx%2==0:
        fx=x+1.5;fy=y+.7
        box('FlowerStem'+str(idx),(fx,fy,.5),(.13,.13,1),coll,parent,blade)
        box('FlowerCentre'+str(idx),(fx,fy,1.05),(.3,.3,.18),coll,parent,flowergold)
        fm=white if idx%4==0 else bpy.data.materials['S1 Pink']
        for dx,dy in [(-.3,0),(.3,0),(0,-.3),(0,.3)]:box('FlowerPetal'+str(idx),(fx+dx,fy+dy,1.01),(.3,.3,.16),coll,parent,fm)
    if idx in [0,4,8,14,16]:
        for j in range(2):
            bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1,radius=.65,location=(x-1.5+j,y-1,.35));o=obj_link(bpy.context.object,'SmallRock'+str(idx)+'_'+str(j),coll,parent,rock);o.scale=(1,.8,.55);bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
# Add flat vertex colors; all objects remain separate and transforms are applied locally.
for o in root.all_objects:
    if o.type!='MESH' or not o.data.materials:continue
    a=o.data.color_attributes.get('Color') or o.data.color_attributes.new(name='Color',type='BYTE_COLOR',domain='CORNER');o.data.color_attributes.active_color=a
    for face in o.data.polygons:
        color=o.data.materials[face.material_index].diffuse_color
        for idx in face.loop_indices:a.data[idx].color=color
# Remove stage-review text clutter from the live viewport and renders.
bpy.data.collections['ReviewGuides'].hide_viewport=True;bpy.data.collections['ReviewGuides'].hide_render=True
for a in bpy.context.screen.areas:
    if a.type=='VIEW_3D':
        a.spaces.active.overlay.show_relationship_lines=False
        a.spaces.active.overlay.show_extras=False
        a.spaces.active.overlay.show_floor=False
        a.spaces.active.overlay.show_axis_x=False;a.spaces.active.overlay.show_axis_y=False
        a.spaces.active.shading.type='MATERIAL'
# Recheck empty mine after all studs and decorations.
bpy.context.view_layer.update()
bad=[]
for o in root.all_objects:
    if o.type!='MESH':continue
    coords=[o.matrix_world@Vector(v) for v in o.bound_box]
    if min(v.x for v in coords)<36-1e-5 and max(v.x for v in coords)>-36+1e-5 and min(v.y for v in coords)<36-1e-5 and max(v.y for v in coords)>-36+1e-5:bad.append(o.name)
assert not bad,bad
# Render normal player height and a clean elevated review angle.
presentation=bpy.data.collections['Presentation'];p=bpy.data.objects['Presentation']
bpy.ops.object.camera_add(location=(104,-192,143));overview=bpy.context.object
for c in list(overview.users_collection):c.objects.unlink(overview)
presentation.objects.link(overview);overview.parent=p;overview.name='Presentation__FinishedOverview';overview.rotation_euler=(Vector((0,-30,0))-overview.location).to_track_quat('-Z','Y').to_euler();overview.data.type='ORTHO';overview.data.ortho_scale=223;overview.data.clip_end=1000
s.cycles.samples=32;s.render.resolution_x=1800;s.render.resolution_y=1500;s.render.resolution_percentage=100;s.camera=overview;s.render.filepath=str(OUT/'simulator-overview.png');bpy.ops.render.render(write_still=True)
s.camera=bpy.data.objects['Presentation__PlayerHeightSpawn'];s.render.resolution_y=1000;s.render.filepath=str(OUT/'simulator-player-height.png');bpy.ops.render.render(write_still=True)
s.camera=bpy.data.objects['Presentation__PlayerHeightPlaza'];s.render.filepath=str(OUT/'simulator-plaza-view.png');bpy.ops.render.render(write_still=True)
s.camera=overview;s.render.resolution_y=1500;s.render.filepath=str(OUT/'simulator-overview.png')
for a in bpy.context.screen.areas:
    if a.type=='VIEW_3D':
        r=a.spaces.active.region_3d;r.view_location=(0,-32,0);r.view_distance=220;r.view_rotation=overview.rotation_euler.to_quaternion();r.view_perspective='ORTHO'
s['Stage']='Simulator detail pass requested by user; original layout retained.'
s['MineAudit']='PASS: all mesh bounding boxes outside 72 x 72 opening. No underground meshes.'
s['ExportStatus']='Full export pending verified Roblox scale test. Do not export ReviewGuides or Presentation.'
# Supply the precise sRGB colors used by the flat shader palette.
rgb={}
for o in root.all_objects:
    if o.type!='MESH':continue
    for m in o.data.materials:
        a=[round((12.92*c if c<=.0031308 else 1.055*c**(1/2.4)-.055)*255) for c in m.diffuse_color[:3]];rgb[m.name]=a
(OUT/'colors-rgb.json').write_text(json.dumps(rgb,indent=2))
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'EnergyCoreMining-StudSimulator.blend'))
print('DETAIL PASS COMPLETE:',sum(o.type=='MESH' for o in root.all_objects),'separate mesh objects. Physical studs, tiled paths, striped roofs, trees, flowers and grass clusters. Mine audit PASS.')
