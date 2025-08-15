module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    shell:
      options:
        failOnError: true
      jison:
        command: [
          'mkdir -p build/lib/src/'
          'jison src/grammar.y src/lexer.l -o build/lib/src/parser.js'
        ].join if process.platform.match /^win/ then '&' else '&&'

    jasmine_test:
      all: ['build/lib/spec/']
      options:
        specFolders: ['build/lib/spec/']
        showColors: true
        includeStackTrace: false
        forceExit: true

    # this is actually the code coverage task, but renaming it causes problems
    jasmine_node:
      coverage:
        savePath: 'demo/coverage/'
        report: ['html']
        excludes: ['build/lib/spec/*.js']
        thresholds:
          lines: 75
      all: ['build/lib/spec/']
      options:
        specFolders: ['build/lib/spec/']
        showColors: true
        includeStackTrace: false
        forceExit: true

    watch:
      files: ['src/lexer.l', 'src/grammar.y', 'src/**/*.coffee', 'spec/**/*.coffee']
      tasks: ['default']
      options:
        spawn: true
        interrupt: true
        atBegin: true
        livereload: true

    coffeelint:
      app: ['src/**/*.coffee', 'spec/**/*.coffee']
      options:
        max_line_length:
          level: 'ignore'
        line_endings:
          value: 'unix'
          level: 'error'

    coffee:
      lib:
        files: [
          expand: true         # Enable dynamic expansion.
          cwd: 'src/'          # Src matches are relative to this path.
          src: ['**/*.coffee'] # Actual pattern(s) to match.
          dest: 'build/lib/src/'         # Destination path prefix.
          ext: '.js'           # Dest filepaths will have this extension.
        ]
      specs:
        files: [
          expand: true         # Enable dynamic expansion.
          cwd: 'spec/'         # Src matches are relative to this path.
          src: ['**/*.coffee'] # Actual pattern(s) to match.
          dest: 'build/lib/spec/'    # Destination path prefix.
          ext: '.js'           # Dest filepaths will have this extension.
        ]

    browserify:
      demo:
        files: [
          expand: true
          cwd: 'build/lib/'
          src: ['src/repl.js', 'build/lib/spec/<%= pkg.name %>-spec.js', 'build/lib/spec/functional-spec.js',
                'build/lib/spec/<%= pkg.name %>-core-spec.js']
          dest: 'build/demo/js/'
        ]
        options:
          exclude: ['lodash-node']

    'gh-pages':
      src: ['**']
      options:
        base: 'build/demo/'
        push: true


  grunt.loadNpmTasks 'grunt-shell'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-gh-pages'

  # grunt-jasmine-node is for tests, grunt-jasmine-node-coverage is for code coverage
  grunt.loadNpmTasks 'grunt-jasmine-node'
  grunt.renameTask 'jasmine_node', 'jasmine_test'
  grunt.loadNpmTasks 'grunt-jasmine-node-coverage'

  grunt.registerTask 'build', ['coffeelint', 'shell:jison', 'coffee']
  grunt.registerTask 'test', ['build', 'jasmine_test']
  grunt.registerTask 'default', ['build', 'browserify', 'jasmine_node']
