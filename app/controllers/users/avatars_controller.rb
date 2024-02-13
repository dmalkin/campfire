class Users::AvatarsController < ApplicationController
  include ActiveStorage::Streaming

  def show
    @user = User.find(params[:user_id])

    if stale?(etag: @user)
      expires_in 30.minutes, public: true, stale_while_revalidate: 1.week

      if @user.avatar.attached?
        avatar_variant = @user.avatar.variant(SQUARE_WEBP_VARIANT).processed
        send_webp_blob_file avatar_variant.key
      else
        render_initials
      end
    end
  end

  def destroy
    Current.user.avatar.destroy
    redirect_to user_profile_url
  end

  private
    SQUARE_WEBP_VARIANT = { resize_to_limit: [ 512, 512 ], format: :webp }

    def send_webp_blob_file(key)
      send_file ActiveStorage::Blob.service.path_for(key), content_type: "image/webp", disposition: :inline
    end

    def render_initials
      render formats: :svg
    end
end
