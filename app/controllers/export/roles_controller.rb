module Export
  class RolesController < Export::ExportApiController
    def index
      render json: UserRole.professional.map{ |ur| UserRoleSerializer.new(ur).serializable_hash }
    end
  end
end
