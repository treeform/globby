import globby, sequtils

doAssert globMatch("foo", "foo") == true
doAssert globMatch("foo", "foz") == false
doAssert globMatch("foo", "fo?") == true
doAssert globMatch("foo", "f??") == true
doAssert globMatch("foo", "???") == true
doAssert globMatch("fooo", "fo?") == false

doAssert globMatch("foo", "fo*") == true
doAssert globMatch("foo", "foo*") == true
doAssert globMatch("fooo", "fo*") == true
doAssert globMatch("fooo", "f*???") == true

doAssert globMatch("foobarbaz", "f*z") == true
doAssert globMatch("foobarbaz", "foo*baz") == true
doAssert globMatch("foobarbaz", "*baz") == true
doAssert globMatch("foobarbaz", "f*b*z") == true
doAssert globMatch("foobarbaz", "f*b?z") == true
doAssert globMatch("foobarbaz", "f*b????z") == true

doAssert globMatch("foobarbaz", "f*b*g") == false
doAssert globMatch("foobarbaz", "*g") == false
doAssert globMatch("foobarbaz", "z*z") == false

doAssert globMatch("foo", "f[o]o") == true
doAssert globMatch("foo", "f[ophjkl]o") == true
doAssert globMatch("foo", "f[phjklo]o") == true
doAssert globMatch("foo", "f[phjkl]o") == false

doAssertRaises GlobbyError:
  discard globMatch("foo", "f[phjklo")

doAssertRaises GlobbyError:
  discard globMatch("foo", "f[]")

doAssertRaises GlobbyError:
  discard globMatch("foo", "f[[]")

doAssert globMatch("foo", "f[a-z]o") == true
doAssert globMatch("foo5", "foo[0-9]") == true
doAssert globMatch("fooA", "foo[0-9]") == false
doAssert globMatch("fooA", "foo[A-Z]") == true
doAssert globMatch("fooa", "foo[A-Z]") == false

doAssertRaises GlobbyError:
  discard globMatch("foo", "f[a-")

doAssertRaises GlobbyError:
  discard globMatch("foo", "f[a-z")

doAssert globMatch("foo/bar", "foo/bar") == true
doAssert globMatch("foz/bar", "foo/bar") == false
doAssert globMatch("foo/bar", "foo/baz") == false

doAssert globMatch("foo/bar/baz", "foo/bar/*") == true
doAssert globMatch("foo/bar/baz", "foo/*/baz") == true
doAssert globMatch("foo/bar/baz", "*/bar/baz") == true
doAssert globMatch("foo/baz/baz", "foo/bar/*") == false
doAssert globMatch("foo/baz/baz", "foz/*/bar") == false
doAssert globMatch("foo/baz/baz", "*/bar/baz") == false

doAssert globMatch("foo/bar/baz/1", "**/1") == true
doAssert globMatch("foo/bar/baz/1", "**/baz/1") == true
doAssert globMatch("foo/bar/baz/1", "**/bar/baz/1") == true
doAssert globMatch("foo/bar/baz/1", "foo/**/baz/1") == true
doAssert globMatch("foo/bar/baz/1", "foo/**/1") == true
doAssert globMatch("foo/bar/baz/2", "foo/**/baz/1") == false

doAssert globMatch("foo/bar/baz", "foo/bar/baz/**") == false
doAssert globMatch("foo/bar/baz", "foo/bar/baz**") == true
doAssert globMatch("foo/bar/baz/1", "foo/bar/baz/**") == true
doAssert globMatch("foo/bar/baz/1", "foo/bar/**") == true
doAssert globMatch("foo/bar/baz/1", "foo/**") == true
doAssert globMatch("foo/bar/baz/1", "**") == true

doAssert globMatch("foo/bar/baz/at1", "**/*/???/at*") == true
doAssert globMatch("foo/bar/baz/at1", "**/*/baz/at*") == true
doAssert globMatch("foo/bar/baz/at1", "foo/*/???/at*") == true
doAssert globMatch("foo/bar/baz/at1", "**/bar*/???/at*") == true

doAssert globMatch("foo/bar", "foo/bar.text") == false

doAssert globMatch("foo/bar", "foo/bar/../bar") == true
doAssert globMatch("foo/bar", "foo/zzz/../bar") == true
doAssert globMatch("foo/bar/baz", "foo/bar/../bar/baz") == true
doAssert globMatch("foo/bar/baz", "foo/zzz/../bar/baz") == true
doAssert globMatch("foo", "foo/bar/../../foo") == true
doAssert globMatch("foo", "foo/zzz/../../foo") == true

doAssert globMatch("foo/bar", "z//foo/bar") == true
doAssert globMatch("foo/bar", "z/x//foo/bar") == true
doAssert globMatch("foo/bar/baz", "foo/bar//foo/bar/baz") == true
doAssert globMatch("foo/bar/baz", "foo/zzz//foo/bar/baz") == true
doAssert globMatch("foo", "foo/bar/baz//foo") == true
doAssert globMatch("foo", "z/x/y//foo") == true

var tree = GlobTree[int]()

tree.add("foo/bar/baz", 0)
tree.add("foo/bar/baz/1", 1)
tree.add("foo/bar/baz/2", 2)

tree.del("foo/bar/baz")

doAssert tree.len == 2

# Ensure insertion order is maintained after delete
doAssert toSeq(tree.findAll("foo/bar/baz/*")) == @[1, 2]

tree.add("foo/bar/baz", 0)
tree.add("foo/bar/baz/z", 3)
tree.add("foo/bar/baz/z", 4)

doAssert tree.len == 5

doAssert toSeq(tree.findAll("")).len == 0
doAssert toSeq(tree.findAll("foo/bar/baz/z"))[0] == 3
doAssert toSeq(tree.findAll("foo/bar/baz/z")).len == 2
tree.del("foo/bar/baz/z", 3)
doAssert tree.len == 4
doAssert toSeq(tree.findAll("foo/bar/baz/z"))[0] == 4
doAssert toSeq(tree.findAll("foo/bar/baz/z")).len == 1

doAssert toSeq(tree.findAll("foo/bar/baz/1"))[0] == 1
doAssert toSeq(tree.findAll("foo/bar/*/1"))[0] == 1
doAssert toSeq(tree.findAll("foo/**/1"))[0] == 1
doAssert toSeq(tree.findAll("???/**/1"))[0] == 1

doAssert toSeq(tree.findAll("something/*")).len == 0
doAssert toSeq(tree.findAll("foo/bar/baz/*")).len == 3
doAssert toSeq(tree.findAll("foo/bar/baz/?")).len == 3
doAssert toSeq(tree.findAll("foo/bar/baz/[0-9]")).len == 2

tree.del("foo/bar/baz/*")
doAssert tree.len == 1

tree.del("something/*")
doAssert tree.len == 1

tree.del("**")
doAssert tree.len == 0

doAssertRaises GlobbyError:
  tree.add("", 0)

doAssertRaises GlobbyError:
  tree.add("//", 0)

doAssertRaises GlobbyError:
  tree.add("a//b", 0)

doAssertRaises GlobbyError:
  tree.add("a/", 0)
