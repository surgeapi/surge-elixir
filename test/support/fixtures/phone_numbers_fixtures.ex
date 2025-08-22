defmodule Surge.PhoneNumbersFixtures do
  @moduledoc """
  Fixtures to help with testing PhoneNumbers.
  """

  def phone_number_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "pn_01jsjwe4d9fx3tpymgtg958d9w",
      "number" => "+18015551234",
      "type" => "local"
    })
  end

  def toll_free_phone_number_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "pn_tollfree123",
      "number" => "+18885551234",
      "type" => "toll_free"
    })
  end

  def minimal_phone_number_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "pn_minimal456"
    })
  end

  def phone_number_with_unknown_type_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "pn_unknown789",
      "number" => "+18015559999",
      "type" => "international"
    })
  end

  def phone_number_with_nil_fields_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "pn_nilfields",
      "number" => nil,
      "type" => nil
    })
  end
end
