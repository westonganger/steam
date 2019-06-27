module Locomotive
  module Steam
    module Liquid
      module Filters

        module Array

          def pop(array, input = 1)
            return array unless array.is_a?(::Array)
            new_ary = array.dup
            new_ary.pop(input.to_i || 1)
            new_ary
          end

          def push(array, input)
            return array unless array.is_a?(::Array)
            new_ary = array.dup
            new_ary.push(input)
            new_ary
          end

          def shift(array, input = 1)
            return array unless array.is_a?(::Array)
            new_ary = array.dup
            new_ary.shift(input.to_i || 1)
            new_ary
          end

          def unshift(array, input)
            return array unless array.is_a?(::Array)
            new_ary = array.dup
            new_ary.unshift(*input)
            new_ary
          end

          # Group an array of items by a property
          #
          # input - the inputted Enumerable
          # property - the property
          #
          # Returns an array of Hashes, each looking something like this:
          #  {"name"  => "larry"
          #   "items" => [...] } # all the items where `property` == "larry"
          def group_by(input, property)
            if groupable?(input)
              groups = input.group_by { |item| item_property(item, property).to_s }
              grouped_array(groups)
            else
              input
            end
          end

          # Group an array of items by an expression
          #
          # input - the object array
          # variable - the variable to assign each item to in the expression
          # expression -a Liquid comparison expression passed in as a string
          #
          # Returns the filtered array of objects
          def group_by_exp(input, variable, expression)
            return input unless groupable?(input)

            parsed_expr = parse_expression(expression)
            @context.stack do
              groups = input.group_by do |item|
                @context[variable] = item
                parsed_expr.render(@context)
              end
              grouped_array(groups)
            end
          end

          private

          def parse_expression(str)
            Liquid::Variable.new(str, Liquid::ParseContext.new)
          end

          def groupable?(element)
            element.respond_to?(:group_by)
          end

          def grouped_array(groups)
            groups.each_with_object([]) do |item, array|
              array << {
                "name"  => item.first,
                "items" => item.last,
                "size"  => item.last.size,
              }
            end
          end

        end

        ::Liquid::Template.register_filter(Array)

      end
    end
  end
end
