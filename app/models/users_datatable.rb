# caged from http://railscasts.com/episodes/340-datatables
class UsersDatatable
  include TranslationTagHelper
  include Rails.application.routes.url_helpers
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i, # note this must be .to_i for security reasons
      iTotalRecords: User.without_role(:anonymous_traveler).count,
      iTotalDisplayRecords: User.without_role(:anonymous_traveler).count,
      aaData: data
    }
  end

private

  def data
    users.map do |user|
      [
        link_to(user.name, admin_user_path(user, locale: I18n.locale)),
        user.email,
        user.created_at.to_date,
        user.roles.collect(&:human_readable_name).to_sentence,
        user.deleted_at ? translate_w_tag_as_default(:user_deleted) : ''
      ]
    end
  end

  def users
    @users ||= fetch_users
  end

  def fetch_users
    users = User.order("#{sort_column} #{sort_direction}").limit(per_page).offset(page)
    users = users.where(deleted_at: nil) unless params[:bIncludeDeleted] == 'true'
    if sort_column == 'roles.name'
      users = users.includes(:roles)
    end
    if params[:sSearch].present?
      users = users.includes(:roles).where("UPPER(first_name) like :search or UPPER(email) like :search or UPPER(roles.name) like :search", search: "%#{params[:sSearch].upcase}%").references(:roles)
    end

    # puts users.to_sql
    users.without_role(:anonymous_traveler)
  end

  def page
    params[:iDisplayStart].to_i
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[users.first_name users.email users.created_at roles.name]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
