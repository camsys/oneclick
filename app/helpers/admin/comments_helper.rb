module Admin::CommentsHelper

  COMMENT_ATTRIBUTES = [:comment, :locale, :visibility, :id, :_destroy]

  def setup_comments commentable
    %w{public private}.each do |visibility|
      method = "#{visibility}_comments".to_sym
      (I18n.available_locales.map(&:to_s) - commentable.send(method).pluck(:locale)).each do |loc|
        commentable.send(method).build locale: loc
      end
    end
  end

end