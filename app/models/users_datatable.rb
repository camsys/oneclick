# caged from http://railscasts.com/episodes/340-datatables
class UsersDatatable
  include Rails.application.routes.url_helpers
  delegate :params, :h, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    total_count = User.without_role(:anonymous_traveler).where(deleted_at: nil).count

    json = {
      sEcho: params[:sEcho].to_i, # note this must be .to_i for security reasons
      iTotalRecords: total_count,
      iTotalDisplayRecords: total_count,
      aaData: paged_users_data
    }
  end

  def as_csv
    CSV.generate do |csv|
      csv << UsersDatatable.localized_column_names
      paged_users_plain_data.each do |user|
        csv << user
      end
    end
  end

  def as_csv_all(csv)
    csv << UsersDatatable.localized_column_names.to_csv
    all_users.find_each do |user|
      csv << export_plain_single_user(user).to_csv
    end
  end

private
  def self.localized_column_names
    [
      I18n.t(:id),
      I18n.t(:username),
      I18n.t(:email),
      I18n.t(:registered),
      I18n.t(:roles),
      I18n.t(:status)
    ]
  end

  def export_plain_single_user(user)
    [
      user.id,
      user.name,
      user.email,
      user.created_at.to_date,
      user.roles.collect(&:human_readable_name).to_sentence,
      user.deleted_at ? I18n.t(:user_deleted) : ''
    ]
  end

  def paged_users_data
    paged_users.map do |user|
      [
        user.id,
        link_to(user.name, admin_user_path(user, locale: I18n.locale)),
        user.email,
        user.created_at.to_date,
        user.roles.collect(&:human_readable_name).to_sentence,
        user.deleted_at ? I18n.t(:user_deleted) : ''
      ]
    end
  end

  # plain user data
  def export_plain_user(users = [])
    users.map do |user|
      export_plain_single_user user
    end
  end

  def paged_users_plain_data
    export_plain_user(paged_users)
  end

  def all_users_plain_data
    export_plain_user(all_users)
  end

  def paged_users
    @users ||= fetch_paged_users
  end

  def all_users
    @users ||= fetch_all_users
  end

  def fetch_users(users = User.all)
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

  def fetch_paged_users
    users = User.order("#{sort_column} #{sort_direction}").limit(per_page).offset(page)
    fetch_users(users)
  end

  def fetch_all_users
    users = User.order("#{sort_column} #{sort_direction}")
    fetch_users(users)
  end

  def page
    params[:iDisplayStart].to_i
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[users.id users.first_name users.email users.created_at roles.name users.deleted_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
