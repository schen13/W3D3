# == Schema Information
#
# Table name: shortened_urls
#
#  id        :bigint(8)        not null, primary key
#  long_url  :string           not null
#  short_url :string           not null
#  user_id   :integer          not null
#

class ShortenedUrl < ApplicationRecord
  validates :long_url, :short_url, presence: true, uniqueness: true
  validates :user_id, presence: true
  
  belongs_to :submitter,
    primary_key: :id,
    foreign_key: :user_id,
    class_name: :User
  
  has_many :visits,
    primary_key: :id,
    foreign_key: :url_id,
    class_name: :Visit
    
  has_many :visitors,
    through: :visits,
    source: :visitor
    
  def self.make_short_url(user_object, long_url)
    p code = ShortenedUrl.random_code
    self.create!(long_url: long_url, short_url: code, user_id: user_object.id)
  end  
  
  def num_clicks
    visits.count
  end
  
  def num_uniques
    # visits.select(:user_id).distinct.count
  end
  
  def num_recent_uniques
    visits.select(:user_id).distinct.where("(Time.now - visits.created_at) / 60 < 10").count
  end
    
  private
  
  def self.random_code
    code = SecureRandom.urlsafe_base64[0..15]
    while self.exists?(:short_url => code)
      code = SecureRandom.urlsafe_base64[0..15]
    end
    code
  end
end
