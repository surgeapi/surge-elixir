defmodule Surge.Events.EventTest do
  use ExUnit.Case, async: true

  alias Surge.Events.Event
  alias Surge.Events.{
    CallEnded,
    ConversationCreated,
    MessageDelivered,
    MessageFailed,
    MessageReceived,
    MessageSent
  }

  import Surge.EventsFixtures

  describe "from_json/1" do
    test "parses message.received event" do
      data = event_message_received_fixture()

      event = Event.from_json(data)

      assert event.account_id == "acct_01japd271aeatb7txrzr2xj8sg"
      assert event.type == :message_received
      assert %MessageReceived{} = event.data
      assert event.data.id == "msg_01jav96823f9x9054d6gyzpp16"
      assert event.data.body == "I don't have friends, I got family."
    end

    test "parses message.sent event" do
      data = event_message_sent_fixture()

      event = Event.from_json(data)

      assert event.account_id == "acct_01japd271aeatb7txrzr2xj8sg"
      assert event.type == :message_sent
      assert %MessageSent{} = event.data
      assert event.data.id == "msg_01jjnn7s0zfx5tdcsxjfy93et2"
      assert event.data.body == "Dude, I almost had you!"
    end

    test "parses message.delivered event" do
      data = event_message_delivered_fixture()

      event = Event.from_json(data)

      assert event.account_id == "acct_01japd271aeatb7txrzr2xj8sg"
      assert event.type == :message_delivered
      assert %MessageDelivered{} = event.data
      assert event.data.id == "msg_01jjnn7s0zfx5tdcsxjfy93et2"
      assert event.data.body == "Dude, I almost had you!"
    end

    test "parses message.failed event" do
      data = event_message_failed_fixture()

      event = Event.from_json(data)

      assert event.account_id == "acct_01japd271aeatb7txrzr2xj8sg"
      assert event.type == :message_failed
      assert %MessageFailed{} = event.data
      assert event.data.id == "msg_01jjnn7s0zfx5tdcsxjfy93et2"
      assert event.data.body == "Dude, I almost had you!"
      assert event.data.failure_reason == :carrier_error
    end

    test "parses call.ended event" do
      data = event_call_ended_fixture()

      event = Event.from_json(data)

      assert event.account_id == "acct_01japd271aeatb7txrzr2xj8sg"
      assert event.type == :call_ended
      assert %CallEnded{} = event.data
      assert event.data.id == "call_01jjnn7s0zfx5tdcsxjfy93et2"
      assert event.data.duration == 184
      assert event.data.status == :completed
    end

    test "parses conversation.created event" do
      data = event_conversation_created_fixture()

      event = Event.from_json(data)

      assert event.account_id == "acct_01japd271aeatb7txrzr2xj8sg"
      assert event.type == :conversation_created
      assert %ConversationCreated{} = event.data
      assert event.data.id == "cnv_01jav8xy7fe4nsay3c9deqxge9"
      assert event.data.phone_number.number == "+18015556789"
      assert event.data.contact.first_name == "Dominic"
    end

    test "handles minimal event data" do
      data = event_minimal_fixture()

      event = Event.from_json(data)

      assert event.account_id == "acct_minimal123"
      assert event.type == :message_received
      assert %MessageReceived{} = event.data
      assert event.data.id == "msg_minimal456"
      assert is_nil(event.data.body)
    end

    test "handles unknown event type" do
      data = event_unknown_type_fixture()

      event = Event.from_json(data)

      assert event.account_id == "acct_unknown789"
      assert is_nil(event.type)
      assert is_nil(event.data)
    end

    test "handles all nil values" do
      data = event_with_nulls_fixture()

      event = Event.from_json(data)

      assert is_nil(event.account_id)
      assert is_nil(event.type)
      assert is_nil(event.data)
    end

    test "handles missing data field" do
      data = event_missing_data_fixture()

      event = Event.from_json(data)

      assert event.account_id == "acct_nodata345"
      assert event.type == :message_received
      assert is_nil(event.data)
    end

    test "handles missing type field" do
      data = event_missing_type_fixture()

      event = Event.from_json(data)

      assert event.account_id == "acct_notype678"
      assert is_nil(event.type)
      assert is_nil(event.data)
    end

    test "handles empty map" do
      data = %{}

      event = Event.from_json(data)

      assert is_nil(event.account_id)
      assert is_nil(event.type)
      assert is_nil(event.data)
    end

    test "handles extra fields in wrapper" do
      data = %{
        "account_id" => "acct_extra123",
        "type" => "message.received",
        "data" => %{
          "id" => "msg_extra456"
        },
        "extra_field" => "should be ignored",
        "timestamp" => "2024-10-23T12:00:00Z"
      }

      event = Event.from_json(data)

      assert event.account_id == "acct_extra123"
      assert event.type == :message_received
      assert event.data.id == "msg_extra456"
      
      # Extra fields should be ignored
      refute Map.has_key?(event, :extra_field)
      refute Map.has_key?(event, :timestamp)
    end

    test "matches example from module documentation" do
      data = %{
        "account_id" => "acct_01japd271aeatb7txrzr2xj8sg",
        "type" => "message.received",
        "data" => %{
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
      }

      event = Event.from_json(data)

      assert %Event{
               account_id: "acct_01japd271aeatb7txrzr2xj8sg",
               type: :message_received,
               data: %MessageReceived{
                 id: "msg_01jav96823f9x9054d6gyzpp16",
                 body: "I don't have friends, I got family."
               }
             } = event

      # Verify nested data is parsed correctly
      assert length(event.data.attachments) == 1
      assert event.data.received_at == ~U[2024-10-22 23:32:49Z]
      assert event.data.conversation.id == "cnv_01jav8xy7fe4nsay3c9deqxge9"
      assert event.data.conversation.contact.first_name == "Dominic"
    end

    test "parses all event types correctly" do
      # Test each event type to ensure proper parsing
      event_types = [
        {"call.ended", :call_ended, CallEnded},
        {"conversation.created", :conversation_created, ConversationCreated},
        {"message.delivered", :message_delivered, MessageDelivered},
        {"message.failed", :message_failed, MessageFailed},
        {"message.received", :message_received, MessageReceived},
        {"message.sent", :message_sent, MessageSent}
      ]

      for {string_type, atom_type, module} <- event_types do
        data = %{
          "account_id" => "acct_test",
          "type" => string_type,
          "data" => %{"id" => "test_id"}
        }

        event = Event.from_json(data)

        assert event.account_id == "acct_test"
        assert event.type == atom_type
        assert %^module{} = event.data
        assert event.data.id == "test_id"
      end
    end
  end
end