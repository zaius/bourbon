require "fileutils"
require 'bourbon/installation_manager'
require 'logger'

module Bourbon
  class Generator
    def initialize(arguments, debug)
      @subcommand = arguments.first
      @logger = build_logger(debug)
    end

    def run
      if @subcommand == "install"
        install
      elsif @subcommand == "update"
        update
      end
    end

    def update
      if bourbon_files_already_exist?
        update_files
        @logger.info "Bourbon files updated."
      else
        @logger.info "No existing bourbon installation. Doing nothing."
      end
    end

    def install
      if bourbon_files_already_exist?
        @logger.info "Bourbon files already installed, doing nothing."
      else
        install_files
        @logger.info "Bourbon files installed to bourbon/"
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
      InstallationManager.new(logger: @logger, plugin_name: 'bourbon')
    end

    def build_logger(debug)
      logger = Logger.new($stdout)
      logger.progname = 'bourbon'
      logger.level = debug ? Logger::DEBUG : Logger::INFO
      logger
    end
  end
end
