defmodule Surge.Events.ConversationCreatedTest do
  use ExUnit.Case, async: true

  alias Surge.Events.ConversationCreated
  alias Surge.Contacts.Contact
  alias Surge.PhoneNumbers.PhoneNumber

  import Surge.EventsFixtures

  describe "from_json/1" do
    test "parses complete conversation created event" do
      data = conversation_created_fixture()

      event = ConversationCreated.from_json(data)

      assert event.id == "cnv_01jav8xy7fe4nsay3c9deqxge9"
      
      assert %PhoneNumber{} = event.phone_number
      assert event.phone_number.id == "pn_01jsjwe4d9fx3tpymgtg958d9w"
      assert event.phone_number.number == "+18015556789"
      assert event.phone_number.type == :local
      
      assert %Contact{} = event.contact
      assert event.contact.id == "ctc_01ja88cboqffhswjx8zbak3ykk"
      assert event.contact.first_name == "Dominic"
      assert event.contact.last_name == "Toretto"
      assert event.contact.phone_number == "+18015551234"
    end

    test "parses conversation with toll free number" do
      data = conversation_created_toll_free_fixture()

      event = ConversationCreated.from_json(data)

      assert event.id == "cnv_tollfree123"
      assert event.phone_number.id == "pn_tollfree456"
      assert event.phone_number.number == "+18885551234"
      assert event.phone_number.type == :toll_free
      assert event.contact.id == "ctc_tollfree789"
      assert event.contact.first_name == "Brian"
      assert event.contact.last_name == "O'Conner"
      assert event.contact.phone_number == "+13105554567"
    end

    test "handles minimal data with only id" do
      data = conversation_created_minimal_fixture()

      event = ConversationCreated.from_json(data)

      assert event.id == "cnv_minimal123"
      assert is_nil(event.phone_number)
      assert is_nil(event.contact)
    end

    test "handles all nil values" do
      data = conversation_created_with_nulls_fixture()

      event = ConversationCreated.from_json(data)

      assert event.id == "cnv_nulls456"
      assert is_nil(event.phone_number)
      assert is_nil(event.contact)
    end

    test "handles contact with full fields including metadata" do
      data = conversation_created_with_full_contact_fixture()

      event = ConversationCreated.from_json(data)

      assert event.id == "cnv_fullcontact789"
      
      assert event.phone_number.id == "pn_full012"
      assert event.phone_number.number == "+12125559876"
      assert event.phone_number.type == :local
      
      assert event.contact.id == "ctc_full345"
      assert event.contact.email == "letty@ortiz.family"
      assert event.contact.first_name == "Letty"
      assert event.contact.last_name == "Ortiz"
      assert event.contact.metadata == %{
        "car" => "Jensen Interceptor",
        "team" => "Fast Family"
      }
      assert event.contact.phone_number == "+14155557890"
    end

    test "handles unknown phone type gracefully" do
      data = conversation_created_unknown_phone_type_fixture()

      event = ConversationCreated.from_json(data)

      assert event.id == "cnv_unknown678"
      assert event.phone_number.id == "pn_unknown901"
      assert event.phone_number.number == "+19995551234"
      # Unknown type should be converted to nil
      assert is_nil(event.phone_number.type)
      assert event.contact.id == "ctc_unknown234"
      assert event.contact.phone_number == "+16175553456"
    end

    test "handles missing phone_number field" do
      data = conversation_created_missing_fields_fixture()

      event = ConversationCreated.from_json(data)

      assert event.id == "cnv_partial567"
      assert is_nil(event.phone_number)
      assert event.contact.id == "ctc_partial890"
      assert event.contact.phone_number == "+17135552468"
    end

    test "handles extra fields in data" do
      data = conversation_created_extra_fields_fixture()

      event = ConversationCreated.from_json(data)

      assert event.id == "cnv_extra123"
      
      # Extra fields in phone_number are handled by PhoneNumber.from_json
      assert event.phone_number.id == "pn_extra456"
      assert event.phone_number.number == "+18005557890"
      assert event.phone_number.type == :local
      
      assert event.contact.id == "ctc_extra789"
      assert event.contact.phone_number == "+12025551234"
      
      # Extra fields at root level should be ignored
      refute Map.has_key?(event, :created_at)
      refute Map.has_key?(event, :extra_field)
    end

    test "handles empty map" do
      data = %{}

      event = ConversationCreated.from_json(data)

      assert is_nil(event.id)
      assert is_nil(event.phone_number)
      assert is_nil(event.contact)
    end

    test "handles partial phone_number data" do
      data = %{
        "id" => "cnv_partial_phone",
        "phone_number" => %{
          "id" => "pn_partial123"
          # Missing number and type
        },
        "contact" => %{
          "id" => "ctc_partial456",
          "phone_number" => "+14155551234"
        }
      }

      event = ConversationCreated.from_json(data)

      assert event.id == "cnv_partial_phone"
      assert event.phone_number.id == "pn_partial123"
      assert is_nil(event.phone_number.number)
      assert is_nil(event.phone_number.type)
      assert event.contact.id == "ctc_partial456"
      assert event.contact.phone_number == "+14155551234"
    end

    test "handles partial contact data" do
      data = %{
        "id" => "cnv_partial_contact",
        "phone_number" => %{
          "id" => "pn_full789",
          "number" => "+18885559999",
          "type" => "toll_free"
        },
        "contact" => %{
          "id" => "ctc_partial012"
          # Missing all other fields
        }
      }

      event = ConversationCreated.from_json(data)

      assert event.id == "cnv_partial_contact"
      assert event.phone_number.id == "pn_full789"
      assert event.phone_number.number == "+18885559999"
      assert event.phone_number.type == :toll_free
      assert event.contact.id == "ctc_partial012"
      assert is_nil(event.contact.phone_number)
      assert is_nil(event.contact.first_name)
      assert is_nil(event.contact.last_name)
    end

    test "matches example from module documentation" do
      data = %{
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

      event = ConversationCreated.from_json(data)

      assert %ConversationCreated{
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
             } = event
    end
  end
end