class CreateFeedIdConfig < ActiveRecord::Migration
  def change
    oc = OneclickConfiguration.where(code: "first_feed_id").first_or_initialize
    oc.value = 1
    oc.save
  end
end
