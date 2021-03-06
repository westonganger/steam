module Locomotive
  module Steam
    module Liquid
      module Tags

        class AltPageLinks < ::Liquid::Tag

          include Concerns::I18nPage

          def render(context)
            set_vars_from_context(context)

            if @site.locales.size == 1
              ''
            else
              (
                [%(<link rel="alternate" hreflang="x-default" href="#{url_for(@site.default_locale, true)}" />)] +
                @site.locales.map do |locale|
                  %(<link rel="alternate" hreflang="#{locale}" href="#{url_for(locale)}" />)
                end
              ).join("\n")
            end
          end

          private

          # Examples:
          # - http://www.example.com/fr (even if the default locale is fr)
          # - http://www.example.com/ (as the default url (x-default) for the index page)
          #
          # Note: the index page has a different behaviour because rendering "/" depends
          # on the language returned by the browser (so might be different based on the user session).
          def url_for(locale, default = false)
            change_page_locale(locale, @page) do
              fullpath = services.url_builder.url_for(@page.send(:_source), locale, @page.index? && !default ? true : nil)

              if @page.index? && default
                fullpath.gsub!(/\/#{locale}$/, '/')
              end

              @base_url + fullpath
            end
          end

          def services
            @context.registers[:services]
          end

          def set_vars_from_context(context)
            @context      = context
            @site         = context.registers[:site]
            @page         = context['page']
            @base_url     = context['base_url']
          end


        end

        ::Liquid::Template.register_tag('alt_page_links'.freeze, AltPageLinks)
      end
    end
  end
end
