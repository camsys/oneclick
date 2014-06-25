# For the user edit page, we need to roll up a user's relationships with another user into a single object for display
# Structure:
#   {
#     @base = <some user>
#     @other_users = {
#       <user record> => {
#         assistor: <record or nil>
#         assistee: <record or nil>
#   }
class UserRelationshipProxy
  attr_reader :me, :you, :i_can_assist, :can_assist_me

  def initialize(user1, user2)
    @me = user1 # think in terms of the buddy table in user profile.  "me" is the user whose profile it is.  "you" is any user with a relationship to "me"
    @you = user2
    find_traveler_relationship
    find_buddy_relationship
  end

  def find_traveler_relationship
    @i_can_assist = UserRelationship.find_by(traveler: @you, delegate: @me)
  end
  
  def find_buddy_relationship
    @can_assist_me = UserRelationship.find_by(traveler: @me, delegate: @you)
  end

  def active?
    rtn = false
    if @i_can_assist
      rtn ||= @i_can_assist.active?
    end
    if @can_assist_me
      rtn ||= @can_assist_me.active?
    end
    rtn
  end

end