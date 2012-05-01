# Yes, i know, this is arguably bad form, but i'm actually going to use bundler
# as an API
require 'rubygems'
require 'bundler/setup'
require 'fileutils'

module ZK
  module Server
    ZK_JAR_GEM  = 'slyphon-zookeeper_jar'
    LOG4J_GEM   = 'slyphon-log4j'

    def self.zk_jar_path
      # in future revisions of the zookeeper jar, we'll make it easier to get
      # at this information without needing rubygems and bundler to get at it,
      # but for now this is the best way

      @zk_jar_path ||= get_jar_paths_from_gem(ZK_JAR_GEM).first
    end

    def self.log4j_jar_path
      @log4j_jar_path ||= get_jar_paths_from_gem(LOG4J_GEM).first
    end

    def self.get_jar_paths_from_gem(gem_name)
      glob = "#{get_spec_for(gem_name).lib_dirs_glob}/**/*.jar"

      Dir[glob].tap do |ary|
        raise "gem #{gem_name} did not contain any jars (using glob: #{glob.inspect})" if ary.empty?
      end
    end

    def self.get_spec_for(gem_name)
      not_found = proc do
        raise "could not locate the #{gem_name} Gem::Specification! wtf?!"
      end

      Bundler.load.specs.find(not_found) { |s| s.name == gem_name }
    end

    def self.java_binary_path=(path)
      @java_binary_path = path
    end

    def self.java_binary_path
      @java_binary_path ||= which('java')
    end

    def self.which(bin_name)
      if_none = proc { "Could not find #{bin_name} in PATH: #{ENV['PATH'].inspect}" }
      ENV['PATH'].split(':').map{|n| File.join(n, bin_name) }.find(if_none) {|x| File.executable?(x) }
    end

    def self.default_log4j_props_path
      File.expand_path('../zk-server/log4j.properties', __FILE__)
    end
  end
end

require 'zk-server/version'
require 'zk-server/process'
