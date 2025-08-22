defmodule Surge.ContactsFixtures do
  @moduledoc """
  Fixtures to help with testing Contacts.
  """

  def contact_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "ctc_01j9dy8mdzfn3r0e8x1tbdrdrf",
      "email" => "dom@toretto.family",
      "first_name" => "Dominic",
      "last_name" => "Toretto",
      "metadata" => %{
        "car" => "1970 Dodge Charger R/T"
      },
      "phone_number" => "+18015551234"
    })
  end

  def minimal_contact_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "ctc_minimal123",
      "phone_number" => "+18015555678"
    })
  end

  def contact_without_phone_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "ctc_nophone456",
      "email" => "brian@oconner.gov",
      "first_name" => "Brian",
      "last_name" => "O'Conner"
    })
  end

  def contact_with_complex_metadata_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "ctc_complex789",
      "phone_number" => "+18015559999",
      "metadata" => %{
        "preferences" => %{
          "notifications" => true,
          "language" => "en"
        },
        "tags" => ["vip", "fast_and_furious"],
        "score" => 9.5
      }
    })
  end

  def contact_with_nil_fields_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "ctc_nilfields",
      "email" => nil,
      "first_name" => nil,
      "last_name" => nil,
      "metadata" => nil,
      "phone_number" => "+18015550000"
    })
  end

  def updated_contact_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "ctc_01j9dy8mdzfn3r0e8x1tbdrdrf",
      "email" => "dom@racewars.com",
      "first_name" => "Dom",
      "last_name" => "Toretto",
      "metadata" => %{
        "car" => "1970 Plymouth Road Runner",
        "crew" => "Family"
      },
      "phone_number" => "+18015554321"
    })
  end
end
