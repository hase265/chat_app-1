class User < ActiveRecord::Base
  has_many :messages
  has_many :accesses
  has_many :from_user_friendships, class_name: 'Friendship', foreign_key: 'from_user_id',
           dependent: :destroy
  has_many :friends_from_user, through: :from_user_friendships, source: 'to_user'
  has_many :to_user_friendships, class_name: 'Friendship', foreign_key: 'to_user_id',
           dependent: :destroy
  has_many :friends_to_user, through: :to_user_friendships, source: 'from_user'

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validates :name, presence: true, uniqueness: true

  def set_image(file)
    return if file.nil?
    file_name = Time.zone.now.to_i.to_s + file.original_filename
    File.open("public/user_images/#{file_name}", "wb") {|f|f.write(file.read)}
    self.image = file_name
  end

  def make_friend_with(user)
    from_user_friendships.find_or_create_by(to_user_id: user.id)
  end

  def break_off_friend(user)
      friendship = from_user_friendships.find_by(to_user_id: user.id) || to_user_friendships.find_by(from_user_id: user.id)
      friendship.destroy if from_user_friendships
  end

  def find_friendship_for(user_id)
    from_user_friendship = from_user_friendships.find_by(to_user_id: user_id)
    to_user_friendship = to_user_friendships.find_by(from_user_id: user_id)
    if from_user_friendship
      from_user_friendship.to_user
    else
      to_user_friendship.from_user
    end
  end

  def friends_all
    friends_to_user + friends_from_user
  end

  def friend?(user)
    self.from_friend?(user) || self.to_friend?(user)
  end

  def from_friend?(user)
    friends_from_user.include?(user)
  end

  def to_friend?(user)
    friends_to_user.include?(user)
  end
end
