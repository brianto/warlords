require 'zip/zip'

MAIN_LIB = File.join "lib", "main"
TEST_LIB = File.join "lib", "test"

MAIN_SRC = File.join "src", "main"
TEST_SRC = File.join "src", "test"

CLIENT_BUILD_ROOT = File.join "build", "client"

SQUISH_TOOL = File.join "tools", "squish.lua"

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
  Dir.glob(File.join(path_elements)).keep_if do |file|
    file =~ /\.lua/
  end
end

def timestamp
  Time.now.strftime "%Y-%m-%d"
end

task :clean do
  rm_rf "build"
end

task :test do
  Rake::Task["test:all"].invoke
end

namespace :client do
  task :run => :build do
    ENV["LUA_PATH"] = "#{CLIENT_BUILD_ROOT}/?.lua"

    sh "love #{CLIENT_BUILD_ROOT}"
  end

  task :build do
    mkdir_p CLIENT_BUILD_ROOT

    cp_r File.join("lib", "main", "."), CLIENT_BUILD_ROOT
    cp_r File.join("src", "main", "client"), CLIENT_BUILD_ROOT
    cp_r File.join("src", "main", "core"), CLIENT_BUILD_ROOT
    cp_r File.join("src", "main", "library"), CLIENT_BUILD_ROOT

    File.open File.join(CLIENT_BUILD_ROOT, "main.lua"), "w" do |file|
      file.write "require 'client/love'"
    end
  end

  task :package => :build do
    filename = File.join "build", "warlords-client-#{timestamp}.zip"

    Zip::ZipFile.open(filename, Zip::ZipFile::CREATE) do |zip|
      Dir.glob(File.join(CLIENT_BUILD_ROOT, "**", "*.lua")).each do |file|
        destination = file.split(File::SEPARATOR).drop(2).join(File::SEPARATOR)
        zip.add destination, file
      end
    end
  end
end

namespace :server do
  task :setup_lua_path do
    ENV["LUA_PATH"] = [MAIN_LIB, MAIN_SRC].collect do |path|
      File.join path, "?.lua"
    end.join(";")
  end

  task :run => :setup_lua_path do
    sh "lua -e \"require 'server/server'\""
  end

  task :create_server_bootstrap do
    mkdir_p "build"

    File.open File.join("build", "server-main.lua"), "w" do |file|
      file.puts "require 'server/server'"
    end
  end

  task :create_squishy => :create_server_bootstrap do
    mkdir_p "build"

    lib = ["lib", "main", "*.lua"]
    server = ["src", "main", "server", "*.lua"]
    core = ["src", "main", "core", "*.lua"]
    library = ["src", "main", "library", "**", "*.lua"]

    lua_modules = [lib, server, core, library]

    File.open File.join("build", "squishy"), "w" do |file|
      lua_modules.each do |parts|
        files = lua_files parts
        requires = lua_requires parts

        files.zip(requires).each do |path, lua_require|
          relative_path = File.join "..", path
          file.puts "Module '#{lua_require}' '#{relative_path}'"
        end
      end

      file.puts "Main 'server-main.lua'"

      output_file = File.join "build", "warlords-server-#{timestamp}.lua"
      file.puts "Output '#{output_file}'"
    end
  end

  task :package => :create_squishy do
    sh "lua #{SQUISH_TOOL} build -vv"
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
