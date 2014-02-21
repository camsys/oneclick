require_relative '20131203203453_create_cms'

class RevertComfyMexicanSofa < ActiveRecord::Migration
  def change
  	revert CreateCms
  end
end
