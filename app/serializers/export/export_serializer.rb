module Export
  class ExportSerializer < ActiveModel::Serializer

    def self.uniquize_attribute(attr)
      define_method(attr) do
        return "#{object.send(attr)}$$#{object.id}"
      end
    end
    
  end
end
