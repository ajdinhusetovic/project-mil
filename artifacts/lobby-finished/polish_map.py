import bpy, math, json, random
from pathlib import Path
from mathutils import Vector
OUT=Path('/Users/ajdinhusetovic/Desktop/ProjectMilka/artifacts/lobby-finished')
s=bpy.context.scene;root=bpy.data.collections['EnergyCoreMining_Lobby']
random.seed(31)
def lin(v):
    v=v/255;return v/12.92 if v<=.04045 else ((v+.055)/1.055)**2.4
new_colors={}
def material(name,rgb):
    m=bpy.data.materials.new('Polish '+name);m.diffuse_color=(*[lin(v) for v in rgb],1);m.use_nodes=True
    n=next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED');n.inputs['Base Color'].default_value=m.diffuse_color;n.inputs['Roughness'].default_value=.87
    new_colors[m.name]=list(rgb);return m
grasses=[material('Grass tile dark',(61,216,24)),material('Grass tile light',(92,239,39)),material('Grass tile medium',(76,229,30))]
leafdark=material('Tree leaves deep',(48,200,24));leaflight=material('Tree leaves fresh',(86,235,35))
soil=material('Flowerbed soil',(133,79,33))
wood=bpy.data.materials['Simulator Wood trim'];gold=bpy.data.materials['S1 WeaponsAccent'];grey=bpy.data.materials['Simulator Grey stone curb'];white=bpy.data.materials['Simulator White stripes'];pink=bpy.data.materials['S1 Pink'];green=bpy.data.materials['Simulator Grass tufts'];yellow=bpy.data.materials['Simulator Flower centres'];dark=bpy.data.materials['Simulator Leaderboard panel']
def fill_color(o,m):
    o.data.materials.clear();o.data.materials.append(m)
    for p in o.data.polygons:p.material_index=0
    a=o.data.color_attributes.get('Color') or o.data.color_attributes.new(name='Color',type='BYTE_COLOR',domain='CORNER');o.data.color_attributes.active_color=a
    for d in a.data:d.color=m.diffuse_color

def box(name,loc,size,coll,parent,mat,bevel=0):
    bpy.ops.mesh.primitive_cube_add(size=1,location=loc);o=bpy.context.object
    for c in list(o.users_collection):c.objects.unlink(o)
    coll.objects.link(o);o.parent=parent;o.name=parent.name+'__'+name;o['RobloxName']=name;o.dimensions=size
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True);fill_color(o,mat)
    if bevel:
        b=o.modifiers.new('Small edge polish','BEVEL');b.width=bevel;b.segments=1;o.modifiers.new('Clean corner normals','WEIGHTED_NORMAL')
    return o

def shade(col,row):
    # Clear alternating patches with occasional middle greens, rather than noisy random pixels.
    if (col*7+row*11)%13==0:return grasses[2]
    return grasses[(col+row)%2]
# Each grass tile and its studs can be edited independently. Grass top stays Z=0.
c=bpy.data.collections['LobbyGround'];p=bpy.data.objects['LobbyGround']
slabs=[bpy.data.objects['LobbyGround__'+n] for n in ['HubGround','WestGround','EastGround','NorthGround']]
tiles={}
for slab in slabs:
    x,y,_=slab.location;sx,sy,sz=slab.dimensions;xmin=x-sx/2;xmax=x+sx/2;ymin=y-sy/2;ymax=y+sy/2
    slab.location.z=-1.04
    for col in range(math.floor(xmin/12),math.ceil(xmax/12)):
        for row in range(math.floor(ymin/12),math.ceil(ymax/12)):
            a=max(xmin,col*12);b=min(xmax,(col+1)*12);d=max(ymin,row*12);e=min(ymax,(row+1)*12)
            if b-a<.01 or e-d<.01:continue
            key=(col,row);m=shade(*key)
            o=box('GrassTile_'+str(col)+'_'+str(row),((a+b)/2,(d+e)/2,-.02),(b-a,e-d,.04),c,p,m)
            o['TileSizeStuds']=12;o['GrassVariant']=m.name;tiles[key]=o
# Split stud geometry per tile, making the patches manageable for later Roblox import.
patches={}
old_studs=[o for o in c.objects if o.type=='MESH' and o.name.endswith('GroundStuds')]
for original in old_studs:
    mesh=original.data
    for offset in range(0,len(mesh.vertices),8):
        points=[tuple(v.co) for v in mesh.vertices[offset:offset+8]]
        if len(points)!=8:continue
        cx=sum(v[0] for v in points)/8;cy=sum(v[1] for v in points)/8;key=(math.floor(cx/12),math.floor(cy/12))
        verts,faces=patches.setdefault(key,([],[]));base=len(verts);verts.extend(points)
        faces.extend([tuple(base+i for i in f) for f in [(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)]])
    bpy.data.objects.remove(original,do_unlink=True)
for key,(verts,faces) in patches.items():
    me=bpy.data.meshes.new('GrassStudTile');me.from_pydata(verts,[],faces);me.update()
    o=bpy.data.objects.new('LobbyGround__GrassStudTile_'+str(key[0])+'_'+str(key[1]),me);c.objects.link(o);o.parent=p;fill_color(o,shade(*key));o['RobloxName']='GrassStudTile_'+str(key[0])+'_'+str(key[1])
    assert len(me.polygons)<800,'Grass patch is unexpectedly large'
