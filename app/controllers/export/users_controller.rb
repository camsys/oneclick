module Export
  class UsersController < Export::ExportApiController
    def registered
      @users = User.registered
      render json: @users.map{ |u| UserSerializer.new(u).serializable_hash }
    end
    
    def guests
      @users = User.where.not(id: User.registered.pluck(:id)).joins(:trips).uniq
      render json: @users.map{ |u| UserSerializer.new(u).serializable_hash }
    end
  end
end
