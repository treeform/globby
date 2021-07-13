# Globby - Glob pattern matching for Nim.

This library is being actively developed and we'd be happy for you to use it.

`nimble install gobby`

![Github Actions](https://github.com/treeform/pixie/workflows/Github%20Actions/badge.svg)

## Documentation

API reference: https://nimdocs.com/treeform/globby

## Supported patterns:

done | Format            | Example         |
-- | ----------------- | --------------- |
✅ | Star              | `foo*`          |
✅ | Single Character  | `foo??`         |
✅ | Character Set     | `foo[abs]`      |
✅ | Character Range   | `foo[a-z]`      |
✅ | Star path         | `foo/*/bar`     |
✅ | Double Star path  | `foo/**/bar`    |
✅ | Root Path         | `/foo/bar`      |
✅ | Relative Path     | `../foo/bar`    |

## Example:

```nim
var tree = GlobTree[int]()

tree.add("foo/bar/baz", 0)
tree.add("foo/bar/baz/1", 1)
tree.add("foo/bar/baz/2", 2)
tree.add("foo/bar/baz/z", 3)
tree.add("foo/bar/baz/z", 4)

assert tree.find("foo/bar/baz/z") == 3
```
