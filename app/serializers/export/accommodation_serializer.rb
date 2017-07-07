module Export
  class AccommodationSerializer < ActiveModel::Serializer
    attributes :code,
               :name

    def self.collection_serialize(collection)
      ActiveModelSerializers::SerializableResource.new(collection, each_serializer: self)
    end

    def name; 'name is here' end
  end
end