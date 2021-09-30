# Globby - Glob pattern matching for Nim.

`nimble install globby`

![Github Actions](https://github.com/treeform/globby/workflows/Github%20Actions/badge.svg)

[API reference](https://nimdocs.com/treeform/globby)

This library has no dependencies other than the Nim standard libarary.

## About

This allows you to create a data structure that you can then access using globs. This library is being actively developed and we'd be happy for you to use it.

## Supported patterns:

Done | Format            | Example         |
-- | ----------------- | --------------- |
✅ | Star              | `foo*`          |
✅ | Single Character  | `foo??`         |
✅ | Character Set     | `foo[abs]`      |
✅ | Character Range   | `foo[a-z]`      |
✅ | Star Path         | `foo/*/bar`     |
✅ | Double Star Path  | `foo/**/bar`    |
✅ | Root Path         | `/foo/bar`      |
✅ | Relative Path     | `../foo/bar`    |

## Example:

```nim
import globby, sequtils

var tree = GlobTree[int]()

tree.add("foo/bar/baz", 0)
tree.add("foo/bar/baz/1", 1)
tree.add("foo/bar/baz/2", 2)
tree.add("foo/bar/baz/z", 3)
tree.add("foo/bar/baz/z", 4)

assert toSeq(tree.findAll("foo/bar/baz/z"))[0] == 3
```
