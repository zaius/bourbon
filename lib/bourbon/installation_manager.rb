class BourbonNotInstalled < StandardError
end

class PluginNotInstalled < StandardError
end

class InstallationManager
  def initialize(args)
    @logger = args[:logger]
    @plugin_name = args[:plugin_name]
    @top_level_plugin_dir = args[:top_level_plugin_dir]
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
    if File.exist?(top_level_plugin_dir)
      FileUtils.mkdir_p(plugin_dir)
    else
      raise PluginNotInstalled
    end
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

  attr_reader :top_level_plugin_dir

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
    File.join('lib', "#{@plugin_name}.rb")
  end

  def sass_extensions_lib
    File.join(plugin_implementation_dir, 'sass_extensions.rb')
  end

  def sass_extensions_dir
    File.join(plugin_implementation_dir, 'sass_extensions')
  end

  def plugin_implementation_dir
    File.join('lib', @plugin_name)
  end

  def all_stylesheets
    Dir[File.join(stylesheets_directory, '*')]
  end

  def stylesheets_directory
    File.join(top_level_plugin_dir, plugin_dir, *%w(app assets stylesheets))
  end
end
