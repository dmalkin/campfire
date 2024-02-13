class Rooms::ClosedsController < RoomsController
  before_action :force_room_type, only: %i[ edit update ]

  DEFAULT_ROOM_NAME = "New room"

  def show
    redirect_to room_url(@room)
  end

  def new
    @room  = Rooms::Closed.new(name: DEFAULT_ROOM_NAME)
    @users = User.active.ordered
  end

  def create
    room = Rooms::Closed.create_for(room_params, users: grantees)

    broadcast_create_room(room)
    redirect_to room_url(room)
  end

  def edit
    selected_user_ids = @room.users.pluck(:id)
    @selected_users, @unselected_users = User.active.ordered.partition { |user| selected_user_ids.include?(user.id) }
  end

  def update
    @room.update! room_params
    @room.memberships.revise(granted: grantees, revoked: revokees)

    broadcast_update_room
    redirect_to room_url(@room)
  end

  private
    # Allows us to edit an open room and turn it into a closed one on saving.
    def force_room_type
      @room = @room.becomes!(Rooms::Closed)
    end

    def grantees
      User.where(id: grantee_ids)
    end

    def revokees
      @room.users.where.not(id: grantee_ids)
    end

    def grantee_ids
      params.fetch(:user_ids, [])
    end

    def broadcast_create_room(room)
      # Optimization so we don't have to render the same shared room per user
      new_room_html = render_to_string(partial: "users/sidebars/rooms/shared", locals: { room: room })

      room.users.each do |user|
        broadcast_prepend_to user, :rooms, target: :shared_rooms, html: new_room_html
      end
    end

    def broadcast_update_room
      broadcast_replace_to :rooms, target: [ @room, :list ], partial: "users/sidebars/rooms/shared", locals: { room: @room }
    end
end
