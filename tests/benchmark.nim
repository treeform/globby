import benchy, globby, random

randomize()

proc maybeAddPart(path: var string) =
  for i in 0 ..< rand(1..10):
    let c = rand(0..25) + 97 # ASCII
    path.add(c.char)
  path.add("/")
  if rand(1..100) <= 90:
    maybeAddPart(path)
  else:
    path.setLen(path.high)

var paths = newSeq[string]()
for i in 0 ..< 1000:
  var path = ""
  maybeAddPart(path)
  paths.add(path)

let tree = GlobTree[int]()

for i, path in paths:
  tree.add(path, i)

timeIt "findAll":
  var count: int
  for path in tree.findAll(paths[rand(0..paths.high)]):
    inc count
  doAssert count > 0
