jade = require 'jade'
sysPath = require 'path'
fs = require 'fs'
umd = require 'umd-wrapper'

require '../vendor/runtime.js'

module.exports = class JadeCompiler
  brunchPlugin: yes
  type: 'template'
  extension: 'jade'
  _dependencyRegExp: /^ *(?:include|extends) (.*)/

  constructor: (@config) ->
    return

  compile: (data, path, callback) ->
    try
        modelPath = "#{process.cwd()}/#{path}.coffee"
        delete require.cache[modelPath]
        model = require modelPath
    catch e
        if e.code == 'MODULE_NOT_FOUND' and e.message.indexOf(modelPath) >= 0
            # that's ok
        else
            return callback e
    isClient = data.indexOf('//- client=true -//') >= 0
    try
        compiled = jade.compile data,
            compileDebug: no,
            client: yes,
            filename: path,
            path: @config.paths.app,
            pretty: !!@config.plugins?.jade?.pretty
        if isClient
            result = umd compiled
            return callback null, result
        else
            bit = do => for wpath in @config.paths.watched
                return path.substring wpath.length if path.indexOf(wpath + '/') == 0
            bit = bit.replace '.jade', '.html'
            outputTo = @config.paths.public + bit
            doWrite = (err, m) ->
                if err
                    return callback err
                else
                    try
                        output = compiled m
                        writeFile outputTo, output, (err) ->
                            callback err, umd -> output
                    catch oerr
                        return callback oerr
            if model then model doWrite else doWrite null, {}
    catch err
        callback err

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

    # add modelPath as dep
    modelPath = "#{path}.coffee"
    if fs.existsSync "#{process.cwd()}/#{modelPath}"
        dependencies.push modelPath

    process.nextTick =>
      callback null, dependencies

mkdirp = (path) ->
    return if path == '.'
    parent = sysPath.dirname path
    mkdirp parent
    try
        fs.mkdirSync path, '0755'
    catch err
        throw err if err.code != 'EEXIST'

writeFile = (path, data, callback) ->
  write = (callback) -> fs.writeFile path, data, callback
  write (error) ->
    return callback null, path, data unless error?
    mkdirp (sysPath.dirname path)
    write (error) ->
      callback error, path, data
