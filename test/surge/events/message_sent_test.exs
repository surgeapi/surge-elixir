defmodule Surge.Events.MessageSentTest do
  use ExUnit.Case, async: true

  alias Surge.Events.MessageSent
  alias Surge.Messages.Attachment
  alias Surge.Messages.Conversation
  alias Surge.Contacts.Contact
  alias Surge.PhoneNumbers.PhoneNumber

  import Surge.EventsFixtures

  describe "from_json/1" do
    test "parses complete message sent event" do
      data = message_sent_fixture()

      event = MessageSent.from_json(data)

      assert event.id == "msg_01jjnn7s0zfx5tdcsxjfy93et2"
      assert event.body == "Dude, I almost had you!"
      
      assert [%Attachment{} = attachment] = event.attachments
      assert attachment.id == "att_01jjnn75vgepj8bnnttfw1st5s"
      assert attachment.type == "image"
      assert attachment.url == "https://toretto.family/skyline.jpg"
      
      assert event.sent_at == ~U[2024-10-21 23:29:41Z]
      
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
      data = message_sent_minimal_fixture()

      event = MessageSent.from_json(data)

      assert event.id == "msg_sent_minimal123"
      assert is_nil(event.body)
      assert event.attachments == []
      assert is_nil(event.sent_at)
      assert is_nil(event.conversation)
    end

    test "handles all nil values" do
      data = message_sent_with_nulls_fixture()

      event = MessageSent.from_json(data)

      assert event.id == "msg_sent_nulls456"
      assert is_nil(event.body)
      assert event.attachments == []
      assert is_nil(event.sent_at)
      assert is_nil(event.conversation)
    end

    test "handles invalid datetime gracefully" do
      data = %{
        "id" => "msg_baddate",
        "body" => "Test message",
        "sent_at" => "not-a-valid-datetime"
      }

      event = MessageSent.from_json(data)

      assert event.id == "msg_baddate"
      assert event.body == "Test message"
      assert is_nil(event.sent_at)
    end

    test "handles datetime with offset" do
      data = %{
        "id" => "msg_offset",
        "sent_at" => "2024-10-23T12:30:45-07:00"
      }

      event = MessageSent.from_json(data)

      assert event.id == "msg_offset"
      # Should convert to UTC
      assert event.sent_at == ~U[2024-10-23 19:30:45Z]
    end

    test "handles empty map" do
      data = %{}

      event = MessageSent.from_json(data)

      assert is_nil(event.id)
      assert is_nil(event.body)
      assert event.attachments == []
      assert is_nil(event.sent_at)
      assert is_nil(event.conversation)
    end

    test "handles partial conversation data" do
      data = %{
        "id" => "msg_partial",
        "body" => "Partial conversation",
        "sent_at" => "2024-10-23T08:30:00Z",
        "conversation" => %{
          "id" => "cnv_partial"
        }
      }

      event = MessageSent.from_json(data)

      assert event.id == "msg_partial"
      assert event.body == "Partial conversation"
      assert event.sent_at == ~U[2024-10-23 08:30:00Z]
      assert event.conversation.id == "cnv_partial"
      assert is_nil(event.conversation.phone_number)
      assert is_nil(event.conversation.contact)
    end

    test "handles message with no attachments" do
      data = %{
        "id" => "msg_noatt",
        "body" => "Just text",
        "attachments" => [],
        "sent_at" => "2024-10-22T10:15:30Z",
        "conversation" => %{
          "id" => "cnv_noatt",
          "phone_number" => %{
            "id" => "pn_noatt",
            "number" => "+18885551234",
            "type" => "toll_free"
          },
          "contact" => %{
            "id" => "ctc_noatt",
            "phone_number" => "+14155552468"
          }
        }
      }

      event = MessageSent.from_json(data)

      assert event.id == "msg_noatt"
      assert event.body == "Just text"
      assert event.attachments == []
      assert event.sent_at == ~U[2024-10-22 10:15:30Z]
      assert event.conversation.phone_number.type == :toll_free
      assert event.conversation.contact.phone_number == "+14155552468"
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
        "sent_at" => "2024-10-21T23:29:41Z",
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

      event = MessageSent.from_json(data)

      assert %MessageSent{
               id: "msg_01jjnn7s0zfx5tdcsxjfy93et2",
               body: "Dude, I almost had you!",
               attachments: [
                 %Attachment{
                   id: "att_01jjnn75vgepj8bnnttfw1st5s",
                   type: "image",
                   url: "https://toretto.family/skyline.jpg"
                 }
               ],
               sent_at: ~U[2024-10-21 23:29:41Z],
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