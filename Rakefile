require 'zip/zip'

MAIN_LIB = File.join "lib", "main"
TEST_LIB = File.join "lib", "test"

MAIN_SRC = File.join "src", "main"
TEST_SRC = File.join "src", "test"

def lua_requires(*path_elements)
  Dir.glob(File.join(path_elements)).collect do |file|
    parts = file.split File::SEPARATOR
    parts[-1] = File.basename parts.last, ".lua"
    parts.drop(2).join(File::SEPARATOR)
  end.reject do |file|
    file =~ /bootstrap/
  end
end

def lua_files(*path_elements)
  Dir.glob(File.join(path_elements)).filter do |file|
    file =~ ".lua"
  end
end

task :clean do
  rm_rf "build"
end

task :test do
  Rake::Task["test:all"].invoke
end

namespace :client do
  BUILD_ROOT = File.join "build", "client"

  task :run => :build do
    ENV["LUA_PATH"] = "#{BUILD_ROOT}/?.lua"

    sh "love #{BUILD_ROOT}"
  end

  task :build do
    mkdir_p BUILD_ROOT

    cp_r File.join("lib", "main", "."), BUILD_ROOT
    cp_r File.join("src", "main", "client"), BUILD_ROOT
    cp_r File.join("src", "main", "core"), BUILD_ROOT

    File.open File.join(BUILD_ROOT, "main.lua"), "w" do |file|
      file.write "require 'client/love'"
    end
  end

  task :package => :build do
    filename = File.join "build", "warlords-client-#{Time.now.strftime "%Y-%m-%d"}.zip"

    Zip::ZipFile.open(filename, Zip::ZipFile::CREATE) do |zip|
      Dir.glob(File.join(BUILD_ROOT, "**", "*.lua")).each do |file|
        destination = file.split(File::SEPARATOR).drop(2).join(File::SEPARATOR)
        zip.add destination, file
      end
    end
  end
end

namespace :server do
  task :build do

  end
end

namespace :test do
  TEST_LAUNCHER = File.join "src", "test", "bootstrap.lua"

  def lua_test(*path_elements)
    tests = lua_requires path_elements
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
