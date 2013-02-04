ENV["LUA_PATH"] = Dir.glob(File.join("{lib,src}", "*")).collect do |path|
  File.join(path, "?.lua")
end.join(File::PATH_SEPARATOR)

task :package do
end

task :test do
  launcher = File.join("src", "test", "bootstrap.lua")

  lua_requires = Dir.glob(File.join("src", "{main,test}", "**", "*.lua"))
  lua_requires.reject! do |file|
    file =~ /bootstrap/
  end

  lua_require_string = lua_requires.collect do |file|
    path = file.split(File::SEPARATOR)
    base = File.join(path.drop(2))

    File.join(File.dirname(base), File.basename(base, ".lua"))
  end.join(" ")

  sh "lua #{launcher} #{lua_require_string}"
end

task :clean do
  rm_rf "build"
end
