module Locomotive::Steam
  module Adapters
    module Filesystem
      module Sanitizers
        class Section

          include Adapters::Filesystem::Sanitizer

          def apply_to_entity(entity)
            super
            parse_json(entity)
          end

          private

          def parse_json(entity)
            content = File.read(entity.template_path)
            match   = content.match(JSON_FRONTMATTER_REGEXP)

            raise_parsing_error(entity, content) if match.nil?

            json, template = match[:json], match[:template]

            if defined?(Hjson)
              begin
                entity.definition = handle_aliases(Hjson.parse(json))
              rescue Hjson::Error => e
                raise Locomotive::Steam::JsonParsingError.new(e, path, json)
              end
            else
              begin
                entity.definition = handle_aliases(MultiJson.load(json))
              rescue MultiJson::ParseError => e
                raise Locomotive::Steam::JsonParsingError.new(e, path, json)
              end
            end

            entity.template = template
          end

          def handle_aliases(definition)
            # Dropzone presets -> presets
            if presets = definition.delete('dropzone_presets')
              definition['presets'] = presets
            end

            # Global content -> default
            if default = definition.delete('global_content')
              definition['default'] = default
            end

            definition['default'] ||= {}
            definition['default']['settings'] ||= {}

            # Fallback to use setting `default` key for section main settings, blocks already utilize this
            definition['settings'].each do |setting|
              if setting.key?('default') && !definition['default']['settings'].key?(setting['id'])
                definition['default']['settings'][setting['id']] = setting['default']
              end
            end

            definition
          end

          def raise_parsing_error(entity, content)
            message = 'Your section requires a valid JSON header'
            raise Locomotive::Steam::ParsingRenderingError.new(message, entity.template_path, content, 0, nil)
          end

        end
      end
    end
  end
end
