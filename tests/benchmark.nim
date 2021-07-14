import benchy, globby, random

randomize()

proc addPart(path: var string) =
  for i in 0 ..< rand(1..10):
    let c = rand('a'.char..'z'.char)
    path.add(c.char)
  path.add("/")
  if rand(1..100) <= 90:
    addPart(path)
  else:
    path.setLen(path.high)

var paths = newSeq[string]()
for i in 0 ..< 1000:
  var path = ""
  addPart(path)
  paths.add(path)

let tree = GlobTree[int]()

for i, path in paths:
  tree.add(path, i)

timeIt "findAll":
  var count: int
  for path in tree.findAll(paths[rand(0..paths.high)]):
    inc count
  doAssert count > 0

timeIt "findAll **":
  var count: int
  for path in tree.findAll("**"):
    inc count
  doAssert count > 0
