import bpy, json
from pathlib import Path
from mathutils import Vector
out=Path(r'C:\Users\huske\Desktop\project-mil\artifacts\lobby-crossroads')
original=bpy.context.window.scene
check=bpy.data.scenes.new('Crossroads FBX validation temporary')
bpy.context.window.scene=check
try:
 bpy.ops.import_scene.fbx(filepath=str(out/'EnergyCore-SpawnCrossroads.fbx'))
 meshes=[o for o in check.objects if o.type=='MESH']
 assert len(meshes)>600,len(meshes)
 assert all(o.data.color_attributes for o in meshes),'Missing vertex colors'
 assert not any('Guide' in o.name or 'FacingArrow' in o.name or 'preview floor' in o.name for o in check.objects),'Planning geometry leaked into export'
 shaft=[o for o in meshes if 'shaft' in o.name]
 assert len(shaft)==4,len(shaft)
 assert all(abs(max(o.dimensions)-720)<.01 for o in shaft),'Shaft scale changed'
 afk=[o for o in meshes if o.name.startswith('AFK_') and '_Foundation' in o.name]
 boards=[o for o in meshes if o.name.startswith('Leaderboard_') and '_Foundation' in o.name]
 assert len(afk)==10 and len(boards)==4
 spawn=Vector((0,0,0));mine=next(o for o in meshes if o.name.startswith('V3 Mine bedrock'))
 forward=Vector((mine.matrix_world.translation.x,mine.matrix_world.translation.y,0))
 # FBX imported back to Blender restores Z-up, +Y forward coordinates.
 assert forward.y>200 and abs(forward.x)<.01
 assert all(o.matrix_world.translation.x<0 for o in afk)
 assert all(o.matrix_world.translation.x>0 for o in boards)
 report={'status':'PASS','roundtrip_mesh_count':len(meshes),'vertex_colors':'present on every mesh','afk_foundations':len(afk),'leaderboard_foundations':len(boards),'shaft_wall_count':len(shaft),'shaft_depth':720,'planning_geometry_exported':False,'orientation':'Mine +Y; AFK left (-X); leaderboards right (+X)'}
 (out/'export-validation.json').write_text(json.dumps(report,indent=2))
 print(json.dumps(report))
finally:
 bpy.context.window.scene=original
 for ob in list(check.objects):bpy.data.objects.remove(ob,do_unlink=True)
 bpy.data.scenes.remove(check)
