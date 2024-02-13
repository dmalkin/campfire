class User < ApplicationRecord
  include Mentionable, Role, Transferable

  has_many :memberships, dependent: :delete_all
  has_many :rooms, through: :memberships

  has_many :reachable_messages, through: :rooms, source: :messages
  has_many :messages, dependent: :destroy, foreign_key: :creator_id

  has_many :push_subscriptions, class_name: "Push::Subscription", dependent: :delete_all

  has_many :boosts, dependent: :destroy, foreign_key: :booster_id
  has_many :searches, dependent: :delete_all

  has_many :sessions, dependent: :destroy

  scope :active, -> { where(active: true) }

  has_one_attached :avatar
  has_secure_password validations: false

  after_create_commit :grant_membership_to_open_rooms

  scope :ordered, -> { order("LOWER(name)") }
  scope :filtered_by, ->(query) { where("name like ?", "%#{query}%") }

  def initials
    name.scan(/\b\w/).join
  end

  def title
    [ name, bio ].compact_blank.join(" – ")
  end

  def deactivate
    transaction do
      close_remote_connections

      memberships.without_direct_rooms.delete_all
      push_subscriptions.delete_all
      searches.delete_all
      sessions.delete_all

      update! active: false, email_address: deactived_email_address
    end
  end

  def deactivated?
    !active?
  end

  private
    def grant_membership_to_open_rooms
      Rooms::Open.find_each { |room| room.memberships.grant_to self }
    end

    def deactived_email_address
      email_address.gsub(/@/, "-deactivated-#{SecureRandom.uuid}@")
    end

    def close_remote_connections
      ActionCable.server.remote_connections.where(current_user: self).disconnect reconnect: false
    end
end
