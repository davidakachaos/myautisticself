'use strict';

module.exports = function(grunt) {
    // Show elapsed time after tasks run
    require('time-grunt')(grunt);
    // load processhtml
    grunt.loadNpmTasks('grunt-newer');
    grunt.loadNpmTasks('grunt-processhtml');
    grunt.loadNpmTasks('grunt-critical');
    grunt.loadNpmTasks('grunt-closure-compiler');
    grunt.loadNpmTasks('grunt-contrib-htmlmin');
    grunt.loadNpmTasks('grunt-contrib-uglify');
    grunt.loadNpmTasks('grunt-uncss');
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
                  sourceMapName: '_site/assets/js/scripts.js'
                },
                files: {
                    '_site/assets/js/scripts.js': ['_site/assets/js/*.js',
                      '_site/assets/js/vendor/*.js',
                      '_site/assets/js/main.js',
                      '!_site/assets/js/autotrack.js',
                      '!_site/assets/js/lazysizes.min.js',
                      '!_site/assets/js/ls.respimg.min.js',
                      '_site/js/**/*.js'
                    ],
                }
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
                        '.ui.message .header', '.ui.message p:last-child', '.ui.button', '.BetterTube', '.BetterTubePlayer',
                        '.BetterTube a', '.BetterTube a:hover', '.BetterTube figcaption', '.BetterTube iframe', '.BetterTube object',
                        '.BetterTube embed','.BetterTube video', '.BetterTube-playBtn', '.BetterTube-playBtn:hover'
                      ]
            },
            dist: {
                nonull: true,
                stylesheets: ['assets/css/site.css'],
                src: ['_site/**/*.html', '!yandex_f0a389ddfda6489c.html',
                        '!_site/2019/**/*.html', '!_site/2020/**/*.html', '_site/2019/08/hulpgids-asperger-syndroom-review.html',
                        '_site/2019/07/beelddenker.html', '_site/2019/10/cobwebs-in-my-head.html',
                        '_site/2020/05/angst-stress-spanningen-en-autisme.html',
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
                    src: ['*.html', '!amp*', '!webpushr*', '!yandex*'],
                    dest: '_site/'
                },
                // {
                //     expand: true,
                //     cwd: '_site/2019/',
                //     src: ['**/*.html'],
                //     dest: '_site/2019/'
                // },
                // {
                //     expand: true,
                //     cwd: '_site/2020/',
                //     src: ['**/*.html'],
                //     dest: '_site/2020/'
                // },{
                //     expand: true,
                //     cwd: '_site/en/',
                //     src: ['**/*.html'],
                //     dest: '_site/en/'
                // },{
                //     expand: true,
                //     cwd: '_site/tag/',
                //     src: ['**/*.html'],
                //     dest: '_site/tag/'
                // },{
                //     expand: true,
                //     cwd: '_site/category/',
                //     src: ['**/*.html'],
                //     dest: '_site/category/'
                // }
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
            dist: {
                files: [{
                    expand: true,
                    cwd: '<%= app.dist %>/<%= app.baseurl %>',
                    src: ['**/*.html', '!amp/**/*.html'],
                    dest: '<%= app.dist %>/',
                    ext: '.html'
                }]
            }
        },
        // Usemin adds files to concat
        concat: {
          dist:{
            files: [{
              src: ['_site/assets/css/*.css', '_site/assets/css/vendor/*.css', '!_site/assets/css/other_font.css'],
              dest: '_site/assets/css/site.css'
            }]
          }
        },
        // Usemin adds files to uglify
        uglify: {
          options: {
            mangle: {
              reserved: ['jQuery']
            }
          },
          dist: {
            files: [{
              src: ['_site/assets/js/*.js', '!_site/assets/js/*.min.js'],
              dest: '_site/assets/js/scripts.js'
            }]
          },
        },
        'closure-compiler': {
          optimize: {
            closurePath: 'closure-compiler',
            // closurePath: '/usr/local/lib/node_modules/google-closure-compiler',
            // js: '_site/assets/js/scripts.min.js',
            js: '_site/assets/js/scripts.js',
            jsOutputFile: '_site/assets/js/scripts.min.js',
            maxBuffer: 50000,
            options: {
              compilation_level: 'SIMPLE_OPTIMIZATIONS',
              //strict_mode_input: false,
              create_source_map: '_site/assets/js/scripts.min.js.map',
              //language_in: 'ECMASCRIPT5',
              //language_out: 'ECMASCRIPT_2019',
              externs: "externs\jquery-1.8.js",
              jscomp_off: 'es5Strict'
            }
          }
        },
        // Usemin adds files to cssmin
        cssmin: {
          options: {
              check: 'gzip',
              sourceMap: true,
          },
          dist: {
              files: [{
                expand: true,
                cwd: '<%= app.dist %>/<%= app.baseurl %>/assets/css',
                src: ['*.css', '!*.min.css'],
                dest: '<%= app.dist %>/<%= app.baseurl %>/assets/css',
                ext: '.min.css'
              }]
          },
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
    grunt.registerTask('removeOldAssets', function(){
        grunt.file.delete('_site/assets/css/main.css');
        grunt.file.delete('_site/assets/js/vendor/semantic.min.js');
        grunt.file.delete('_site/assets/js/main.js');
        grunt.file.delete('_site/assets/js/modernizer-webp.js');
        // grunt.file.delete('_site/assets/js/autotrack.js');
        // grunt.file.delete('_site/assets/js/autotrack.js.map');
        grunt.file.delete('_site/assets/js/autotrack.min.js');
        grunt.file.delete('_site/assets/js/BetterTube.js');
        grunt.file.delete('_site/assets/css/other_font.css');
        grunt.file.delete('_site/assets/css/main.css');
        grunt.file.delete('_site/assets/css/main.min.css');
        grunt.file.delete('_site/assets/css/main.min.css.map');
        grunt.file.delete('_site/assets/css/mobile.css');
        grunt.file.delete('_site/assets/css/mobile.min.css');
        grunt.file.delete('_site/assets/css/mobile.min.css.map');
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
        'newer:concat',
        'newer:cssmin',
        'uglify',
        'removeOldAssets',
        //'closure-compiler:optimize',
        'newer:processhtml',
        'uncss',
        'newer:stripCssComments',
        'newer:autoprefixer',
        'critical:dist',
        'newer:htmlmin',
        'removeTmp'
    ]);

    grunt.registerTask('testjs', [
      'newer:imagemin',
      'newer:svgmin',
      'newer:concat',
      'newer:cssmin',
      'uglify',
      'removeOldAssets',
      'closure-compiler:optimize',
      'newer:processhtml',
      'uncss',
      'newer:stripCssComments',
      'newer:autoprefixer',
    ]);

    grunt.registerTask('default', [
        'serve'
    ]);
};
