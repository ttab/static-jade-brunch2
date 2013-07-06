## static-jade-brunch
Adds static HTML [Jade](http://jade-lang.com) support to
[brunch](http://brunch.io).

Not to be confused with "the other" static-jade-brunch

## Usage
Install the plugin via npm with `npm install --save static-jade-brunch2`.

Or, do manual install:

* Add `"static-jade-brunch2": "x.y.z"` to `package.json` of your brunch app.
  Pick a plugin version that corresponds to your minor (y) brunch version.
* If you want to use git version of plugin, add
`"static-jade-brunch": "git+ssh://git@github.com:ttab/static-jade-brunch.git"`.

## Special Client Side Usage ##

This plugin compiles static .html-files into `public` by default. It is however possible
to make client side jade-templates by including the "special" token `//- client=true -//`
somewhere in the file. Example:

```
//- client=true -//
!!! 5
html
    head
        meta(charset='utf-8' )
        meta(http-equiv='X-UA-Compatible', content='IE=edge,chrome=1')
        title UI
        link(rel='stylesheet', href='/stylesheets/app.css')
    body
        block content
        script(src='/javascripts/vendor.js')
        script(src='/javascripts/app.js')
```

Such files are not generated individually to the `public` but can still be relied upon
for `extend` for server side static pages.

## License

The MIT License (MIT)

Copyright (c) 2012-2013 Paul Miller (http://paulmillr.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
