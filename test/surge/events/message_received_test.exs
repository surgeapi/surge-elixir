defmodule Surge.Events.MessageReceivedTest do
  use ExUnit.Case, async: true

  alias Surge.Events.MessageReceived
  alias Surge.Messages.Attachment
  alias Surge.Messages.Conversation
  alias Surge.Contacts.Contact
  alias Surge.PhoneNumbers.PhoneNumber

  import Surge.EventsFixtures

  describe "from_json/1" do
    test "parses complete message received event" do
      data = message_received_fixture()

      event = MessageReceived.from_json(data)

      assert event.id == "msg_01jav96823f9x9054d6gyzpp16"
      assert event.body == "I don't have friends, I got family."
      
      assert [%Attachment{} = attachment] = event.attachments
      assert attachment.id == "att_01jav8z6x1j4m1b3w8v2jz7j3r"
      assert attachment.type == "image"
      assert attachment.url == "https://toretto.family/image.jpg"
      
      assert event.received_at == ~U[2024-10-22 23:32:49Z]
      
      assert %Conversation{} = event.conversation
      assert event.conversation.id == "cnv_01jav8xy7fe4nsay3c9deqxge9"
      
      assert event.conversation.phone_number.id == "pn_01jsjwe4d9fx3tpymgtg958d9w"
      assert event.conversation.phone_number.number == "+18015556789"
      assert event.conversation.phone_number.type == :local
      
      assert event.conversation.contact.id == "ctc_01ja88cboqffhswjx8zbak3ykk"
      assert event.conversation.contact.first_name == "Dominic"
      assert event.conversation.contact.last_name == "Toretto"
      assert event.conversation.contact.phone_number == "+18015551234"
    end

    test "handles minimal data with only id" do
      data = message_received_minimal_fixture()

      event = MessageReceived.from_json(data)

      assert event.id == "msg_recv_minimal123"
      assert is_nil(event.body)
      assert event.attachments == []
      assert is_nil(event.received_at)
      assert is_nil(event.conversation)
    end

    test "handles all nil values" do
      data = message_received_with_nulls_fixture()

      event = MessageReceived.from_json(data)

      assert event.id == "msg_recv_nulls456"
      assert is_nil(event.body)
      assert event.attachments == []
      assert is_nil(event.received_at)
      assert is_nil(event.conversation)
    end

    test "handles message with no attachments" do
      data = message_received_no_attachments_fixture()

      event = MessageReceived.from_json(data)

      assert event.id == "msg_recv_noatt789"
      assert event.body == "Text only message from contact"
      assert event.attachments == []
      assert event.received_at == ~U[2024-10-23 09:15:30Z]
      
      assert event.conversation.id == "cnv_recv_noatt012"
      assert event.conversation.phone_number.type == :local
      assert event.conversation.contact.first_name == "Letty"
      assert event.conversation.contact.last_name == "Ortiz"
      assert event.conversation.contact.phone_number == "+14155552345"
    end

    test "handles invalid datetime gracefully" do
      data = %{
        "id" => "msg_baddate",
        "body" => "Test message",
        "received_at" => "not-a-valid-datetime"
      }

      event = MessageReceived.from_json(data)

      assert event.id == "msg_baddate"
      assert event.body == "Test message"
      assert is_nil(event.received_at)
    end

    test "handles datetime with offset" do
      data = %{
        "id" => "msg_offset",
        "received_at" => "2024-10-23T12:30:45-07:00"
      }

      event = MessageReceived.from_json(data)

      assert event.id == "msg_offset"
      # Should convert to UTC
      assert event.received_at == ~U[2024-10-23 19:30:45Z]
    end

    test "handles empty map" do
      data = %{}

      event = MessageReceived.from_json(data)

      assert is_nil(event.id)
      assert is_nil(event.body)
      assert event.attachments == []
      assert is_nil(event.received_at)
      assert is_nil(event.conversation)
    end

    test "handles partial conversation data" do
      data = %{
        "id" => "msg_partial",
        "body" => "Partial conversation",
        "received_at" => "2024-10-23T08:30:00Z",
        "conversation" => %{
          "id" => "cnv_partial"
        }
      }

      event = MessageReceived.from_json(data)

      assert event.id == "msg_partial"
      assert event.body == "Partial conversation"
      assert event.received_at == ~U[2024-10-23 08:30:00Z]
      assert event.conversation.id == "cnv_partial"
      assert is_nil(event.conversation.phone_number)
      assert is_nil(event.conversation.contact)
    end

    test "handles multiple attachments" do
      data = %{
        "id" => "msg_multi",
        "body" => "Multiple attachments",
        "attachments" => [
          %{
            "id" => "att_1",
            "type" => "image",
            "url" => "https://example.com/1.jpg"
          },
          %{
            "id" => "att_2",
            "type" => "video",
            "url" => "https://example.com/2.mp4"
          }
        ],
        "received_at" => "2024-10-22T15:45:00Z",
        "conversation" => %{
          "id" => "cnv_multi"
        }
      }

      event = MessageReceived.from_json(data)

      assert event.id == "msg_multi"
      assert event.body == "Multiple attachments"
      assert length(event.attachments) == 2
      
      [att1, att2] = event.attachments
      
      assert att1.id == "att_1"
      assert att1.type == "image"
      assert att1.url == "https://example.com/1.jpg"
      
      assert att2.id == "att_2"
      assert att2.type == "video"
      assert att2.url == "https://example.com/2.mp4"
    end

    test "handles extra fields in data" do
      data = %{
        "id" => "msg_extra",
        "body" => "Message with extra fields",
        "attachments" => [],
        "received_at" => "2024-10-23T12:00:00Z",
        "conversation" => %{
          "id" => "cnv_extra"
        },
        "extra_field" => "should be ignored",
        "status" => "received"
      }

      event = MessageReceived.from_json(data)

      assert event.id == "msg_extra"
      assert event.body == "Message with extra fields"
      
      # Extra fields should be ignored
      refute Map.has_key?(event, :extra_field)
      refute Map.has_key?(event, :status)
    end

    test "matches example from module documentation" do
      data = %{
        "id" => "msg_01jav96823f9x9054d6gyzpp16",
        "body" => "I don't have friends, I got family.",
        "attachments" => [
          %{
            "id" => "att_01jav8z6x1j4m1b3w8v2jz7j3r",
            "type" => "image",
            "url" => "https://toretto.family/image.jpg"
          }
        ],
        "received_at" => "2024-10-22T23:32:49Z",
        "conversation" => %{
          "id" => "cnv_01jav8xy7fe4nsay3c9deqxge9",
          "phone_number" => %{
            "id" => "pn_01jsjwe4d9fx3tpymgtg958d9w",
            "number" => "+18015556789",
            "type" => "local"
          },
          "contact" => %{
            "id" => "ctc_01ja88cboqffhswjx8zbak3ykk",
            "first_name" => "Dominic",
            "last_name" => "Toretto",
            "phone_number" => "+18015551234"
          }
        }
      }

      event = MessageReceived.from_json(data)

      assert %MessageReceived{
               id: "msg_01jav96823f9x9054d6gyzpp16",
               body: "I don't have friends, I got family.",
               attachments: [
                 %Attachment{
                   id: "att_01jav8z6x1j4m1b3w8v2jz7j3r",
                   type: "image",
                   url: "https://toretto.family/image.jpg"
                 }
               ],
               received_at: ~U[2024-10-22 23:32:49Z],
               conversation: %Conversation{
                 id: "cnv_01jav8xy7fe4nsay3c9deqxge9",
                 phone_number: %PhoneNumber{
                   id: "pn_01jsjwe4d9fx3tpymgtg958d9w",
                   number: "+18015556789",
                   type: :local
                 },
                 contact: %Contact{
                   id: "ctc_01ja88cboqffhswjx8zbak3ykk",
                   first_name: "Dominic",
                   last_name: "Toretto",
                   phone_number: "+18015551234"
                 }
               }
             } = event
    end
  end
end