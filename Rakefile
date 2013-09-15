require 'bundler/gem_tasks'

desc 'Compile preprocessor'
task :install do
  system('cd lib/trace_visualization/preprocessor; make install; make clean')
end

desc 'Spec all functionality of gem'
task :spec_all do
  system('rspec spec/*')
end
