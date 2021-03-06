# encoding: UTF-8
module MongoMapper
  module Plugins
    module Associations
      class OneEmbeddedProxy < Proxy
        undef_method :object_id

        def build(attributes={})
          @target = klass.new(attributes)
          assign_references(@target)
          loaded
          @target
        end

        def replace(doc)
          if doc.respond_to?(:attributes)
            @target = klass.load(doc.attributes)
          else
            @target = klass.load(doc)
          end
          assign_references(@target)
          loaded
          @target
        end

        protected

          def find_target
            if @value
              klass.load(@value).tap do |child|
                assign_references(child)
              end
            end
          end

          def assign_references(doc)
            doc._parent_document = owner
          end
      end
    end
  end
end
