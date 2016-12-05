class SetModePriority < ActiveRecord::Migration
  def change
    Rake::Task["oneclick:one_offs:set_mode_priority"].invoke
  end
end
