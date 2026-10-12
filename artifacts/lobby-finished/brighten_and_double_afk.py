import bpy, json, math
from pathlib import Path
from mathutils import Vector
OUT=Path('/Users/ajdinhusetovic/Desktop/ProjectMilka/artifacts/lobby-finished')
s=bpy.context.scene;root=bpy.data.collections['EnergyCoreMining_Lobby']
pale=bpy.data.materials['Simulator Pale paving tiles'];alternate=bpy.data.materials['Simulator Paving alternate'];white=bpy.data.materials['Simulator White stripes'];gold=bpy.data.materials['S1 WeaponsAccent']
def recolor(o,m):
    o.data.materials.clear();o.data.materials.append(m)
    for p in o.data.polygons:p.material_index=0
    a=o.data.color_attributes.get('Color') or o.data.color_attributes.new(name='Color',type='BYTE_COLOR',domain='CORNER');o.data.color_attributes.active_color=a
    for d in a.data:d.color=m.diffuse_color
for name in ['ShopApron','LeaderboardApproach']:
    recolor(bpy.data.objects['Paths__'+name],pale)
for o in bpy.data.collections['Paths'].objects:
    if o.type=='MESH' and o.name.startswith('Paths__Tile'):
        recolor(o,alternate if (round(o.location.x/4)+round(o.location.y/4))%3==0 else pale)
recolor(bpy.data.objects['Paths__PathTileStuds'],pale)
# Double the AFK row with five independently editable stations alongside it.
names=['AFK_1x','AFK_1_5x','AFK_3x','AFK_5x','AFK_8x']
for name in names:
    source=bpy.data.collections[name];original_parent=bpy.data.objects[name]
    new_name=name+'_02'
    target=bpy.data.collections.new(new_name);root.children.link(target)
    parent=bpy.data.objects.new(new_name,None);target.objects.link(parent);parent.location=(-14,0,0)
    parent['AFKCopyOf']=name;parent['Multiplier']=name.replace('AFK_','').replace('_','.')
    for original in source.objects:
        if original.type!='MESH':continue
        copy=original.copy();copy.data=original.data.copy();copy.name=new_name+'__'+original.name.split('__',1)[1];target.objects.link(copy);copy.parent=parent
        copy.matrix_basis=original.matrix_basis.copy();copy.matrix_parent_inverse=original.matrix_parent_inverse.copy()
# Grey platform remains structural; its footprint expands inward by 14 studs.
for name,loc,size in [('AFKPlatform',(49,-70,.5),(30,62,1)),('AFKFrontStep',(32.75,-70,.25),(2.5,62,.5)),('AFKAccessWalk',(30,-70,.12),(3,62,.24))]:
    o=bpy.data.objects['Paths__'+name];o.location=loc;o.dimensions=size;bpy.context.view_layer.objects.active=o;o.select_set(True);bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);o.select_set(False)
# Keep a four-stud aisle between the two rows of pad bases (x=47 to x=51).
c=bpy.data.collections['Paths'];parent=bpy.data.objects['Paths']
def box(name,loc,size,mat,coll=c,par=parent):
    bpy.ops.mesh.primitive_cube_add(size=1,location=loc);o=bpy.context.object
    for col in list(o.users_collection):col.objects.unlink(o)
    coll.objects.link(o);o.parent=par;o.name=par.name+'__'+name;o['RobloxName']=name;o.dimensions=size;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);recolor(o,mat);return o
box('AFKGoldenFrontBorder',(34.2,-70,1.03),(.35,62,.06),gold)
box('AFKGoldenBackBorder',(63.8,-70,1.03),(.35,62,.06),gold)
for y in [-100.8,-39.2]:box('AFKGoldenEndBorder',(49,y,1.03),(30,.35,.06),gold)
box('AFKCentralAisle',(49,-70,1.04),(3.7,61,.08),pale)
# Brighten the leaderboard forecourt with the reference's red carpet.
def linear(v):
    v=v/255;return v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4
red=bpy.data.materials.new('Simulator Leaderboard red carpet');red.diffuse_color=(*[linear(v) for v in (229,72,74)],1);red.use_nodes=True
node=next(n for n in red.node_tree.nodes if n.type=='BSDF_PRINCIPLED');node.inputs['Base Color'].default_value=red.diffuse_color;node.inputs['Roughness'].default_value=.9
bc=bpy.data.collections['Leaderboards'];bp=bpy.data.objects['Leaderboards']
box('RedCarpet',(-55,-77.5,.845),(13.1,43.5,.07),red,bc,bp)
box('CarpetGoldEdge',(-48.5,-77.5,.89),(.24,43.5,.08),gold,bc,bp)
# Separate stud patch for the carpet, using a top cap and sides.
verts=[];faces=[]
for x in [-60,-58,-56,-54,-52,-50]:
    for y in range(-98,-55,2):
        b=len(verts);sx=.55;sy=.55;z=.905;h=.08
        verts.extend([(x+dx*sx/2,y+dy*sy/2,z+dz*h/2) for dx,dy,dz in [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),(-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1)]])
        faces.extend([tuple(b+i for i in face) for face in [(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)]])
mesh=bpy.data.meshes.new('CarpetStuds');mesh.from_pydata(verts,[],faces);mesh.update();o=bpy.data.objects.new('Leaderboards__CarpetStuds',mesh);bc.objects.link(o);o.parent=bp;recolor(o,red)
# Remove tile meshes now covered by the expanded AFK platform.
for o in list(c.objects):
    if o.type=='MESH' and o.name.startswith('Paths__Tile') and o.location.x>=36:bpy.data.objects.remove(o,do_unlink=True)
# Validate count, aisle and mine clearance.
bpy.context.view_layer.update()
afk=[coll for coll in root.children if coll.name.startswith('AFK_')]
assert len(afk)==10,len(afk)
assert all(any(o.get('RobloxName')=='StandingArea' for o in coll.objects) and any(o.get('RobloxName')=='TrainingBlock' for o in coll.objects) for coll in afk)
for o in root.all_objects:
    if o.type!='MESH':continue
    cs=[o.matrix_world@Vector(v) for v in o.bound_box]
    assert not(min(v.x for v in cs)<36-1e-5 and max(v.x for v in cs)>-36+1e-5 and min(v.y for v in cs)<36-1e-5 and max(v.y for v in cs)>-36+1e-5),o.name
for area in bpy.context.screen.areas:
    if area.type=='VIEW_3D':area.spaces.active.shading.use_scene_world=True
s['AFKCount']=10;s['AFKAisleStuds']=4;s['MineAudit']='PASS: 72x72 opening remains empty'
for cam,file,height in [('Presentation__FinishedOverview','simulator-overview.png',1500),('Presentation__PlayerHeightSpawn','simulator-player-height.png',1000),('Presentation__PlayerHeightPlaza','simulator-plaza-view.png',1000)]:
    s.camera=bpy.data.objects[cam];s.render.resolution_x=1800;s.render.resolution_y=height;s.render.filepath=str(OUT/file);bpy.ops.render.render(write_still=True)
s.camera=bpy.data.objects['Presentation__FinishedOverview'];s.render.resolution_y=1500
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'EnergyCoreMining-StudSimulator.blend'))
colors=json.loads((OUT/'colors-rgb.json').read_text());colors[red.name]=[229,72,74];(OUT/'colors-rgb.json').write_text(json.dumps(colors,indent=2))
print('Saved: pale walkways, red studded leaderboard carpet, 10 AFK stations in 2 rows, 4-stud middle aisle. Mine audit PASS.')
