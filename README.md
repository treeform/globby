# Globby - Glob pattern matching for Nim.

API reference: https://nimdocs.com/treeform/globby

Supported patterns:

* Star: `foo*`
* Single Character: `foo??`
* Character Set: `foo[abs]`
* Character Range: `foo[a-z]`
* Star path: `foo/*/bar`
* Double Star path: `foo/**/bar`
* Root Path `/foo/bar`
* Relative Path `../foo/bar`
