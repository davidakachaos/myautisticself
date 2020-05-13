'use strict';

module.exports = function(grunt) {
    // Show elapsed time after tasks run
    require('time-grunt')(grunt);
    // load processhtml
    grunt.loadNpmTasks('grunt-newer');
    grunt.loadNpmTasks('grunt-processhtml');
    grunt.loadNpmTasks('grunt-usemin');
    grunt.loadNpmTasks('grunt-critical');
    grunt.loadNpmTasks('grunt-closure-compiler');
    // Load all Grunt tasks
    require('jit-grunt')(grunt);

    grunt.initConfig({
        app: {
            app: '.',
            dist: '_site',
            baseurl: '.'
        },
        htmlmin: {
            dist: {
                options: {
                    removeComments: true,
                    collapseWhitespace: true,
                    collapseBooleanAttributes: true,
                    collapseWhitespace: true,
                    conservativeCollapse: true,
                    removeAttributeQuotes: true,
                    removeCommentsFromCDATA: true,
                    removeEmptyAttributes: true,
                    removeOptionalTags: true,
                    useShortDoctype: true,
                    minifyJS: true,
                    minifyCSS: true
                },
                files: [{
                    expand: true,
                    cwd: '<%= app.dist %>/<%= app.baseurl %>',
                    src: ['**/*.html'],
                    dest: '<%= app.dist %>/<%= app.baseurl %>'
                }]
            }
        },
        uglify: {
            options: {
                preserveComments: false,
                mangle: {
                    reserved: ['jQuery', 'Cookies']
                },
                reserveDOMProperties: true,
                compress: {
                  drop_console: true
                }
            },
            dist: {
                options:{
                  sourceMap: true,
                  sourceMapName: '_site/assets/js/scripts.min.js'
                },
                files: {
                    '_site/assets/js/scripts.min.js': ['<%= app.app %>/assets/js/*.js', '<%= app.app %>/assets/js/vendor/*.js', '<%= app.app %>/js/**/*.js'],
                }
            }
        },
        sass: {
            server: {
                options: {
                    sourceMap: true
                },
                files: [{
                    expand: true,
                    cwd: '<%= app.app %>/assets/scss',
                    src: '**/*.{scss,sass}',
                    dest: '.tmp/<%= app.baseurl %>/css',
                    ext: '.css'
                }]
            },
            dist: {
                options: {
                    outputStyle: 'compressed'
                },
                files: [{
                    expand: true,
                    cwd: '<%= app.app %>/assets/scss',
                    src: '**/*.{scss,sass}',
                    dest: '<%= app.dist %>/<%= app.baseurl %>/assets/css',
                    ext: '.css'
                }]
            }
        },
        uncss: {
            options: {
                htmlroot: '_site',
                stylesheets: ['assets/css/site.css'],
                report: 'min',
                ignoreSheets: [/fonts.googleapis/],
                ignore: ['.webp header', 'input[name="_gotcha"]', '.ui.form', '.ui.form input[type=email]', '.ui.form textarea',
                        '.ui.message', '.ui.message.error', '.ui.message.succes', '.ui.form .field>label',
                        'ui button', 'lazyload', '.no-webp header', '.ui.form input[type=text]', '.ui.message>:first-child',
                        '.ui.message .header', '.ui.message p:last-child', '.ui.button'
                      ]
            },
            dist: {
                nonull: true,
                stylesheets: ['assets/css/site.css'],
                src: ['_site/**/*.html', '!yandex_f0a389ddfda6489c.html',
                        '!_site/2019/**/*.html', '!_site/2020/**/*.html', '_site/2019/08/hulpgids-asperger-syndroom-review.html',
                        '_site/2019/07/beelddenker.html', '_site/2019/10/cobwebs-in-my-head.html',
                        '_site/2020/05/13/angst-stress-spanningen-en-autisme.html',
                        '!_site/amp/**/*.html', '!_site/tag/**/*.html',
                        '!_site/category/**/*.html', '!_site/en/**/*.html',
                        '_site/contact-opnemen.html', '_site/get-in-touch.html'
                    ],
                dest: '_site/assets/css/site.css'
            }
        },
        autoprefixer: {
            options: {
                browsers: ['> 1%', 'last 2 versions', 'Firefox ESR', 'Opera 12.1']
            },
            dist: {
                files: [{
                    expand: true,
                    cwd: '_site/assets/css',
                    src: '**/*.css',
                    dest: '_site/assets/css'
                }]
            }
        },
        critical: {
            dist: {
                options: {
                    base: '.',
                    css: [
                        '_site/assets/css/site.css'
                    ],
                    minify: true,
                    inline: true,
                    inlineImages: true,
                    width: 1300,
                    height: 900
                },
                files: [{
                    expand: true,
                    cwd: '_site/',
                    src: ['*.html', '!amp*', '!yandex*'],
                    dest: '_site/'
                },{
                    expand: true,
                    cwd: '_site/2019/',
                    src: ['**/*.html'],
                    dest: '_site/2019/'
                },{
                    expand: true,
                    cwd: '_site/2020/',
                    src: ['**/*.html'],
                    dest: '_site/2020/'
                },{
                    expand: true,
                    cwd: '_site/en/',
                    src: ['**/*.html'],
                    dest: '_site/en/'
                },{
                    expand: true,
                    cwd: '_site/tag/',
                    src: ['**/*.html'],
                    dest: '_site/tag/'
                },{
                    expand: true,
                    cwd: '_site/category/',
                    src: ['**/*.html'],
                    dest: '_site/category/'
                }
                // ,{
                //     expand: true,
                //     cwd: '<%= app.dist %>/<%= app.baseurl %>',
                //     src: ['**/*.html', '!amp/**/*.html'],
                //     dest: '<%= app.dist %>/<%= app.baseurl %>'
                // }
              ]
            }
        },
        imagemin: {
            options: {
                progressive: true,
                concurrency: 8
            },
            dist: {
                files: [{
                    expand: true,
                    cwd: '<%= app.dist %>/<%= app.baseurl %>/assets/img',
                    src: '**/*.{jpg,jpeg,png,gif}',
                    dest: '<%= app.dist %>/<%= app.baseurl %>/assets/img'
                }, {
                    expand: true,
                    cwd: '<%= app.dist %>/<%= app.baseurl %>/assets/resized',
                    src: '**/*.{jpg,jpeg,png,gif}',
                    dest: '<%= app.dist %>/<%= app.baseurl %>/assets/resized'
                }]
            }
        },
        svgmin: {
            dist: {
                files: [{
                    expand: true,
                    cwd: '<%= app.dist %>/<%= app.baseurl %>/assets/img',
                    src: '**/*.svg',
                    dest: '<%= app.dist %>/<%= app.baseurl %>/assets/img'
                }]
            }
        },
        processhtml: {
            options: {
                process: true,
            },
            js: {
                files: [{
                    expand: true,
                    cwd: '<%= app.dist %>/<%= app.baseurl %>',
                    src: ['**/*.html', '!amp/**/*.html'],
                    dest: '<%= app.dist %>/',
                    ext: '.html'
                }]
            },
            css: {
                files: [{
                    expand: true,
                    cwd: '<%= app.dist %>/<%= app.baseurl %>',
                    src: ['**/*.html', '!amp/**/*.html'],
                    dest: '<%= app.dist %>/',
                    ext: '.html'
                }]
            }
        },
        useminPrepare: {
            options: {
                dest: '_site',
                root: '_site'
            },
            html: ['_site/**/*.html']
        },
        usemin: {
            options: {
                assetsDirs: ['_site', '_site/assets/img'],
                flow: { steps: { js: ['concat', 'uglify'], css: ['concat', 'cssmin'] }, post: {} }
            },
            html: ['_site/**/*.html'],
            css: ['_site/assets/css/**/*.css'],
            blockReplacements: {
              css: function (block) {
                  return '<link rel="preload" href="' + block.dest + '" as="style" onload="this.onload=null;this.rel=\'stylesheet\'"><noscript><link rel="stylesheet" href="' + block.dest + '"></noscript>';
              }
            },
        },
        // Usemin adds files to concat
        concat: {},
        // Usemin adds files to uglify
        uglify: {
            options: {
                preserveComments: false,
                mangle: {
                    reserved: ['jQuery']
                }
            },
        },
        'closure-compiler': {
          optimize: {
            closurePath: '/usr/local/bin/closure-compiler',
            // js: '_site/assets/js/scripts.min.js',
            js: '.tmp/concat/assets/js/scripts.min.js',
            jsOutputFile: '_site/assets/js/scripts.min.js',
            maxBuffer: 50000,
            options: {
              compilation_level: 'SIMPLE_OPTIMIZATIONS',
              strict_mode_input: false,
              create_source_map: '_site/assets/js/scripts.min.js.map',
              language_in: 'ECMASCRIPT5',
              language_out: 'ECMASCRIPT_2019',
              externs: "externs\jquery-1.8.js",
              jscomp_off: 'es5Strict'
            }
          }
        },
        // Usemin adds files to cssmin
        cssmin: {
            dist: {
                options: {
                    check: 'gzip',
                    sourceMap: true,
                }
            }
        },
        copy: {
            dist: {
                files: [{
                    expand: true,
                    dot: true,
                    cwd: '.tmp/<%= app.baseurl %>',
                    src: [
                        'css/**/*',
                        'js/**/*'
                    ],
                    dest: '<%= app.dist %>/<%= app.baseurl %>'
                }]
            }
        },
        buildcontrol: {
            dist: {
                options: {
                    dir: '<%= app.dist %>/<%= app.baseurl %>',
                    remote: 'git@github.com:user/repo.git',
                    branch: 'gh-pages',
                    commit: true,
                    push: true,
                    connectCommits: false
                }
            }
        },
        stripCssComments: {
            dist: {
                options: {
                    preserve: false
                },
                files: {
                    '_site/assets/css/site.css': '_site/assets/css/site.css'
                }
            }
        }
    });

    // Define Tasks
    grunt.registerTask('serve', function(target) {
        if (target === 'dist') {
            return grunt.task.run(['build', 'connect:dist:keepalive']);
        }

        grunt.task.run([
            'clean:server',
            'jekyll:server',
            'useminPrepare',
            'concat',
            'autoprefixer',
            // 'uglify',
            'connect:livereload',
            'watch'
        ]);
    });

    grunt.registerTask('server', function() {
        grunt.log.warn('The `server` task has been deprecated. Use `grunt serve` to start a server.');
        grunt.task.run(['serve']);
    });

    grunt.registerTask('removeOldAssets', function(){
        grunt.file.delete('_site/assets/css/main.css');
        grunt.file.delete('_site/assets/js/vendor');
        grunt.file.delete('_site/assets/js/main.js');
        grunt.file.delete('_site/assets/css/main.css');
        grunt.file.delete('_site/assets/css/mobile.css');
        grunt.file.delete('_site/assets/css/vendor/syntax.css');
        grunt.file.delete('_site/assets/css/vendor/semantic.min.css');
    });

    grunt.registerTask('removeTmp', function(){
        grunt.file.delete('.tmp');
        grunt.file.delete('_site/assets/js/scripts.min.js.report.txt');
    })

    grunt.registerTask('optimize', [
        'newer:imagemin',
        'newer:svgmin',
        'newer:useminPrepare',
        'newer:concat:generated',
        'newer:cssmin:generated',
        'newer:uglify:generated',
        'removeOldAssets',
        'usemin',
        'closure-compiler:optimize',
        'uncss',
        'newer:stripCssComments',
        'newer:autoprefixer',
        'critical:dist',
        'newer:htmlmin',
        'removeTmp'
    ]);

    grunt.registerTask('testjs', [
      'useminPrepare',
      'concat:generated',
      'cssmin:generated',
      'uglify:generated',
      'removeOldAssets',
      'usemin',
      'closure-compiler:optimize',
    ]);

    // grunt.registerTask('deploy', [
    //     'build',
    //     'copy',
    //     'buildcontrol'
    // ]);

    grunt.registerTask('default', [
        'serve'
    ]);
};
