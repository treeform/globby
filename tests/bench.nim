import benchy, globby, random, strutils

randomize(2021)

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

timeIt "findAll", 10000:
  var count: int
  for path in tree.findAll(paths[rand(0..paths.high)]):
    inc count
  doAssert count > 0

timeIt "findAll **", 10000:
  var count: int
  for path in tree.findAll("**"):
    inc count
  doAssert count > 0

timeIt "findAll **/..", 10000:
  var path: string
  while true:
    path = paths[rand(0..paths.high)]
    if path.contains('/'):
      break

  let glob = "**/" & path[path.find('/') + 1 .. ^1]

  var count: int
  for path in tree.findAll(glob):
    inc count
  doAssert count > 0

timeIt "findAll */..", 10000:
  var path: string
  while true:
    path = paths[rand(0..paths.high)]
    if path.contains('/'):
      break

  let glob = "*/" & path[path.find('/') + 1 .. ^1]

  var count: int
  for path in tree.findAll(glob):
    inc count
  doAssert count > 0

timeIt "findAll ../*/..", 10000:
  var path: string
  while true:
    path = paths[rand(0..paths.high)]
    if path.count('/') >= 2:
      break

  let
    firstSlash = path.find('/')
    secondSlash = firstSlash + 1 + path[firstSlash + 1 .. ^1].find('/')

  let glob = path[0 ..< firstSlash] & "/*/" & path[secondSlash + 1 .. ^1]

  var count: int
  for path in tree.findAll(glob):
    inc count
  doAssert count > 0

timeIt "del", 10000:
  tree.del(paths[rand(0..paths.high)])
