require "fileutils"
require 'bourbon/installation_manager'
require 'logger'
require 'thor'

module Bourbon
  class Generator < Thor
    desc 'install', 'Install Bourbon or a Bourbon plugin'
    def install
      if bourbon_files_already_exist?
        logger.info "Bourbon files already installed, doing nothing."
      else
        install_files
        logger.info "Bourbon files installed to bourbon/"
      end
    end

    desc 'update', 'Update an existing Bourbon installation'
    def update
      if bourbon_files_already_exist?
        update_files
        logger.info "Bourbon files updated."
      else
        logger.info "No existing bourbon installation. Doing nothing."
      end
    end

    private

    def bourbon_files_already_exist?
      File.directory?("bourbon")
    end

    def install_files
      installation_manager.ensure_plugin_directory
      installation_manager.ensure_extensions_installed
      installation_manager.ensure_stylesheets_installed
    end

    def update_files
      installation_manager.remove_plugin
      install_files
    end

    def installation_manager
      InstallationManager.new(logger: logger, plugin_name: 'bourbon')
    end

    def logger
      @logger ||= build_logger(ENV['DEBUG'])
    end

    def build_logger(debug)
      logger = Logger.new($stdout)
      logger.progname = 'bourbon'
      logger.level = debug ? Logger::DEBUG : Logger::INFO
      logger
    end
  end
end
