defmodule Surge.Events.MessageFailedTest do
  use ExUnit.Case, async: true

  alias Surge.Events.MessageFailed
  alias Surge.Messages.Attachment
  alias Surge.Messages.Conversation
  alias Surge.Contacts.Contact
  alias Surge.PhoneNumbers.PhoneNumber

  import Surge.EventsFixtures

  describe "from_json/1" do
    test "parses complete message failed event with carrier_error" do
      data = message_failed_fixture()

      event = MessageFailed.from_json(data)

      assert event.id == "msg_01jjnn7s0zfx5tdcsxjfy93et2"
      assert event.body == "Dude, I almost had you!"
      
      assert [%Attachment{} = attachment] = event.attachments
      assert attachment.id == "att_01jjnn75vgepj8bnnttfw1st5s"
      assert attachment.type == "image"
      assert attachment.url == "https://toretto.family/skyline.jpg"
      
      assert event.failed_at == ~U[2024-10-21 23:29:42Z]
      assert event.failure_reason == :carrier_error
      
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

    test "parses invalid_number failure reason" do
      data = message_failed_invalid_number_fixture()

      event = MessageFailed.from_json(data)

      assert event.id == "msg_invalid123"
      assert event.body == "Test message"
      assert event.failed_at == ~U[2024-10-22 10:00:00Z]
      assert event.failure_reason == :invalid_number
      assert event.conversation.phone_number.type == :toll_free
      assert event.conversation.contact.phone_number == "+19999999999"
    end

    test "parses blocked failure reason" do
      data = message_failed_blocked_fixture()

      event = MessageFailed.from_json(data)

      assert event.id == "msg_blocked345"
      assert event.body == "Blocked message"
      assert event.failed_at == ~U[2024-10-22 11:00:00Z]
      assert event.failure_reason == :blocked
      assert event.conversation.id == "cnv_blocked678"
      assert is_nil(event.conversation.phone_number)
      assert is_nil(event.conversation.contact)
    end

    test "parses spam_detected failure reason" do
      data = message_failed_spam_detected_fixture()

      event = MessageFailed.from_json(data)

      assert event.id == "msg_spam901"
      assert event.body == "Free money!!! Click here!!!"
      assert event.failed_at == ~U[2024-10-22 12:00:00Z]
      assert event.failure_reason == :spam_detected
    end

    test "parses rate_limited failure reason" do
      data = message_failed_rate_limited_fixture()

      event = MessageFailed.from_json(data)

      assert event.id == "msg_rate567"
      assert event.body == "Too many messages"
      assert event.failed_at == ~U[2024-10-22 13:00:00Z]
      assert event.failure_reason == :rate_limited
    end

    test "handles unknown failure reason gracefully" do
      data = message_failed_unknown_reason_fixture()

      event = MessageFailed.from_json(data)

      assert event.id == "msg_unknown123"
      assert event.body == "Unknown failure"
      assert event.failed_at == ~U[2024-10-22 14:00:00Z]
      assert is_nil(event.failure_reason)
    end

    test "handles minimal data with only id" do
      data = %{"id" => "msg_minimal"}

      event = MessageFailed.from_json(data)

      assert event.id == "msg_minimal"
      assert is_nil(event.body)
      assert event.attachments == []
      assert is_nil(event.conversation)
      assert is_nil(event.failed_at)
      assert is_nil(event.failure_reason)
    end

    test "handles all nil values" do
      data = %{
        "id" => "msg_nulls",
        "body" => nil,
        "attachments" => nil,
        "conversation" => nil,
        "failed_at" => nil,
        "failure_reason" => nil
      }

      event = MessageFailed.from_json(data)

      assert event.id == "msg_nulls"
      assert is_nil(event.body)
      assert event.attachments == []
      assert is_nil(event.conversation)
      assert is_nil(event.failed_at)
      assert is_nil(event.failure_reason)
    end

    test "handles invalid datetime gracefully" do
      data = %{
        "id" => "msg_baddate",
        "body" => "Test",
        "failed_at" => "not-a-valid-datetime",
        "failure_reason" => "carrier_error"
      }

      event = MessageFailed.from_json(data)

      assert event.id == "msg_baddate"
      assert event.body == "Test"
      assert is_nil(event.failed_at)
      assert event.failure_reason == :carrier_error
    end

    test "handles datetime with offset" do
      data = %{
        "id" => "msg_offset",
        "failed_at" => "2024-10-23T12:30:45-07:00",
        "failure_reason" => "blocked"
      }

      event = MessageFailed.from_json(data)

      assert event.id == "msg_offset"
      # Should convert to UTC
      assert event.failed_at == ~U[2024-10-23 19:30:45Z]
      assert event.failure_reason == :blocked
    end

    test "handles empty map" do
      data = %{}

      event = MessageFailed.from_json(data)

      assert is_nil(event.id)
      assert is_nil(event.body)
      assert event.attachments == []
      assert is_nil(event.conversation)
      assert is_nil(event.failed_at)
      assert is_nil(event.failure_reason)
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
        },
        "failed_at" => "2024-10-21T23:29:42Z",
        "failure_reason" => "carrier_error"
      }

      event = MessageFailed.from_json(data)

      assert %MessageFailed{
               id: "msg_01jjnn7s0zfx5tdcsxjfy93et2",
               body: "Dude, I almost had you!",
               attachments: [
                 %Attachment{
                   id: "att_01jjnn75vgepj8bnnttfw1st5s",
                   type: "image",
                   url: "https://toretto.family/skyline.jpg"
                 }
               ],
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
               },
               failed_at: ~U[2024-10-21 23:29:42Z],
               failure_reason: :carrier_error
             } = event
    end
  end
end