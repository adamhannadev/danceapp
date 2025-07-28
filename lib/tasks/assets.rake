namespace :assets do
  desc "Build CSS assets"
  task :build_css do
    system("yarn build:css") || abort("CSS build failed")
  end

  desc "Watch CSS assets for changes"
  task :watch_css do
    system("yarn watch:css") || abort("CSS watch failed")
  end

  desc "Precompile assets including CSS build"
  task precompile: :build_css do
    Rake::Task["assets:precompile"].invoke
  end
end
