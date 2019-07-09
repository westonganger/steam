module Locomotive::Steam
  module Adapters
    module Filesystem

      module JSONLoader

        extend Forwardable

        def_delegators :@scope

        attr_reader :site_path, :env

        def initialize(site_path, env = :local)
          @site_path, @env = site_path, env
        end

        def load(scope = nil)
          @scope = scope
        end

        def _load(path, &block)
          if File.exists?(path)
            json = File.open(path).read.force_encoding('utf-8')

            safe_json_load(json, path, &block)
          else
            Locomotive::Common::Logger.error "No #{path} file found"
            {}
          end
        end

        def safe_json_load(path)
          return {} unless File.exists?(path)

          json = File.read(path)

          begin
            MultiJson.load(json)
          rescue MultiJson::ParseError => e
            raise Locomotive::Steam::JsonParsingError.new(e, path, json)
          end
        end

        def template_extensions
          @extensions ||= %w(json)
        end

      end

    end
  end
end
