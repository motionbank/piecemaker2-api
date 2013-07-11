require "pathname"
require 'tmpdir'

task :default do
  exec("rake -T")
end  

desc "create .dmg file from piecemaker.app"
task :dmg do

  # create tmp dir
  TMP_DIR = Pathname.new(Dir.mktmpdir)
  WORKING_DIR = Pathname.new(Dir.pwd)

  # copy piecemaker app to tmp dir
  system("cp -r #{WORKING_DIR + 'piecemaker2.app'} #{TMP_DIR}")

  # build dmg
  system("hdiutil create -fs HFS+ -volname 'Piecemaker2' \
    -srcfolder '#{TMP_DIR}' '#{WORKING_DIR + 'piecemaker2.dmg'}'")

  # remove tmp dir
  system("rm -rf #{TMP_DIR}")
end