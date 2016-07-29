# ./Rakefile

#!/usr/bin/env rake
task :app do
  require "./MyRoda"
end
Dir[File.dirname(__FILE__) + "/lib/tasks/*.rb"].sort.each do |path|
  require path
end
