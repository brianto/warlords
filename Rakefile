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

desc "purges workspace of build artifacts"
task :clean do
  rm_rf "build"
end

desc "compiles client into a LOVE package and server into a standalone file"
task :package do
  Rake::Task["client:package"].invoke
  Rake::Task["server:package"].invoke
end

desc "runs all server, core, and library tests"
task :test do
  Rake::Task["test:all"].invoke
end

namespace :client do
  desc "starts the LOVE client"
  task :run => :build do
    ENV["LUA_PATH"] = "#{CLIENT_BUILD_ROOT}/?.lua"

    sh "love #{CLIENT_BUILD_ROOT}"
  end

  desc "copies client source and dependencies for execution and/or packaging"
  task :build do
    mkdir_p CLIENT_BUILD_ROOT

    cp_r File.join("lib", "main", "."), CLIENT_BUILD_ROOT
    cp_r File.join("src", "main", "client"), CLIENT_BUILD_ROOT
    cp_r File.join("src", "main", "core"), CLIENT_BUILD_ROOT
    cp_r File.join("src", "main", "library"), CLIENT_BUILD_ROOT

    File.open File.join(CLIENT_BUILD_ROOT, "main.lua"), "w" do |file|
      file.write "require 'client/bootstrap'"
    end
  end

  desc "creates a LOVE compliant package for execution"
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
  desc "sets the LUA_PATH environment variable for source execution"
  task :setup_lua_path do
    ENV["LUA_PATH"] = [MAIN_LIB, MAIN_SRC].collect do |path|
      File.join path, "?.lua"
    end.join(";")
  end

  desc "runs the server"
  task :run => :setup_lua_path do
    sh "lua -e \"require 'server/bootstrap'\""
  end

  desc "creates build/server-main.lua which bootstraps the server for execution"
  task :create_server_bootstrap do
    mkdir_p "build"

    File.open File.join("build", "server-main.lua"), "w" do |file|
      file.puts "require 'server/bootstrap'"
    end
  end

  desc "generates a squishy packaging descriptor for combining server dependencies"
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

  desc "packages the server code into a standalone lua file"
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

  desc "sets the LUA_PATH environment variable for source testing"
  task :setup_lua_path do
    ENV["LUA_PATH"] = [MAIN_LIB, TEST_LIB, MAIN_SRC, TEST_SRC].collect do |path|
      File.join path, "?.lua"
    end.join(";")
  end

  desc "runs all tests in src/tests"
  task :all => :setup_lua_path do
    lua_test "src", "test", "**", "*.lua"
  end

  desc "runs all tests in src/tests/server"
  task :server => :setup_lua_path do
    lua_test "src", "test", "server", "*.lua"
  end

  desc "runs all tests in src/tests/core"
  task :core => :setup_lua_path do
   lua_test "src", "test", "core", "*.lua"
  end

  desc "runs tests for all or a specific library in src/tests/library"
  task :library, [:set] => :setup_lua_path do |task, params|
    params[:set] ||= ""

    lua_test "src", "test", "library", params[:set], "*.lua"
  end
end
