task :default => 'test'

# CoffeeScritp relative tasks
desc "Remove oldies files"
task :remove_file do
    puts "remove old files"
    `rm lib/3scale/*.js`
end

desc "Compile JS from coffee script files"
task :compile => [:remove_file] do
    puts 'Compiling src files...'
    `coffee --bare --output lib/3scale/ --compile coffee/src/`
end

# Test relative tesks
desc "Remove oldies tests files"
task :remove_test_file do
    puts "remove old tests files"
    `rm test/*.js`
end

desc "Compile the test files"
task :compile_tests => [:remove_test_file] do
    puts "Compiling test files..."
    `coffee --bare --output test/ --compile coffee/test/`
end
desc "Make testing at the code"
task :test => [:compile, :compile_tests] do
    puts `vows test/* --spec`
end

# NodeJS relatives task
desc "Open a intereactive nodeJS console"
task :console => [:compile] do
    `export NODE_PATH="$HOME/Workspace/3scale_ws_api_for_js"`
    `node`
end