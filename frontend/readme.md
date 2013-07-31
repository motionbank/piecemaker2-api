# Coding Tips

Some general information about frontend development

## CSS Authoring

We're using [Compass](http://compass-style.org/), so every developer have to use it's compiler.
See the ./config.rb for additional information.

### PhpStorm

Some information for setting up PhpStorm while using RVM and OS X:
Go to "Projects Settings - File Watchers" and add a custom file watcher with the following options:

![PhpStorm File Watcher](http://gopeter.de/misc/filewatcher.png)

If you are using RVM, you have to add an environment variable:

`GEM_PATH : path to your ruby version`

For example:

`GEM_PATH : /Users/peter_goebel/.rvm/gems/ruby-2.0.0-p247`

### External file watcher

If you are using another code editor, you can run an external file watcher, e.g. Scout [Scout](mhs.github.io/scout-app/) or [Prepos](http://alphapixels.com/prepros/).