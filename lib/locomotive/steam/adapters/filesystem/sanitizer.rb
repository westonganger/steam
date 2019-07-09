module Locomotive::Steam
  module Adapters
    module Filesystem

      module Sanitizer

        extend Forwardable

        def_delegators :@scope, :site, :locale, :locales, :default_locale

        attr_reader :scope, :site_path

        def initialize(site_path)
          @site_path = site_path
        end

        def setup(scope)
          @scope = scope
          self
        end

        def with(scope, &block)
          setup(scope)
          yield(self)
        end

        def apply_to(entity_or_dataset)
          if entity_or_dataset.respond_to?(:all)
            apply_to_dataset(entity_or_dataset)
          else
            apply_to_entity(entity_or_dataset)
          end
        end

        def apply_to_dataset(dataset)
          dataset
        end

        def apply_to_entity(entity)
          attach_site_to(entity)
          entity
        end

        def apply_to_entity_with_dataset(entity, dataset)
          entity
        end

        def attach_site_to(entity)
          entity[:site_id] = scope.site._id if scope.site
        end

        private

        def load_custom_setting_types
          @custom_setting_types ||= begin
            Dir.glob(File.join(site_path, 'config', 'custom_setting_types', "*.json")).map do |filepath|
              if File.exists?(path)
                json = File.read(path)

                begin
                  json = MultiJson.load(json)
                rescue MultiJson::ParseError => e
                  raise Locomotive::Steam::JsonParsingError.new(e, path, json)
                end
              else
                json = {}
              end

              slug = File.basename(filepath).split('.').first

              {
                type: slug,
                definition: json 
              }
            end
          end
        end

        alias :current_locale :locale

      end

    end
  end
end
