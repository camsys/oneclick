module Export
  class UsersController < Export::ExportApiController
    def registered
      @users = User.registered
      render json: @users.map{ |u| UserSerializer.new(u).serializable_hash }
    end
    
    def guests
      @professinals = get_professionals
      @users = (User.where.not(id: User.registered.pluck(:id)).joins(:trips).uniq) - @professinals
      render json: @users.map{ |u| UserSerializer.new(u).serializable_hash }
    end
    
    def professionals
      @users = get_professionals
      render json: @users.map{ |u| UserSerializer.new(u).serializable_hash }
    end

    protected

    def get_professionals
      User.with_any_role(
          {name: :provider_staff, resource: :any},
          :system_administrator
      )
    end
  end
end
