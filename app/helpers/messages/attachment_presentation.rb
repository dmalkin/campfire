class Messages::AttachmentPresentation
  def initialize(message, context:)
    @message, @context = message, context
  end

  def render
    if message.attachment.attached?
      if message.attachment.previewable? || message.attachment.variable?
        render_preview
      else
        render_link
      end
    end
  end

  private
    attr_reader :message, :context
    delegate :tag, :link_to, :broadcast_image_tag, :rails_blob_path, :url_for, to: :context

    def render_preview
      if message.attachment.video?
        video_preview_tag
      else
        lightboxed_image_preview_tag
      end
    end

    def video_preview_tag
      width, height = preview_dimensions

      inline_media_dimension_constraints(width, height) do
        tag.video \
          src: rails_blob_path(message.attachment), poster: url_for(message.attachment.preview(format: :webp, resize_to_limit: [ Message::THUMBNAIL_MAX_WIDTH, Message::THUMBNAIL_MAX_HEIGHT ])),
          controls: true, preload: :none, width: "100%", height: "100%", class: "message__attachment"
      end
    end

    def lightboxed_image_preview_tag
      width, height = preview_dimensions

      inline_media_dimension_constraints(width, height) do
        lightbox_link do
          broadcast_image_tag message.attachment.representation(:thumb), width: width, height: height, class: "message__attachment", loading: "lazy"
        end
      end
    end

    def inline_media_dimension_constraints(width, height, &)
      if width && height
        aspect_ratio = (width / height.to_f)

        tag.div class: "max-inline-size center flex overflow-clip", style: "width: #{width / 2}px; aspect-ratio: #{aspect_ratio};", &
      else
        tag.div class: "max-inline-size center overflow-clip", &
      end
    end

    def preview_dimensions
      width = message.attachment.metadata[:width]
      height = message.attachment.metadata[:height]

      case
      when width.nil? || height.nil?
        [ nil, nil ]
      when width <= Message::THUMBNAIL_MAX_WIDTH && height <= Message::THUMBNAIL_MAX_HEIGHT
        [ width, height ]
      else
        width_factor = Message::THUMBNAIL_MAX_WIDTH.to_f / width
        height_factor = Message::THUMBNAIL_MAX_HEIGHT.to_f / height
        scale_factor = [ width_factor, height_factor ].min

        [ width * scale_factor, height * scale_factor ]
      end
    end

    def render_link
      tag.div class: "btn btn--plain" do
        broadcast_image_tag("common-file-text.svg", role: "presentation", class: "file-icon colorize--black") +
          download_link { message.attachment.filename.to_s }
      end
    end

    def lightbox_link(&)
      link_to rails_blob_path(message.attachment), class: "flex", data: {
        lightbox_target: "image", action: "lightbox#open", lightbox_url_value: rails_blob_path(message.attachment, disposition: "attachment", only_path: true) }, &
    end

    def download_link(&)
      link_to rails_blob_path(message.attachment, disposition: "attachment", only_path: true), &
    end
end
