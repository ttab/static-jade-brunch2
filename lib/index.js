// Generated by CoffeeScript 1.7.1
var JadeCompiler, fs, jade, mkdirp, sysPath, umd, writeFile,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

jade = require('jade');

sysPath = require('path');

fs = require('fs');

umd = require('umd-wrapper');

require('../vendor/runtime.js');

module.exports = JadeCompiler = (function() {
  JadeCompiler.prototype.brunchPlugin = true;

  JadeCompiler.prototype.type = 'template';

  JadeCompiler.prototype.extension = 'jade';

  JadeCompiler.prototype._dependencyRegExp = /^ *(?:include|extends) (.*)/;

  function JadeCompiler(config) {
    this.config = config;
    this.getDependencies = __bind(this.getDependencies, this);
    return;
  }

  JadeCompiler.prototype.compile = function(data, path, callback) {
    var bit, compiled, doWrite, e, err, isClient, model, modelPath, outputTo, result, _ref, _ref1;
    try {
      modelPath = "" + (process.cwd()) + "/" + path + ".coffee";
      delete require.cache[modelPath];
      model = require(modelPath);
    } catch (_error) {
      e = _error;
      if (e.code === 'MODULE_NOT_FOUND' && e.message.indexOf(modelPath) >= 0) {

      } else {
        return callback(e);
      }
    }
    isClient = data.indexOf('//- client=true -//') >= 0;
    try {
      compiled = jade.compile(data, {
        compileDebug: false,
        client: true,
        filename: path,
        path: this.config.paths.app,
        pretty: !!((_ref = this.config.plugins) != null ? (_ref1 = _ref.jade) != null ? _ref1.pretty : void 0 : void 0)
      });
      if (isClient) {
        result = umd(compiled);
        return callback(null, result);
      } else {
        bit = (function(_this) {
          return function() {
            var wpath, _i, _len, _ref2;
            _ref2 = _this.config.paths.watched;
            for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
              wpath = _ref2[_i];
              if (path.indexOf(wpath + '/') === 0) {
                return path.substring(wpath.length);
              }
            }
          };
        })(this)();
        bit = bit.replace('.jade', '.html');
        outputTo = this.config.paths["public"] + bit;
        doWrite = function(err, m) {
          var oerr, output;
          if (err) {
            return callback(err);
          } else {
            try {
              output = compiled(m);
              return writeFile(outputTo, output, function(err) {
                return callback(err, umd(function() {
                  return output;
                }));
              });
            } catch (_error) {
              oerr = _error;
              return callback(oerr);
            }
          }
        };
        if (model) {
          return model(doWrite);
        } else {
          return doWrite(null, {});
        }
      }
    } catch (_error) {
      err = _error;
      return callback(err);
    }
  };

  JadeCompiler.prototype.include = [sysPath.join(__dirname, '..', 'vendor', 'runtime.js')];

  JadeCompiler.prototype.getDependencies = function(data, path, callback) {
    var dependencies, modelPath, parent;
    parent = sysPath.dirname(path);
    dependencies = data.split('\n').map((function(_this) {
      return function(line) {
        return line.match(_this._dependencyRegExp);
      };
    })(this)).filter((function(_this) {
      return function(match) {
        return (match != null ? match.length : void 0) > 0;
      };
    })(this)).map((function(_this) {
      return function(match) {
        return match[1];
      };
    })(this)).filter((function(_this) {
      return function(path) {
        return !!path;
      };
    })(this)).map((function(_this) {
      return function(path) {
        if (sysPath.extname(path) !== ("." + _this.extension)) {
          return path + ("." + _this.extension);
        } else {
          return path;
        }
      };
    })(this)).map((function(_this) {
      return function(path) {
        if (path.charAt(0) === '/') {
          return sysPath.join(_this.config.paths.root, path.slice(1));
        } else {
          return sysPath.join(parent, path);
        }
      };
    })(this));
    modelPath = "" + path + ".coffee";
    if (fs.existsSync("" + (process.cwd()) + "/" + modelPath)) {
      dependencies.push(modelPath);
    }
    return process.nextTick((function(_this) {
      return function() {
        return callback(null, dependencies);
      };
    })(this));
  };

  return JadeCompiler;

})();

mkdirp = function(path) {
  var err, parent;
  if (path === '.') {
    return;
  }
  parent = sysPath.dirname(path);
  mkdirp(parent);
  try {
    return fs.mkdirSync(path, '0755');
  } catch (_error) {
    err = _error;
    if (err.code !== 'EEXIST') {
      throw err;
    }
  }
};

writeFile = function(path, data, callback) {
  var write;
  write = function(callback) {
    return fs.writeFile(path, data, callback);
  };
  return write(function(error) {
    if (error == null) {
      return callback(null, path, data);
    }
    mkdirp(sysPath.dirname(path));
    return write(function(error) {
      return callback(error, path, data);
    });
  });
};
