require "fileutils"
require 'bourbon/installation_manager'
require 'logger'
require 'thor'

module Bourbon
  class Generator < Thor
    desc 'install', 'Install Bourbon or a Bourbon plugin'
    method_option :verbose, aliases: '-V', desc: 'Talk through every step', type: :boolean, default: false
    def install(plugin_name = nil)
      if plugin_name
        install_plugin(plugin_name)
      elsif bourbon_files_already_exist?
        logger.info "Bourbon files already installed, doing nothing."
      else
        install_bourbon
        logger.info "Bourbon files installed to bourbon/"
      end
    end

    desc 'update', 'Update an existing Bourbon installation'
    method_option :verbose, aliases: '-V', desc: 'Talk through every step', type: :boolean, default: false
    def update(plugin_name = nil)
      if plugin_name
        update_plugin(plugin_name)
      elsif bourbon_files_already_exist?
        update_bourbon
        logger.info "Bourbon files updated."
      else
        logger.info "No existing bourbon installation. Doing nothing."
      end
    end

    private

    def bourbon_files_already_exist?
      File.directory?("bourbon")
    end

    def install_plugin(plugin_name)
      logger.info("Installing #{plugin_name}")
      installation_manager = InstallationManager.new(
        logger: logger,
        plugin_name: plugin_name,
        top_level_plugin_dir: top_level_plugin_dir)

      begin
        installation_manager.ensure_bourbon_installed
      rescue BourbonNotInstalled
        install_bourbon
      end

      begin
        installation_manager.ensure_plugin_directory
      rescue PluginNotInstalled
        logger.fatal <<-INSTALL_GEM
        You must install the #{plugin_name} gem first:

          gem install #{plugin_name}
          bourbon install #{plugin_name}
        INSTALL_GEM
      end

      installation_manager.ensure_extensions_installed
      installation_manager.ensure_stylesheets_installed
    end

    def update_plugin(plugin_name)
      logger.info("Installing #{plugin_name}")
      installation_manager = InstallationManager.new(
        logger: logger,
        plugin_name: plugin_name,
        top_level_plugin_dir: top_level_plugin_dir)

      installation_manager.remove_plugin

      begin
        installation_manager.ensure_bourbon_installed
      rescue BourbonNotInstalled
        install_bourbon
      end

      installation_manager.ensure_plugin_directory
      installation_manager.ensure_extensions_installed
      installation_manager.ensure_stylesheets_installed
    end

    def install_bourbon
      installation_manager = InstallationManager.new(
        logger: logger,
        plugin_name: 'bourbon',
        top_level_plugin_dir: top_level_plugin_dir)

      installation_manager.ensure_plugin_directory
      installation_manager.ensure_extensions_installed
      installation_manager.ensure_stylesheets_installed
    end

    def update_bourbon
      installation_manager = InstallationManager.new(
        logger: logger,
        plugin_name: 'bourbon',
        top_level_plugin_dir: top_level_plugin_dir)

      installation_manager.remove_plugin
      installation_manager.ensure_plugin_directory
      installation_manager.ensure_extensions_installed
      installation_manager.ensure_stylesheets_installed
    end

    def logger
      @logger ||= build_logger(ENV['DEBUG'] || options[:verbose])
    end

    def build_logger(debug)
      logger = Logger.new($stdout)
      logger.progname = 'bourbon'
      logger.level = debug ? Logger::DEBUG : Logger::INFO
      logger
    end

    def top_level_plugin_dir
      File.join(
        File.dirname(File.dirname(File.dirname(File.dirname(__FILE__)))),
        plugin_dir)
    end
  end
end
