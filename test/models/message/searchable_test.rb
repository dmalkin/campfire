require "test_helper"

class Message::SearchableTest < ActiveSupport::TestCase
  test "message body is indexed and searchable" do
    message = rooms(:designers).messages.create! body: "My hovercraft is full of eels", client_message_id: "earth", creator: users(:david)
    assert_equal [ message ], rooms(:designers).messages.search("eel")

    message.update! body: "My hovercraft is full of sharks"
    assert_equal [ message ], rooms(:designers).messages.search("sharks")

    message.destroy!
    assert_equal [], rooms(:designers).messages.search("sharks")
  end

  test "rich text body is converted to plain text for indexing" do
    message = rooms(:designers).messages.create! body: "<span>My hovercraft is full of eels</span>", client_message_id: "earth", creator: users(:david)

    assert_equal [], rooms(:designers).messages.search("span")
    assert_equal [ message ], rooms(:designers).messages.search("eel")
  end
end
