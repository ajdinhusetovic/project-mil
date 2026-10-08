-- Edit mode only. Measure the rock island inside each imported crystal mesh once.
-- Saved attributes let clients use the results without EditableMesh at runtime.
task.spawn(function()
for _, name in {"ChargedQuartz", "Quartz", "Ion"} do
 local model = game.ReplicatedStorage.BlockModels[name]
 local part = model:FindFirstChildWhichIsA("MeshPart", true)
 local mesh = game:GetService("AssetService"):CreateEditableMeshAsync(part.MeshContent)
 assert(mesh, "Could not measure " .. name)
 local parent, points, equivalent = {}, {}, {}
 local lo, hi = Vector3.new(math.huge,math.huge,math.huge), Vector3.new(-math.huge,-math.huge,-math.huge)
 local function minimum(a,b) return Vector3.new(math.min(a.X,b.X),math.min(a.Y,b.Y),math.min(a.Z,b.Z)) end
 local function maximum(a,b) return Vector3.new(math.max(a.X,b.X),math.max(a.Y,b.Y),math.max(a.Z,b.Z)) end
 local function root(id)
  while parent[id] ~= id do parent[id] = parent[parent[id]]; id = parent[id] end
  return id
 end
 local function join(a,b) parent[root(a)] = root(b) end
 for _, id in mesh:GetVertices() do
  local p = mesh:GetPosition(id)
  points[id], parent[id] = p, id
  lo, hi = minimum(lo,p), maximum(hi,p)
  local key = string.format("%.3f,%.3f,%.3f",p.X,p.Y,p.Z)
  if equivalent[key] then join(id,equivalent[key]) else equivalent[key]=id end
 end
 for _, id in mesh:GetFaces() do
  local v = mesh:GetFaceVertices(id)
  for i=2,#v do join(v[1],v[i]) end
 end
 local groups = {}
 for id,p in points do
  local key=root(id)
  local g=groups[key]
  if not g then g={Lo=p,Hi=p}; groups[key]=g end
  g.Lo,g.Hi=minimum(g.Lo,p),maximum(g.Hi,p)
 end
 local best,volume
 for _,g in groups do
  local size=g.Hi-g.Lo
  local v=size.X*size.Y*size.Z
  if not volume or v>volume then best,volume=g,v end
 end
 local bodySize=best.Hi-best.Lo
 assert(bodySize.X>190 and bodySize.X<210 and bodySize.Y>190 and bodySize.Y<210 and bodySize.Z>190 and bodySize.Z<210,"Unexpected rock body in "..name..": "..tostring(bodySize))
 local localCenter=(best.Hi+best.Lo)/2-(hi+lo)/2
 local ratio=part.Size/part.MeshSize
 local bounds=model:GetBoundingBox()
 local offset=bounds:PointToObjectSpace(part.CFrame:PointToWorldSpace(localCenter*ratio))
 model:SetAttribute("MiningBodySize",bodySize*ratio)
 model:SetAttribute("MiningBodyOffset",offset)
 print("MEASURED ROCK BODY",name,bodySize*ratio,offset)
 mesh:Destroy()
end
print("BLOCK BODY CALIBRATION PASSED")
end)
