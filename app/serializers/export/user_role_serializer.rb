module Export
  class UserRoleSerializer < ExportSerializer

    attributes :name, :user_id, :resource_id, :resource_type
    
    def name
      object.role.try(:name)
    end
    
    def resource_id
      object.role.try(:resource_id)
    end
    
    def resource_type
      object.role.try(:resource_type)
    end

  end
end
