# encoding: UTF-8
module MongoMapper
  module Plugins
    module Pagination
      class Proxy
        instance_methods.each { |m| undef_method m unless m =~ /(^__|^nil\?$|^send$|respond_to\?|proxy_|^object_id$)/ }

        attr_accessor :subject
        attr_reader :total_entries, :per_page, :current_page
        alias limit per_page

        def initialize(total_entries, current_page, per_page=nil)
          @total_entries    = total_entries.to_i
          self.per_page     = per_page
          self.current_page = current_page
        end

        def total_pages
          (total_entries / per_page.to_f).ceil
        end

        def out_of_bounds?
          current_page > total_pages
        end

        def previous_page
          current_page > 1 ? (current_page - 1) : nil
        end

        def next_page
          current_page < total_pages ? (current_page + 1) : nil
        end

        def skip
          (current_page - 1) * per_page
        end
        alias offset skip # for will paginate support

        def send(method, *args, &block)
          if respond_to?(method)
            super
          else
            subject.send(method, *args, &block)
          end
        end

        def ===(other)
          other === subject
        end

        def method_missing(name, *args, &block)
          @subject.send(name, *args, &block)
        end

        def respond_to?(name, *args, &block)
          super || @subject.respond_to?(name, *args, &block)
        end

        private
          def per_page=(value)
            value = 25 if value.blank?
            @per_page = value.to_i
          end

          def current_page=(value)
            value = value.to_i
            value = 1 if value < 1
            @current_page = value
          end
      end
    end
  end
end