/*
* Import npm packages
*/
var gulp = require('gulp'),
    watch = require('gulp-watch'),
    concat = require('gulp-concat'),
    sass = require('gulp-ruby-sass'),
    connect = require('gulp-connect'),
    plumber = require('gulp-plumber'),
    nodemon = require('gulp-nodemon'),
    sourcemaps = require('gulp-sourcemaps');

var sassConfig = {
    compass: true,
    sourcemap: true,
    lineNumbers: true,
    style: "expanded",
    require: ["susy", "compass", "breakpoint"]
};

/*
* Live reload task for component
*/

gulp.task('develop', function () {
  nodemon({ script: 'server.js'
          , ext: 'html js'
          , tasks: ['livesass'] })
    .on('restart', function () {
      console.log('restarted!')
    })
})


gulp.task('live', function() {

    ComponentServer();
    
    //WEBPAGERELOADS
    gulp.watch('./public/views/*.html', ['html-reload']);
    gulp.watch('./public/styles/**/*.scss', ['sass-compile-reload']);
    gulp.watch('./public/js/**/*.js', ['js-reload']);
    
    gulp.watch('./app/**/*.js', ['js-reload']);

    gulp.watch('./index.html', ['index-reload']);
    gulp.watch('./config.js', ['js-reload']);
    gulp.watch('./server.js', ['js-reload']);

});

gulp.task('livesass', function() {
    
    gulp.watch('./public/styles/**/*.scss', ['sass-compile']);

});

/*
* HTML task
*/

gulp.task('index-reload', function () {
  gulp.src('./*.html')
    .pipe(connect.reload());
});

gulp.task('html-reload', function () {
  gulp.src('./public/views/*.html')
    .pipe(connect.reload());
});


/*
* Sass task
*/
gulp.task('sass-compile-reload', function() {
  return  sass('./public/styles/mainStyles.scss', sassConfig)
    .pipe(gulp.dest('./public/styles/css'))
    .pipe(sourcemaps.write('./maps'))
    .pipe(connect.reload());
});


gulp.task('sass-compile', function() {
  return  sass('./public/styles/mainStyles.scss', sassConfig)
    .pipe(gulp.dest('./public/styles/css'))
    .pipe(sourcemaps.write('./maps'))
});


/*
* Js task
*/
gulp.task('js-reload', function () {
  gulp.src('./public/js/**/*.js')
      .pipe(connect.reload());
});


/*
* Component server
*/
function ComponentServer () {
  connect.server({
    port: 8082,
    livereload: true,
    root: ['./public', './']
  }); 
}