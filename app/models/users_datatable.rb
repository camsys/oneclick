# caged from http://railscasts.com/episodes/340-datatables
class UsersDatatable
  include Rails.application.routes.url_helpers
  delegate :params, :h, :link_to, :check_box_tag, to: :@view

  def initialize(view)
    @view = view
  end

  def valid_users
    users = User.without_role(:anonymous_traveler)

    users = users.where(deleted_at: nil) unless params[:bIncludeDeleted] == 'true'
  end

  def as_json(options = {})
    total_count = valid_users.count

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
      TranslationEngine.translate_text(:id),
      TranslationEngine.translate_text(:username),
      TranslationEngine.translate_text(:email),
      TranslationEngine.translate_text(:registered),
      TranslationEngine.translate_text(:roles),
      TranslationEngine.translate_text(:status),
      TranslationEngine.translate_text(:provider),
      TranslationEngine.translate_text(:agency)
    ]
  end

  def export_plain_single_user(user)
    [
      user.id,
      user.name,
      user.email,
      user.created_at.to_date,
      user.roles.collect(&:human_readable_name).to_sentence,
      user.deleted_at ? TranslationEngine.translate_text(:user_deleted) : '',
      user.provider.try(:name).to_s,
      user.agency.try(:name).to_s
    ]
  end

  def paged_users_data
    paged_users.map do |user|
      [
        check_box_tag("recipient-#{user.id}", 1, false, {
          class: 'message-checkbox', 
          data: { id: user.id }
        }),
        user.id,
        link_to(user.name, admin_user_path(user, locale: I18n.locale)),
        user.email,
        user.created_at.to_date,
        user.roles.collect(&:human_readable_name).to_sentence,
        user.deleted_at ? TranslationEngine.translate_text(:user_deleted) : '',
        user.provider.try(:name).to_s,
        user.agency.try(:name).to_s
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

  def fetch_users(users)
    case sort_column
    when 'roles.name'
      users = users.includes(:roles)
    when 'agencies.name'
      users = users.includes(:agency)
    when 'providers.name'
      users = users.includes(:provider)
    end

    if params[:sSearch].present?
      users = users.includes(:roles, :provider, :agency).where(
        "UPPER(first_name) like :search or UPPER(users.email) like :search or UPPER(roles.name) like :search or " +
        "UPPER(providers.name) like :search or UPPER(agencies.name) like :search", 
        search: "%#{params[:sSearch].upcase}%").references(:roles, :provider, :agency)
    end

    users
  end

  def fetch_paged_users
    users = valid_users.order("#{sort_column} #{sort_direction}").limit(per_page).offset(page)
    fetch_users(users)
  end

  def fetch_all_users
    users = valid_users.order("#{sort_column} #{sort_direction}")
    fetch_users(users)
  end

  def page
    params[:iDisplayStart].to_i
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    if params[:iSortCol_0].to_i < 1
      sort_column_id = 0
    else
      sort_column_id = params[:iSortCol_0].to_i - 1
    end
    columns = %w[users.id users.first_name users.email users.created_at roles.name users.deleted_at providers.name agencies.name]
    columns[sort_column_id]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
