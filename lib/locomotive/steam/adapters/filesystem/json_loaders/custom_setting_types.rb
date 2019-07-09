module Locomotive
  module Steam
    module Adapters
      module Filesystem
        module JSONLoaders
          class CustomSettingTypes

            include Adapters::Filesystem::JSONLoader

            def load(scope)
              super
              load_list
            end

            private

            def load_list
              Dir.glob(File.join(path, "*.{#{template_extensions.join(',')}}")).map do |filepath|
                slug = File.basename(filepath).split('.').first

                {
                  type: slug,
                  json: _load(filepath)
                }
              end
            end

            def path
              @path ||= File.join(site_path, 'config', 'custom_setting_types')
            end

          end
        end
      end
    end
  end
end
