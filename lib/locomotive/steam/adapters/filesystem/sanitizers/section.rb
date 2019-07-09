module Locomotive::Steam
  module Adapters
    module Filesystem
      module Sanitizers
        class Section

          include Adapters::Filesystem::Sanitizer

          attr_reader :custom_setting_types

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
                raise Locomotive::Steam::JsonParsingError.new(e, entity.template_path, json)
              end
            else
              begin
                entity.definition = handle_aliases(MultiJson.load(json))
              rescue MultiJson::ParseError => e
                raise Locomotive::Steam::JsonParsingError.new(e, entity.template_path, json)
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
            definition['default']['blocks'] ||= []
            definition['default']['blocks'].each_index do |i|
              definition['default']['blocks'][i]['settings'] ||= {}
            end
            definition['blocks'] ||= []
            definition['blocks'].each_index do |i|
              definition['blocks'][i]['settings'] ||= {}
            end

            # Fallback to use setting `default` key for Standalone/Global section settings and block settings
            definition['settings'].each do |setting|
              if setting.key?('default') && !definition['default']['settings'].key?(setting['id'])
                definition['default']['settings'][setting['id']] = setting['default']
              end
            end

            definition['default']['blocks'].each_with_index do |default_block, i|
              type_block_def = definition['blocks'].detect{|x| x['type'] == default_block['type']}

              if type_block_def
                type_block_def['settings'].each do |setting|
                  if setting.key?('default') && !default_block['settings'].key?(setting['id'])
                    definition['default']['blocks'][i]['settings'][setting['id']] = setting['default']
                  end
                end
              end
            end

            # Handle Custom Setting Types
            load_custom_setting_types

            if @custom_setting_types.present?
              if definition['settings'].present?
                definition['settings'].each_with_index do |setting, i|
                  if setting['type'].present?
                    custom_setting_type = @custom_setting_types.detect{|x| x['type'] == setting['type']}

                    if custom_setting_type
                      definition['settings'][i] = custom_setting_type['definition'].merge(setting)
                    end
                  end
                end
              end

              if definition['blocks'].present?
                definition['blocks'].each_with_index do |block_def, i|
                  if block_def['settings'].present?
                    block_def['settings'].each_with_index do |setting, i2|
                      if setting['type'].present?
                        custom_setting_type = @custom_setting_types.detect{|x| x['type'] == setting['type']}

                        if custom_setting_type
                          definition['blocks'][i]['settings'][i2] = custom_setting_type['definition'].merge(setting)
                        end
                      end
                    end
                  end
                end
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
