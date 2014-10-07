COMMENT_ATTRIBUTES = [:comment, :locale, :visibility, :id, :_destroy]

module Admin::CommentsHelper

  def setup_comments commentable
    %w{public private}.each do |visibility|
      method = "#{visibility}_comments".to_sym
      (I18n.available_locales.map(&:to_s) - commentable.send(method).pluck(:locale)).each do |loc|
        commentable.send(method).build locale: loc
      end
    end
  end

  def fixup_comments_attributes_for_delete commentable
    [:public_comments_attributes, :private_comments_attributes].each do |t|
      if params[commentable].include? t
        params[commentable][t].each do |k, v|
          # k is the (artificial) index, v is the hash with the form values
          if v[:comment].blank? && v.include?(:id)
            v[:_destroy] = 1
          end
        end
      end
    end
  end

end
