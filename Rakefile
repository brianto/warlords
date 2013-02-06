MAIN_LIB = File.join "lib", "main"
TEST_LIB = File.join "lib", "test"

MAIN_SRC = File.join "src", "main"
TEST_SRC = File.join "src", "test"

def lua_files(*path_elements)
  Dir.glob(File.join(path_elements)).collect do |file|
    parts = file.split File::SEPARATOR
    parts[-1] = File.basename parts.last, ".lua"
    parts.drop(2).join(File::SEPARATOR)
  end.reject do |file|
    file =~ /bootstrap/
  end
end

namespace :client do

end

namespace :server do

end

task :test do
  Rake::Task["test:all"].invoke
end

namespace :test do
  TEST_LAUNCHER = File.join "src", "test", "bootstrap.lua"

  def lua_test(*path_elements)
    tests = lua_files path_elements
    sh "lua #{TEST_LAUNCHER} #{tests.join(' ')}"
  end

  task :setup_lua_path do
    ENV["LUA_PATH"] = [MAIN_LIB, TEST_LIB, MAIN_SRC, TEST_SRC].collect do |path|
      File.join path, "?.lua"
    end.join(";")
  end

  task :all => :setup_lua_path do
    lua_test "src", "test", "**", "*.lua"
  end

  task :server => :setup_lua_path do
    lua_test "src", "test", "server", "*.lua"
  end

  task :core => :setup_lua_path do
   lua_test "src", "test", "core", "*.lua"
  end

  task :library, [:set] => :setup_lua_path do |task, params|
    params[:set] ||= ""

    lua_test "src", "test", "library", params[:set], "*.lua"
  end
end
