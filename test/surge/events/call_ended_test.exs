defmodule Surge.Events.CallEndedTest do
  use ExUnit.Case, async: true

  alias Surge.Events.CallEnded
  alias Surge.Contacts.Contact

  import Surge.EventsFixtures

  describe "from_json/1" do
    test "parses complete call ended event with completed status" do
      data = call_ended_fixture()

      event = CallEnded.from_json(data)

      assert event.id == "call_01jjnn7s0zfx5tdcsxjfy93et2"
      assert %Contact{} = event.contact
      assert event.contact.id == "ctc_01ja88cboqffhswjx8zbak3ykk"
      assert event.contact.phone_number == "+18015551234"
      assert event.duration == 184
      assert event.initiated_at == ~U[2025-03-31 21:01:37Z]
      assert event.status == :completed
    end

    test "parses call ended event with busy status" do
      data = call_ended_busy_fixture()

      event = CallEnded.from_json(data)

      assert event.id == "call_busy123"
      assert event.contact.id == "ctc_busy456"
      assert event.contact.phone_number == "+14155552468"
      assert event.duration == 0
      assert event.initiated_at == ~U[2025-03-31 22:15:00Z]
      assert event.status == :busy
    end

    test "parses call ended event with canceled status" do
      data = call_ended_canceled_fixture()

      event = CallEnded.from_json(data)

      assert event.id == "call_canceled789"
      assert event.contact.id == "ctc_cancel012"
      assert event.contact.phone_number == "+12125553690"
      assert event.duration == 5
      assert event.initiated_at == ~U[2025-03-31 23:30:45Z]
      assert event.status == :canceled
    end

    test "parses call ended event with failed status" do
      data = call_ended_failed_fixture()

      event = CallEnded.from_json(data)

      assert event.id == "call_failed345"
      assert event.contact.id == "ctc_fail678"
      assert event.contact.phone_number == "+13105554812"
      assert event.duration == 0
      assert event.initiated_at == ~U[2025-04-01 00:45:00Z]
      assert event.status == :failed
    end

    test "parses call ended event with missed status" do
      data = call_ended_missed_fixture()

      event = CallEnded.from_json(data)

      assert event.id == "call_missed901"
      assert event.contact.id == "ctc_miss234"
      assert event.contact.phone_number == "+16175555024"
      assert event.duration == 0
      assert event.initiated_at == ~U[2025-04-01 01:00:00Z]
      assert event.status == :missed
    end

    test "parses call ended event with no_answer status" do
      data = call_ended_no_answer_fixture()

      event = CallEnded.from_json(data)

      assert event.id == "call_noanswer567"
      assert event.contact.id == "ctc_noanswer890"
      assert event.contact.phone_number == "+17135556136"
      assert event.duration == 0
      assert event.initiated_at == ~U[2025-04-01 02:15:30Z]
      assert event.status == :no_answer
    end

    test "handles minimal data with only id" do
      data = call_ended_minimal_fixture()

      event = CallEnded.from_json(data)

      assert event.id == "call_minimal123"
      assert is_nil(event.contact)
      assert is_nil(event.duration)
      assert is_nil(event.initiated_at)
      assert is_nil(event.status)
    end

    test "handles all nil values" do
      data = call_ended_with_nulls_fixture()

      event = CallEnded.from_json(data)

      assert event.id == "call_nulls456"
      assert is_nil(event.contact)
      assert is_nil(event.duration)
      assert is_nil(event.initiated_at)
      assert is_nil(event.status)
    end

    test "handles invalid datetime gracefully" do
      data = call_ended_invalid_datetime_fixture()

      event = CallEnded.from_json(data)

      assert event.id == "call_baddate789"
      assert event.contact.id == "ctc_baddate012"
      assert event.contact.phone_number == "+18005557248"
      assert event.duration == 100
      assert is_nil(event.initiated_at)
      assert event.status == :completed
    end

    test "handles unknown status gracefully" do
      data = call_ended_unknown_status_fixture()

      event = CallEnded.from_json(data)

      assert event.id == "call_unknown345"
      assert event.contact.id == "ctc_unknown678"
      assert event.contact.phone_number == "+19005558360"
      assert event.duration == 50
      assert event.initiated_at == ~U[2025-04-01 03:30:00Z]
      assert is_nil(event.status)
    end

    test "handles contact with extra fields" do
      data = call_ended_with_extra_contact_fields_fixture()

      event = CallEnded.from_json(data)

      assert event.id == "call_extra901"
      assert event.contact.id == "ctc_extra234"
      assert event.contact.phone_number == "+12025559472"
      # Extra fields in contact are handled by Contact.from_json
      assert event.duration == 300
      assert event.initiated_at == ~U[2025-04-01 04:45:00Z]
      assert event.status == :completed
    end

    test "handles empty map" do
      data = %{}

      event = CallEnded.from_json(data)

      assert is_nil(event.id)
      assert is_nil(event.contact)
      assert is_nil(event.duration)
      assert is_nil(event.initiated_at)
      assert is_nil(event.status)
    end

    test "handles missing fields" do
      data = %{
        "id" => "call_partial123",
        "duration" => 60
      }

      event = CallEnded.from_json(data)

      assert event.id == "call_partial123"
      assert is_nil(event.contact)
      assert event.duration == 60
      assert is_nil(event.initiated_at)
      assert is_nil(event.status)
    end

    test "preserves timezone information in datetime" do
      data = %{
        "id" => "call_tz123",
        "initiated_at" => "2025-04-01T12:30:45.123456Z"
      }

      event = CallEnded.from_json(data)

      assert event.id == "call_tz123"
      assert event.initiated_at == ~U[2025-04-01 12:30:45.123456Z]
    end

    test "handles datetime with offset" do
      data = %{
        "id" => "call_offset123",
        "initiated_at" => "2025-04-01T12:30:45-07:00"
      }

      event = CallEnded.from_json(data)

      assert event.id == "call_offset123"
      # Should convert to UTC
      assert event.initiated_at == ~U[2025-04-01 19:30:45Z]
    end

    test "matches example from module documentation" do
      data = %{
        "id" => "call_01jjnn7s0zfx5tdcsxjfy93et2",
        "contact" => %{
          "id" => "ctc_01ja88cboqffhswjx8zbak3ykk",
          "phone_number" => "+18015551234"
        },
        "duration" => 184,
        "initiated_at" => "2025-03-31T21:01:37Z",
        "status" => "completed"
      }

      event = CallEnded.from_json(data)

      assert %CallEnded{
               id: "call_01jjnn7s0zfx5tdcsxjfy93et2",
               contact: %Contact{
                 id: "ctc_01ja88cboqffhswjx8zbak3ykk",
                 phone_number: "+18015551234"
               },
               duration: 184,
               initiated_at: ~U[2025-03-31 21:01:37Z],
               status: :completed
             } = event
    end
  end
end