defmodule Surge.Events.MessageDeliveredTest do
  use ExUnit.Case, async: true

  alias Surge.Events.MessageDelivered
  alias Surge.Messages.Attachment
  alias Surge.Messages.Conversation
  alias Surge.Contacts.Contact
  alias Surge.PhoneNumbers.PhoneNumber

  import Surge.EventsFixtures

  describe "from_json/1" do
    test "parses complete message delivered event" do
      data = message_delivered_fixture()

      event = MessageDelivered.from_json(data)

      assert event.id == "msg_01jjnn7s0zfx5tdcsxjfy93et2"
      assert event.body == "Dude, I almost had you!"

      assert [%Attachment{} = attachment] = event.attachments
      assert attachment.id == "att_01jjnn75vgepj8bnnttfw1st5s"
      assert attachment.type == "image"
      assert attachment.url == "https://toretto.family/skyline.jpg"

      assert event.delivered_at == ~U[2024-10-21 23:29:42Z]

      assert %Conversation{} = event.conversation
      assert event.conversation.id == "cnv_01jav8xy7fe4nsay3c9deqxge9"

      assert event.conversation.phone_number.id == "pn_01jsjwe4d9fx3tpymgtg958d9w"
      assert event.conversation.phone_number.number == "+18015556789"
      assert event.conversation.phone_number.type == :local

      assert event.conversation.contact.email == "dom@toretto.family"
      assert event.conversation.contact.id == "ctc_01ja88cboqffhswjx8zbak3ykk"
      assert event.conversation.contact.first_name == "Dominic"
      assert event.conversation.contact.last_name == "Toretto"
      assert event.conversation.contact.metadata == %{"car" => "1970 Dodge Charger R/T"}
      assert event.conversation.contact.phone_number == "+18015551234"
    end

    test "handles minimal data with only id" do
      data = message_delivered_minimal_fixture()

      event = MessageDelivered.from_json(data)

      assert event.id == "msg_minimal123"
      assert is_nil(event.body)
      assert event.attachments == []
      assert is_nil(event.delivered_at)
      assert is_nil(event.conversation)
    end

    test "handles all nil values" do
      data = message_delivered_with_nulls_fixture()

      event = MessageDelivered.from_json(data)

      assert event.id == "msg_nulls456"
      assert is_nil(event.body)
      assert event.attachments == []
      assert is_nil(event.delivered_at)
      assert is_nil(event.conversation)
    end

    test "handles message with no attachments" do
      data = message_delivered_no_attachments_fixture()

      event = MessageDelivered.from_json(data)

      assert event.id == "msg_noatt789"
      assert event.body == "Just text, no attachments"
      assert event.attachments == []
      assert event.delivered_at == ~U[2024-10-22 10:15:30Z]

      assert event.conversation.id == "cnv_noatt012"
      assert event.conversation.phone_number.type == :toll_free
      assert event.conversation.contact.phone_number == "+14155552468"
    end

    test "handles message with multiple attachments" do
      data = message_delivered_multiple_attachments_fixture()

      event = MessageDelivered.from_json(data)

      assert event.id == "msg_multi901"
      assert event.body == "Check out these photos!"
      assert length(event.attachments) == 3

      [att1, att2, att3] = event.attachments

      assert att1.id == "att_image234"
      assert att1.type == "image"
      assert att1.url == "https://example.com/photo1.jpg"

      assert att2.id == "att_video567"
      assert att2.type == "video"
      assert att2.url == "https://example.com/video.mp4"

      assert att3.id == "att_audio890"
      assert att3.type == "audio"
      assert att3.url == "https://example.com/sound.mp3"

      assert event.delivered_at == ~U[2024-10-22 15:45:00Z]
      assert event.conversation.contact.first_name == "Mia"
    end

    test "handles invalid datetime gracefully" do
      data = message_delivered_invalid_datetime_fixture()

      event = MessageDelivered.from_json(data)

      assert event.id == "msg_baddate012"
      assert event.body == "Invalid date test"
      assert is_nil(event.delivered_at)
      assert event.conversation.id == "cnv_baddate345"
    end

    test "handles unknown attachment type gracefully" do
      data = message_delivered_unknown_attachment_type_fixture()

      event = MessageDelivered.from_json(data)

      assert event.id == "msg_unkatt234"
      assert event.body == "Unknown attachment type"

      assert [attachment] = event.attachments
      assert attachment.id == "att_unk567"
      # Type is preserved as string
      assert attachment.type == "unknown_type"
      assert attachment.url == "https://example.com/file.xyz"
    end

    test "handles extra fields in data" do
      data = message_delivered_with_extra_fields_fixture()

      event = MessageDelivered.from_json(data)

      assert event.id == "msg_extra345"
      assert event.body == "Message with extra fields"
      assert event.attachments == []
      assert event.delivered_at == ~U[2024-10-23 12:00:00Z]

      # Extra fields should be ignored
      refute Map.has_key?(event, :sent_at)
      refute Map.has_key?(event, :extra_field)
      refute Map.has_key?(event, :status)
    end

    test "handles empty map" do
      data = %{}

      event = MessageDelivered.from_json(data)

      assert is_nil(event.id)
      assert is_nil(event.body)
      assert event.attachments == []
      assert is_nil(event.delivered_at)
      assert is_nil(event.conversation)
    end

    test "handles datetime with offset" do
      data = %{
        "id" => "msg_offset123",
        "delivered_at" => "2024-10-23T12:30:45-07:00"
      }

      event = MessageDelivered.from_json(data)

      assert event.id == "msg_offset123"
      # Should convert to UTC
      assert event.delivered_at == ~U[2024-10-23 19:30:45Z]
    end

    test "matches example from module documentation" do
      data = %{
        "id" => "msg_01jjnn7s0zfx5tdcsxjfy93et2",
        "body" => "Dude, I almost had you!",
        "attachments" => [
          %{
            "id" => "att_01jjnn75vgepj8bnnttfw1st5s",
            "type" => "image",
            "url" => "https://toretto.family/skyline.jpg"
          }
        ],
        "delivered_at" => "2024-10-21T23:29:42Z",
        "conversation" => %{
          "id" => "cnv_01jav8xy7fe4nsay3c9deqxge9",
          "phone_number" => %{
            "id" => "pn_01jsjwe4d9fx3tpymgtg958d9w",
            "number" => "+18015556789",
            "type" => "local"
          },
          "contact" => %{
            "email" => "dom@toretto.family",
            "id" => "ctc_01ja88cboqffhswjx8zbak3ykk",
            "first_name" => "Dominic",
            "last_name" => "Toretto",
            "metadata" => %{
              "car" => "1970 Dodge Charger R/T"
            },
            "phone_number" => "+18015551234"
          }
        }
      }

      event = MessageDelivered.from_json(data)

      assert %MessageDelivered{
               id: "msg_01jjnn7s0zfx5tdcsxjfy93et2",
               body: "Dude, I almost had you!",
               attachments: [
                 %Attachment{
                   id: "att_01jjnn75vgepj8bnnttfw1st5s",
                   type: "image",
                   url: "https://toretto.family/skyline.jpg"
                 }
               ],
               delivered_at: ~U[2024-10-21 23:29:42Z],
               conversation: %Conversation{
                 id: "cnv_01jav8xy7fe4nsay3c9deqxge9",
                 phone_number: %PhoneNumber{
                   id: "pn_01jsjwe4d9fx3tpymgtg958d9w",
                   number: "+18015556789",
                   type: :local
                 },
                 contact: %Contact{
                   email: "dom@toretto.family",
                   id: "ctc_01ja88cboqffhswjx8zbak3ykk",
                   first_name: "Dominic",
                   last_name: "Toretto",
                   metadata: %{"car" => "1970 Dodge Charger R/T"},
                   phone_number: "+18015551234"
                 }
               }
             } = event
    end
  end
end

