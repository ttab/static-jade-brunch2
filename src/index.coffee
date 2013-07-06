jade = require 'jade'
sysPath = require 'path'
fs = require 'fs'

module.exports = class JadeCompiler
  brunchPlugin: yes
  type: 'template'
  extension: 'jade'
  _dependencyRegExp: /^ *(?:include|extends) (.*)/

  constructor: (@config) ->
    return

  compile: (data, path, callback) ->
    isClient = data.indexOf('//- client=true -//') >= 0
    try
      content = jade.compile data,
        compileDebug: no,
        client: yes,
        filename: path,
        path: @config.paths.app,
        pretty: !!@config.plugins?.jade?.pretty
      if isClient
        result = "module.exports = #{content};"
      else
        [_, bit] = path.match /.*\/(.*)\.jade/
        outputTo = @config.paths.public + '/' + bit + '.html'
        result = null
        output = content({})
        writeFile outputTo, output, (err) -> console.error err if err
    catch err
      error = err
    finally
      callback error, result

  # Add '../node_modules/jade/jade.js' to vendor files.
  include: [
    (sysPath.join __dirname, '..', 'vendor', 'runtime.js')
  ]

  getDependencies: (data, path, callback) =>
    parent = sysPath.dirname path
    dependencies = data
      .split('\n')
      .map (line) =>
        line.match(@_dependencyRegExp)
      .filter (match) =>
        match?.length > 0
      .map (match) =>
        match[1]
      .filter (path) =>
        !!path
      .map (path) =>
        if sysPath.extname(path) isnt ".#{@extension}"
          path + ".#{@extension}"
        else
          path
      .map (path) =>
        if path.charAt(0) is '/'
          sysPath.join @config.paths.root, path[1..]
        else
          sysPath.join parent, path
    process.nextTick =>
      callback null, dependencies

mkdirp = (path) ->
    return if path == '.'
    parent = sysPath.dirname path
    mkdirp parent
    fs.mkdirSync path, '0755'

writeFile = (path, data, callback) ->
  write = (callback) -> fs.writeFile path, data, callback
  write (error) ->
    return callback null, path, data unless error?
    mkdirp (sysPath.dirname path)
    write (error) ->
      callback error, path, data
