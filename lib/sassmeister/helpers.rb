require 'sassmeister/redis'

module SassMeister
  module Helpers
    def get_frontmatter_dependencies(sass)
      frontmatter = sass.scan(/^\/\/ ([\w\s]+?) \(v([[:alnum:]\.]+?)\)\s*$/)

      dependencies = {}

      unless frontmatter.empty?
        frontmatter.each {|name, version| dependencies[name] = version}
      end

      return dependencies
    end


    def pack_dependencies(sass, dependencies)
      sass.slice!(/(^\/\/ [\-]{3,4}\n(?:\/\/ .+\n)*\/\/ [\-]{3,4}\s*)*/)

      if dependencies.has_key?('libsass')
        frontmatter = "// ----\n// libsass (v#{dependencies.delete('libsass')})\n// ----"

      else
        frontmatter = "// ----\n// Sass (sass-version)\n// Compass (compass-version)\n// ----"

        frontmatter.gsub!(/sass-version/, "v#{dependencies.delete('Sass')}")
        frontmatter.gsub!(/compass-version/, "v#{dependencies.delete('Compass')}")
      end

      dependencies.each {|name, version| frontmatter.gsub!(/\/\/ ----\Z/, "// #{name} (v#{version})\n// ----") }

      return frontmatter
    end


    def app_last_modified
      return @mtime ||= File.mtime(__FILE__) if settings.environment == :production

      Time.now
    end


    def origin
      return request.env["HTTP_ORIGIN"] if origin_allowed? request.env["HTTP_ORIGIN"]

      return false
    end


    def origin_allowed?(uri)
      return false if uri.nil?

      return uri.match(/^http:\/\/(.+\.){0,1}sassmeister\.(com|dev|((\d+\.){4}xip\.io))/)
    end

    def compiler_menu
      @compiler_menu ||= get_compiler_menu

      @compiler_menu if @compiler_menu
    end

    def get_compiler_menu
      html = SassMeister::Redis.new 'compiler_menu'
      
      if html.value.empty?
        build_compiler_menu
      else
        html.value
      end
    end

    def build_compiler_menu
      compilers = SassMeister::Redis.new 'compilers'

      return false if compilers.value.empty?

      html = erb :'shared/_compiler_menu', locals: {compilers: compilers.value}, layout: false

      compiler_menu = SassMeister::Redis.new 'compiler_menu'
      compiler_menu.set html

      html
    end


    def extension_info_list
      @extension_info_list ||= get_extension_info_list

      @extension_info_list if @extension_info_list
    end

    def get_extension_info_list
      html = SassMeister::Redis.new 'extension_info_list'
      
      if html.value.empty?
        build_extension_info_list
      else
        html.value
      end
    end

    def build_extension_info_list
      extensions = SassMeister::Redis.new 'extensions'

      return false if extensions.value.empty?

      html = erb :'shared/_extension_info_list', locals: {extensions: extensions.value}, layout: false

      extension_info_list = SassMeister::Redis.new 'extension_info_list'
      extension_info_list.set html

      html
    end
  end
end

