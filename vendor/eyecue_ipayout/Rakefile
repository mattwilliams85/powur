require "bundler/gem_tasks"

Dir.glob('tasks/**/*.rake').each(&method(:import))

task :console do
  exec "irb -r mygem -I ./lib"
end