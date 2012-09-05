require "fileutils"

module Bourbon
  class Generator
    def initialize(arguments)
      @subcommand = arguments[0]
    end

    def run
      if @subcommand == "install"
       install
      elsif @subcommand == "update"
        update
      end
    end

    private

    def install
      if bourbon_files_already_exist?
        puts "Bourbon files already installed, doing nothing."
      else
        install_files
        puts "Bourbon files installed to bourbon/"
      end
    end

    def update
      if bourbon_files_already_exist?
        remove_bourbon_directory
        install_files
        puts "Bourbon files updated."
      else
        puts "No existing bourbon installation. Doing nothing."
      end
    end

    class Plugin
      def initialize(args)
        @logger = args[:logger]
        @installation_manager = args[:installation_manager]
        @name = args[:name]
      end

      def install
        logger.info("installing #{@name}")
        installation_manager.ensure_bourbon_installed
        installation_manager.ensure_plugin_directory
        installation_manager.ensure_extensions_installed
        installation_manager.ensure_stylesheets_installed
      end

      def update
        logger.info("updating #{@name}")
        installation_manager.ensure_bourbon_installed
        installation_manager.remove_plugin
        install
      end

      protected

      attr_reader :logger, :installation_manager
    end

    class BourbonNotInstalled < StandardError
    end

    require 'logger'
    class NullLogger < Logger
      def initialize(output_buffer)
        super
        nullify_logger
      end

      private

      def nullify_logger
        self.progname = 'bourbon'
        #self.level = 10
      end
    end

    class InstallationManager
      def initialize(args)
        @logger = args[:logger]
        @plugin_name = args[:plugin_name]
      end

      def ensure_bourbon_installed
        @logger.debug('ensuring Bourbon is installed')
        unless File.directory?('bourbon')
          @logger.fatal("Bourbon is not installed in #{Dir.pwd}")
          raise BourbonNotInstalled
        end
      end

      def ensure_plugin_directory
        @logger.debug('ensuring the plugin has a directory')
        FileUtils.mkdir_p(plugin_dir)
      end

      def ensure_extensions_installed
        @logger.debug('ensuring the plugin extensions are installed')
        copy_top_level_plugin_lib
        copy_sass_extensions_lib
        copy_sass_extensions
      end

      def ensure_stylesheets_installed
        @logger.debug('ensuring the plugin stylesheets are installed')
        FileUtils.cp_r(all_stylesheets, plugin_dir)
      end

      def remove_plugin
        @logger.debug('removing the plugin')
        FileUtils.rm_rf(plugin_dir)
      end

      private

      def plugin_dir
        @plugin_name
      end

      def copy_top_level_plugin_lib
        if File.exist?(top_level_plugin_lib)
          @logger.debug('installing the top level plugin library')
          FileUtils.mkdir_p(plugin_implementation_dir)
          FileUtils.cp(top_level_plugin_lib, plugin_lib)
        else
          @logger.debug("skipping the top level plugin library: #{top_level_plugin_lib}")
        end
      end

      def copy_sass_extensions_lib
        if File.exist?(top_level_sass_extensions_lib)
          @logger.debug('installing the sass extensions library')
          FileUtils.cp(top_level_sass_extensions_lib, sass_extensions_lib)
        else
          @logger.debug("skipping the sass extensions library: #{top_level_sass_extensions_lib}")
        end
      end

      def copy_sass_extensions
        if File.directory?(top_level_sass_extensions_dir)
          @logger.debug('installing the sass extensions')
          FileUtils.cp_r(top_level_sass_extensions_dir, sass_extensions_dir)
        else
          @logger.debug("skipping the sass extensions: #{top_level_sass_extensions_dir}")
        end
      end

      def top_level_plugin_dir
        File.dirname(File.dirname(File.dirname(File.dirname(__FILE__))))
      end

      def top_level_plugin_lib
        File.join(top_level_plugin_dir, plugin_lib)
      end

      def top_level_sass_extensions_lib
        File.join(top_level_plugin_dir, sass_extensions_lib)
      end

      def top_level_sass_extensions_dir
        File.join(top_level_plugin_dir, sass_extensions_dir)
      end

      def plugin_lib
        File.join(plugin_dir, 'lib', "#{@plugin_name}.rb")
      end

      def sass_extensions_lib
        File.join(plugin_implementation_dir, 'sass_extensions.rb')
      end

      def sass_extensions_dir
        File.join(plugin_implementation_dir, 'sass_extensions')
      end

      def plugin_implementation_dir
        File.join(plugin_dir, 'lib', @plugin_name)
      end

      def all_stylesheets
        Dir[File.join(stylesheets_directory, '*')]
      end

      def stylesheets_directory
        File.join(top_level_plugin_dir, plugin_dir, *%w(app assets stylesheets))
      end
    end

    private

    def logger
      NullLogger.new($stdout)
    end

    def bourbon_files_already_exist?
      File.directory?("bourbon")
    end

    def install_files
      installation_manager = InstallationManager.new(logger: logger, plugin_name: 'bourbon')
      installation_manager.ensure_plugin_directory
      installation_manager.ensure_extensions_installed
      installation_manager.ensure_stylesheets_installed
    end

    def remove_bourbon_directory
      FileUtils.rm_rf("bourbon")
    end
  end
end
