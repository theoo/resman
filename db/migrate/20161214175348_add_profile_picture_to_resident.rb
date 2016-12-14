class AddProfilePictureToResident < ActiveRecord::Migration
  def up
    add_attachment :residents, :profile_picture
  end

  def down
    remove_attachment :residents, :profile_picture
  end
end