# Fresh two-tone trees; stud layers receive the same color as their leaf cube.
c=bpy.data.collections['TreesAndDecorations'];p=bpy.data.objects['TreesAndDecorations']
for o in c.objects:
    if o.type=='MESH' and 'Tree' in o.name and 'Crown' in o.name:fill_color(o,leaflight if 'UpperCrown' in o.name else leafdark)
# Four low flower beds add a cared-for edge without placing clutter on the paths.
for i,(x,y) in enumerate([(-13,-67),(13,-67),(-54,-103.5),(68,-70)]):
    box('FlowerbedSoil'+str(i),(x,y,.2),(4.6,2.2,.4),c,p,soil)
    for dx in [-2.35,2.35]:box('FlowerbedEnd'+str(i),(x+dx,y,.32),(.18,2.6,.64),c,p,wood,.03)
    for dy in [-1.2,1.2]:box('FlowerbedSide'+str(i),(x,y+dy,.32),(4.8,.18,.64),c,p,wood,.03)
    for j in range(5):
        fx=x-1.7+j*.85;fy=y+(.36 if j%2 else -.36)
        box('BedFlowerStem'+str(i)+'_'+str(j),(fx,fy,.83),(.11,.11,.9),c,p,green)
        box('BedFlowerCentre'+str(i)+'_'+str(j),(fx,fy,1.32),(.24,.24,.16),c,p,yellow)
        m=white if (i+j)%2 else pink
        for dx,dy in [(-.23,0),(.23,0),(0,-.23),(0,.23)]:box('BedFlowerPetal'+str(i)+'_'+str(j),(fx+dx,fy+dy,1.29),(.25,.25,.12),c,p,m)
        box('BedFlowerLeaf'+str(i)+'_'+str(j),(fx+.16,fy,.9),(.35,.11,.15),c,p,green)
# Mining rim gets a narrow yellow safety strip and short dark diagonal markings.
c=bpy.data.collections['MineEntrance'];p=bpy.data.objects['MineEntrance']
for side in [-1,1]:
    box('MineSideSafetyStripe'+str(side),(side*37,0,.73),(1.8,72,.06),c,p,gold)
    box('MineEndSafetyStripe'+str(side),(0,side*37,.73),(72,1.8,.06),c,p,gold)
    for a in range(-34,35,4):
        mark=box('MineSideHazard'+str(side),(side*37,a,.775),(.6,1.6,.03),c,p,dark);mark.rotation_euler.z=math.pi/4
        mark=box('MineEndHazard'+str(side),(a,side*37,.775),(1.6,.6,.03),c,p,dark);mark.rotation_euler.z=math.pi/4
# Tiny bevels on path borders and plinth trims soften the asset without changing the layout.
for o in bpy.data.collections['Paths'].objects:
    if o.type=='MESH' and ('Border' in o.name or 'EntryStep' in o.name) and not o.modifiers:
        mod=o.modifiers.new('Clean border edges','BEVEL');mod.width=.025;mod.segments=1;o.modifiers.new('Clean border normals','WEIGHTED_NORMAL')
# Validate original constraints and the simplified path topology.
bpy.context.view_layer.update()
assert len([c for c in root.children if c.name.startswith('AFK_')])==10
assert all(bpy.data.objects.get('Paths__'+n) for n in ['ForwardToMine','LeftToLeaderboards','RightToAFK'])
assert not bpy.data.objects.get('Paths__ShopApron')
for o in root.all_objects:
    if o.type!='MESH':continue
    points=[o.matrix_world@Vector(v) for v in o.bound_box]
    assert not(min(v.x for v in points)<36-1e-5 and max(v.x for v in points)>-36+1e-5 and min(v.y for v in points)<36-1e-5 and max(v.y for v in points)>-36+1e-5),o.name
for o in slabs:assert abs(o.location.z+o.dimensions.z/2+.04)<1e-6
for o in tiles.values():assert abs(o.location.z+o.dimensions.z/2)<1e-6
s['GrassTiles']='12-stud light/dark green patches, matching square studs, individually editable tiles and stud patches.'
s['PolishAudit']='PASS: grass top Z=0; 72x72 opening clear; 10 AFK; 3 continuous paths; no shop side paving.'
s.cycles.samples=40
for cam,file,height in [('Presentation__FinishedOverview','simulator-overview.png',1500),('Presentation__Overhead','simple-paths-overhead.png',1800),('Presentation__PlayerHeightSpawn','simulator-player-height.png',1000),('Presentation__PlayerHeightPlaza','simulator-plaza-view.png',1000)]:
    s.camera=bpy.data.objects[cam];s.render.resolution_x=1800;s.render.resolution_y=height;s.render.filepath=str(OUT/file);bpy.ops.render.render(write_still=True)
s.camera=bpy.data.objects['Presentation__FinishedOverview'];s.render.resolution_y=1500;s.render.filepath=str(OUT/'simulator-overview.png')
bpy.ops.wm.save_as_mainfile(filepath=str(OUT/'EnergyCoreMining-StudSimulator.blend'))
rgb=json.loads((OUT/'colors-rgb.json').read_text());rgb.update(new_colors);(OUT/'colors-rgb.json').write_text(json.dumps(rgb,indent=2))
print('POLISH PASS SAVED:',len(tiles),'editable grass tiles;',len(patches),'matching stud patches. Two-tone trees, flower beds and mine safety trim. Mine/ground/path/AFK audits passed.')
