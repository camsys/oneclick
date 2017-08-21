module Export
  class UsersController < Export::ExportApiController
    def registered
      @users = User.registered
      render json: @users.map{ |u| UserSerializer.new(u).serializable_hash }
    end
    
    def guests
      @professinals = User.with_any_role(
          {name: :provider_staff, resource: :any},
          :system_administrator
      )
      @users = (User.where.not(id: User.registered.pluck(:id)).joins(:trips).uniq) - @professinals
      render json: @users.map{ |u| UserSerializer.new(u).serializable_hash }
    end
    
    def professionals
      @users = User.with_any_role(
        {name: :provider_staff, resource: :any}, 
        :system_administrator
      )
      render json: @users.map{ |u| UserSerializer.new(u).serializable_hash }
    end
  end
end
