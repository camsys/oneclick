module Export
  class UsersController < Export::ExportApiController
    def registered
      @users = User.registered
      render json: @users.map{ |u| UserSerializer.new(u).serializable_hash }
    end
    
    def guests

      batch_index = params[:batch_index].try(:to_i) || 0
      batch_size = params[:batch_size].try(:to_i) || 50

      @professinals = get_professionals
      @users = (User.where.not(id: User.registered.pluck(:id)).order(:id).limit(batch_size).offset(batch_size*batch_index).joins(:trips).uniq) - @professinals
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
