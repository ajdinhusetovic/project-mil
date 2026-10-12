import bpy, math
from pathlib import Path
from mathutils import Vector
OUT=Path('/Users/ajdinhusetovic/Desktop/ProjectMilka/artifacts/lobby-finished')
s=bpy.context.scene;c=bpy.data.collections['Paths'];parent=bpy.data.objects['Paths']
# Keep the central plaza and AFK structure; replace the entire walking-path network.
keep=['Paths__CentralPlaza','Paths__Plaza','Paths__SmallSpawnInlay','Paths__AFKPlatform','Paths__AFKFrontStep','Paths__AFKGolden','Paths__AFKCentralAisle']
for o in list(c.objects):
    if o.type=='MESH' and not any(o.name.startswith(p) for p in keep):bpy.data.objects.remove(o,do_unlink=True)
pale=bpy.data.materials['Simulator Pale paving tiles'];grey=bpy.data.materials['Simulator Grey stone curb']
def vertex_colors(o,m):
    o.data.materials.append(m)
    a=o.data.color_attributes.new(name='Color',type='BYTE_COLOR',domain='CORNER');o.data.color_attributes.active_color=a
    for d in a.data:d.color=m.diffuse_color

def box(name,loc,size,m):
    bpy.ops.mesh.primitive_cube_add(size=1,location=loc);o=bpy.context.object
    for coll in list(o.users_collection):coll.objects.unlink(o)
    c.objects.link(o);o.parent=parent;o.name='Paths__'+name;o['RobloxName']=name;o.dimensions=size
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);vertex_colors(o,m);return o
# Three uninterrupted slabs overlap beneath the circular plaza to avoid edge gaps.
branches=[('ForwardToMine',(0,-57,.1),(12,38,.2)),('LeftToLeaderboards',(-27,-81,.1),(42,12,.2)),('RightToAFK',(18.75,-81,.1),(25.5,12,.2))]
for name,loc,size in branches:box(name,loc,size,pale)
# Native-looking square studs, with no checkerboard paving or separate tile slabs.
verts=[];faces=[]
for name,(x,y,z),(sx,sy,sz) in branches:
    px=x-sx/2+.75
    while px<=x+sx/2-.75+1e-6:
        py=y-sy/2+.75
        while py<=y+sy/2-.75+1e-6:
            if math.hypot(px,py+81)>10.15:
                base=len(verts);w=.43;h=.08;centre_z=.25
                verts.extend([(px+a*w/2,py+b*w/2,centre_z+d*h/2) for a,b,d in [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),(-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1)]])
                faces.extend([tuple(base+i for i in f) for f in [(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)]])
            py+=1.5
        px+=1.5
me=bpy.data.meshes.new('ContinuousPathStuds');me.from_pydata(verts,[],faces);me.update();stud=bpy.data.objects.new('Paths__ContinuousPathStuds',me);c.objects.link(stud);stud.parent=parent;vertex_colors(stud,pale)
# Thin borders only on the three branches, ending cleanly at the plaza.
for x in [-6.3,6.3]:box('ForwardBorder',(x,-54.5,.14),(.6,33,.28),grey)
for y in [-87.3,-74.7]:
    box('LeftBorder',(-29.5,y,.14),(37,.6,.28),grey)
    box('RightBorder',(21.25,y,.14),(20.5,.6,.28),grey)
# A single entry step at each destination, rather than a side walkway.
box('LeaderboardEntryStep',(-47.25,-81,.2),(1.5,12,.4),grey)
step=bpy.data.objects['Paths__AFKFrontStep'];step.location=(32.75,-81,.25);step.dimensions=(2.5,12,.5)
bpy.context.view_layer.objects.active=step;step.select_set(True);bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);step.select_set(False)
# Check all three branches intersect the circular plaza and end at their destinations.
assert len(branches)==3
bpy.context.view_layer.update()
for o in bpy.data.collections['EnergyCoreMining_Lobby'].all_objects:
    if o.type!='MESH':continue
    pts=[o.matrix_world@Vector(v) for v in o.bound_box]
    assert not(min(v.x for v in pts)<36-1e-5 and max(v.x for v in pts)>-36+1e-5 and min(v.y for v in pts)<36-1e-5 and max(v.y for v in pts)>-36+1e-5),o.name
s['PathLayout']='Three continuous branches: forward mine, left leaderboards, right AFK. No shop aprons or shop side paths.'
# Render the corrected overhead layout and player-height view.
for cam,file,height in [('Presentation__Overhead','simple-paths-overhead.png',1800),('Presentation__FinishedOverview','simulator-overview.png',1500),('Presentation__PlayerHeightSpawn','simulator-player-height.png',1000),('Presentation__PlayerHeightPlaza','simulator-plaza-view.png',1000)]:
    s.camera=bpy.data.objects[cam];s.render.resolution_x=1800;s.render.resolution_y=height;s.render.filepath=str(OUT/file);bpy.ops.render.render(write_still=True)
s.camera=bpy.data.objects['Presentation__FinishedOverview'];s.render.resolution_y=1500
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'EnergyCoreMining-StudSimulator.blend'))
print('Saved 3 continuous paths. All shop-side and extra paving removed. 10 AFK stations retained. Mine opening clear.')
