'use strict';

module.exports = function(grunt) {
    // Show elapsed time after tasks run
    require('time-grunt')(grunt);
    // load processhtml
    grunt.loadNpmTasks('grunt-processhtml');
    // Load all Grunt tasks
    require('jit-grunt')(grunt);

    grunt.initConfig({
        app: {
            app: '.',
            dist: '_site',
            baseurl: '.'
        },
        watch: {
            sass: {
                files: ['<%= app.app %>/_assets/scss/**/*.{scss,sass}'],
                tasks: ['sass:server', 'autoprefixer']
            },
            scripts: {
                files: ['<%= app.app %>/_assets/js/**/*.{js}'],
                tasks: ['uglify']
            },
            jekyll: {
                files: [
                    '<%= app.app %>/**/*.{html,yml,md,mkd,markdown}'
                ],
                tasks: ['jekyll:server']
            },
            livereload: {
                options: {
                    livereload: '<%= connect.options.livereload %>'
                },
                files: [
                    '_site/**/*.{html,yml,md,mkd,markdown}',
                    '_site/assets/css/*.css',
                    '_site/assets/js/*.js',
                    '<%= app.app %>/assets/img/**/*.{gif,jpg,jpeg,png,svg,webp}'
                ]
            }
        },
        connect: {
            options: {
                port: 9000,
                livereload: 35729,
                // change this to '0.0.0.0' to access the server from outside
                hostname: 'localhost'
            },
            livereload: {
                options: {
                    open: {
                        target: 'http://localhost:9000/<%= app.baseurl %>'
                    },
                    base: [
                        '_site',
                        '.tmp',
                        '<%= app.app %>'
                    ]
                }
            },
            dist: {
                options: {
                    open: {
                        target: 'http://localhost:9000/<%= app.baseurl %>'
                    },
                    base: [
                        '<%= app.dist %>',
                        '.tmp'
                    ]
                }
            }
        },
        clean: {
            server: [
                '.jekyll',
                '.tmp'
            ],
            dist: {
                files: [{
                    dot: true,
                    src: [
                        '.tmp',
                        // '<%= app.dist %>/*',
                        '!<%= app.dist %>/.git*'
                    ]
                }]
            }
        },
        jekyll: {
            options: {
                config: '_config.yml',
                src: '<%= app.app %>'
            },
            dist: {
                options: {
                    dest: '<%= app.dist %>',
                }
            },
            server: {
                options: {
                    config: '_config.yml',
                    dest: '<%= app.dist %>'
                }
            }
        },
        htmlmin: {
            dist: {
                options: {
                    removeComments: true,
                    collapseWhitespace: true,
                    collapseBooleanAttributes: true,
                    removeAttributeQuotes: true,
                    removeRedundantAttributes: true,
                    removeEmptyAttributes: true,
                    minifyJS: true,
                    minifyCSS: true
                },
                files: [{
                    expand: true,
                    cwd: '<%= app.dist %>/<%= app.baseurl %>',
                    src: ['**/*.html', '!amp/**/*.html'],
                    dest: '<%= app.dist %>/<%= app.baseurl %>'
                }]
            }
        },
        uglify: {
            options: {
                preserveComments: false,
                mangle: {
                 reserved: ['jQuery']
               }
            },
            dist: {
                files: {
                    '_site/assets/js/scripts.js': ['<%= app.app %>/assets/js/**/*.js', '!<%= app.app %>/assets/js/**/*.min.js']
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
                report: 'min',
                ignore: ['.reveal', '.progressive', '.progressive img.preview', '.progressive img.reveal', '.progressive img', '.progressive img.reveal']
            },
            dist: {
                nonull: true,
                src: ['_site/**/*.html', '!yandex_f0a389ddfda6489c.html', '!_site/amp/**/*.html', '!_site/tag/**/*.html', '!_site/category/**/*.html', '!_site/en/**/*.html'],
                dest: '_site/assets/css/site.css'
            }
        },
        autoprefixer: {
            options: {
                browsers: ['last 3 versions']
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
                    base: './',
                    css: [
                        '_site/assets/css/site.css'
                    ],
                    minify: true,
                    width: 320,
                    height: 480
                },
                files: [{
                    expand: true,
                    cwd: '<%= app.dist %>/<%= app.baseurl %>',
                    src: ['**/*.html', '!amp/**/*.html'],
                    dest: '<%= app.dist %>/<%= app.baseurl %>'
                }]
            }
        },
        cssmin_old: {
            dist: {
                options: {
                    keepSpecialComments: 0,
                    check: 'gzip'
                },
                files: {
                  '_site/assets/css/site.css': '_site/assets/css/site.css'
                  // [ '_site/assets/css/vendor/syntax.css', '_site/assets/css/vendor/semantic.min.css', '_site/assets/css/main.css', '_site/assets/css/mobile.css']
                }
            }
        },
        imagemin: {
            options: {
                progressive: true
            },
            dist: {
                files: [{
                    expand: true,
                    cwd: '<%= app.dist %>/<%= app.baseurl %>/assets/img',
                    src: '**/*.{jpg,jpeg,png,gif}',
                    dest: '<%= app.dist %>/<%= app.baseurl %>/assets/img'
                },{
                    expand: true,
                    cwd: '<%= app.dist %>/<%= app.baseurl %>/assets/resized',
                    src: '**/*.{jpg,jpeg,png,gif}',
                    dest: '<%= app.dist %>/<%= app.baseurl %>/assets/resized'
                }
              ]
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
            dest: '_site'
          },
          html: '_site/index.html'
        },
        usemin: {
          options: {
            assetsDirs: ['_site', '_site/assets/img']
          },
          html: ['_site/**/*.html'],
          css: ['_site/assets/css/**/*.css']
        },
        // Usemin adds files to concat
        concat: {},
        // Usemin adds files to uglify
        uglify: {},
        // Usemin adds files to cssmin
        cssmin: {
          dist: {
            options: {
              check: 'gzip'
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

    grunt.registerTask('optimize', [
        // 'clean:dist',
        // 'jekyll:dist',
        'imagemin',
        'svgmin',
        'uncss',
        'cssmin',
        'processhtml:js',
        'processhtml:css',
        'autoprefixer',
        // 'uglify',
        // 'critical',
        'usemin',
        'htmlmin'
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
