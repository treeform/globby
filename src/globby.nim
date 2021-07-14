import strutils

type
  GlobbyError* = object of ValueError

  GlobEntry[T] = object
    path: string
    parts: seq[string] ## The path parts (path split on '/').
    data: T

  GlobTree*[T] = ref object
    data: seq[GlobEntry[T]]

proc len*[T](tree: GlobTree[T]): int =
  ## Return number of paths in the tree.
  tree.data.len

proc add*[T](tree: GlobTree[T], path: string, data: T) =
  ## Add a path to the tree. Can contain multiple entries for the same path.
  if path == "":
    raise newException(GlobbyError, "Path cannot be an empty string")
  let parts = path.split('/')
  for part in parts:
    if part == "":
      raise newException(GlobbyError, "Path cannot contain // or a trailing /")
    if part.contains({'*', '?', '[', ']'}):
      raise newException(GlobbyError, "Path cannot contain *, ?, [ or ]")
  tree.data.add(GlobEntry[T](
    path: path,
    parts: parts,
    data: data
  ))

proc globMatchOne(path, glob: string, pathStart = 0, globStart = 0): bool =
  ## Match a single entry string to glob.

  proc error() =
    raise newException(GlobbyError, "Invalid glob: `" & glob & "`")

  var
    i = pathStart
    j = globStart
  while j < glob.len:
    if glob[j] == '?':
      discard
    elif glob[j] == '*':
      while true:
        if j == glob.len - 1: # At the end
          return true
        elif glob[j + 1] == '*':
          inc j
        else:
          break
      for k in i ..< path.len:
        if globMatchOne(path, glob, k, j + 1):
          i = k - 1
          return true
      return false
    elif glob[j] == '[':
      inc j
      if j < glob.len and glob[j] == ']': error()
      if j + 3 < glob.len and glob[j + 1] == '-' and glob[j + 3] == ']':
        # Do [A-z] style match.
        if path[i].ord < glob[j].ord or path[i].ord > glob[j + 2].ord:
          return false
        j += 3
      else:
        # Do [ABC] style match.
        while true:
          if j >= glob.len: error()
          elif glob[j] == path[i]:
            while glob[j] != ']':
              if j + 1 >= glob.len: error()
              inc j
            break
          elif glob[j] == '[': error()
          elif glob[j] == ']':
            return false
          inc j
    elif i >= path.len:
      return false
    elif glob[j] != path[i]:
      return false
    inc i
    inc j

  if i == path.len and j == glob.len:
    return true

proc globMatch(
  pathParts, globParts: seq[string], pathStart = 0, globStart = 0
): bool =
  ## Match a seq string to a seq glob pattern.
  var
    i = pathStart
    j = globStart
  while i < pathParts.len and j < globParts.len:
    if globParts[j] == "*":
      discard
    elif globParts[j] == "**":
      if j == globParts.len - 1: # At the end
        return true
      for k in i ..< pathParts.len:
        if globMatch(pathParts, globParts, k, j + 1):
          i = k - 1
          return true
      return false
    else:
      if not globMatchOne(pathParts[i], globParts[j]):
        return false
    inc i
    inc j

  if i == pathParts.len and j == globParts.len:
    return true

proc globSimplify(globParts: seq[string]): seq[string] =
  ## Simplify backwards ".." and absolute "//".
  for globPart in globParts:
    if globPart == "..":
      if result.len > 0:
        discard result.pop()
    elif globPart == "":
      result.setLen(0)
    else:
      result.add globPart

proc del*[T](tree: GlobTree[T], path: string, data: T) =
  ## Delete a specific path and value from the tree.
  for i, entry in tree.data:
    if entry.path == path and entry.data == data:
      tree.data.del(i)
      return

proc del*[T](tree: GlobTree[T], glob: string) =
  ## Delete all paths from the tree that match the glob.
  let globParts = glob.split('/').globSimplify()
  var i = 0
  while i < tree.data.len:
    let entry = tree.data[i]
    if entry.parts.globMatch(globParts):
      tree.data.del(i)
      continue
    inc i

iterator findAll*[T](tree: GlobTree[T], glob: string): T =
  ## Find all the values that match the glob.
  let globParts = glob.split('/').globSimplify()
  for entry in tree.data:
    if entry.parts.globMatch(globParts):
      yield entry.data

iterator paths*[T](tree: GlobTree[T]): string =
  ## Iterate all of the paths in the tree.
  for entry in tree.data:
    yield entry.path

proc globMatch*(path, glob: string): bool =
  ## Match a path to a glob pattern.
  globMatch(path.split('/'), glob.split('/').globSimplify())
