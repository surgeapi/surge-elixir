defmodule Surge.PhoneNumbers.PhoneNumberTest do
  use ExUnit.Case, async: true

  alias Surge.PhoneNumbers.PhoneNumber

  import Surge.PhoneNumbersFixtures

  describe "from_json/1" do
    test "parses local phone number" do
      data = phone_number_fixture()

      phone_number = PhoneNumber.from_json(data)

      assert phone_number.id == "pn_01jsjwe4d9fx3tpymgtg958d9w"
      assert phone_number.number == "+18015551234"
      assert phone_number.type == :local
    end

    test "parses toll_free phone number" do
      data = toll_free_phone_number_fixture()

      phone_number = PhoneNumber.from_json(data)

      assert phone_number.id == "pn_tollfree123"
      assert phone_number.number == "+18885551234"
      assert phone_number.type == :toll_free
    end

    test "handles nil type" do
      data = %{
        "id" => "pn_notype",
        "number" => "+18015555678",
        "type" => nil
      }

      phone_number = PhoneNumber.from_json(data)

      assert phone_number.id == "pn_notype"
      assert phone_number.number == "+18015555678"
      assert is_nil(phone_number.type)
    end

    test "handles unknown type" do
      data = phone_number_with_unknown_type_fixture()

      phone_number = PhoneNumber.from_json(data)

      assert phone_number.id == "pn_unknown789"
      assert phone_number.number == "+18015559999"
      # Unknown type should be parsed as nil
      assert is_nil(phone_number.type)
    end

    test "handles nil number" do
      data = %{
        "id" => "pn_nonumber",
        "number" => nil,
        "type" => "local"
      }

      phone_number = PhoneNumber.from_json(data)

      assert phone_number.id == "pn_nonumber"
      assert is_nil(phone_number.number)
      assert phone_number.type == :local
    end

    test "handles all nil fields" do
      data = phone_number_with_nil_fields_fixture()

      phone_number = PhoneNumber.from_json(data)

      assert phone_number.id == "pn_nilfields"
      assert is_nil(phone_number.number)
      assert is_nil(phone_number.type)
    end

    test "handles empty map" do
      data = %{}

      phone_number = PhoneNumber.from_json(data)

      assert is_nil(phone_number.id)
      assert is_nil(phone_number.number)
      assert is_nil(phone_number.type)
    end

    test "handles complete phone number data from OpenAPI spec" do
      data = %{
        "id" => "pn_01jsjwe4d9fx3tpymgtg958d9w",
        "number" => "+18015552345",
        "type" => "local"
      }

      phone_number = PhoneNumber.from_json(data)

      assert phone_number.id == "pn_01jsjwe4d9fx3tpymgtg958d9w"
      assert phone_number.number == "+18015552345"
      assert phone_number.type == :local
    end

    test "handles minimal phone number with only id" do
      data = minimal_phone_number_fixture()

      phone_number = PhoneNumber.from_json(data)

      assert phone_number.id == "pn_minimal456"
      assert is_nil(phone_number.number)
      assert is_nil(phone_number.type)
    end
  end
end
