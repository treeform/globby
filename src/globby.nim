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

proc globMatchOne(s, glob: string): bool =
  ## Match a single entry string to glob.

  proc error() =
    raise newException(GlobbyError, "Invalid Glob pattern: `" & glob & "`")

  var
    i = 0
    j = 0
  while j < glob.len:
    if glob[j] == '?':
      discard
    elif glob[j] == '*':
      while true:
        if j == glob.len - 1: # At the end
          return true
        elif glob[j+1] == '*':
          inc j
        else:
          break
      for k in i ..< s.len:
        if globMatchOne(s[k..^1], glob[(j+1)..^1]):
          i = k - 1
          return true
      return false

    elif glob[j] == '[':
      inc j
      if j < glob.len and glob[j] == ']': error()
      if j + 3 < glob.len and glob[j + 1] == '-' and glob[j + 3] == ']':
        # Do [A-z] style match.
        if s[i].ord < glob[j].ord or s[i].ord > glob[j+2].ord:
          return false
        j += 3
      else:
        # Do [ABC] style match.
        while true:
          if j >= glob.len: error()
          elif glob[j] == s[i]:
            while glob[j] != ']':
              if j + 1 >= glob.len: error()
              inc j
            break
          elif glob[j] == '[': error()
          elif glob[j] == ']':
            return false
          inc j
    elif i >= s.len:
      return false
    elif glob[j] != s[i]:
      return false
    inc i
    inc j

  if i == s.len and j == glob.len:
    return true

proc globSimplify(globArr: seq[string]): seq[string] =
  ## Simplify backwards ".." and absolute "//".
  for glob in globArr:
    if glob == "..":
      if result.len > 0:
        discard result.pop()
    elif glob == "":
      result.setLen(0)
    else:
      result.add glob

proc globMatch(sArr, globArr: seq[string]): bool =
  ## Match a seq string to a seq glob pattern.
  var
    globArr = globSimplify(globArr)
    i = 0
    j = 0
  while i < sArr.len and j < globArr.len:
    if globArr[j] == "*":
      discard
    elif globArr[j] == "**":
      if j == globArr.len - 1: # At the end
        return true
      for k in i ..< sArr.len:
        if globMatch(sArr[k..^1], globArr[(j+1)..^1]):
          i = k - 1
          return true
      return false
    else:
      if not globMatchOne(sArr[i], globArr[j]):
        return false
    inc i
    inc j

  if i == sArr.len and j == globArr.len:
    return true

proc del*[T](tree: GlobTree[T], path: string, data: T) =
  ## Delete a specific path and value from the tree.
  for i, entry in tree.data:
    if entry.path == path and entry.data == data:
      tree.data.del(i)
      return

proc del*[T](tree: GlobTree[T], glob: string) =
  ## Delete all paths from the tree that match the glob.
  var i = 0
  while i < tree.data.len:
    let entry = tree.data[i]
    if entry.parts.globMatch(glob.split('/')):
      tree.data.del(i)
      continue
    inc i

iterator findAll*[T](tree: GlobTree[T], glob: string): T =
  ## Find all the values that match the glob.
  for entry in tree.data:
    if entry.parts.globMatch(glob.split('/')):
      yield entry.data

iterator paths*[T](tree: GlobTree[T]): string =
  ## Iterate all of the paths in the tree.
  for entry in tree.data:
    yield entry.path

proc globMatch*(path, glob: string): bool =
  ## Match a path to a glob pattern.
  globMatch(path.split('/'), glob.split('/'))
