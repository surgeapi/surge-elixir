defmodule Surge.UsersFixtures do
  @moduledoc """
  Fixtures to help with testing Users.
  """

  def user_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "usr_01j9dwavghe1ttppewekjjkfrx",
      "first_name" => "Brian",
      "last_name" => "O'Conner",
      "metadata" => %{
        "email" => "boconner@toretti.family",
        "user_id" => 1234
      },
      "photo_url" => "https://toretti.family/people/brian.jpg"
    })
  end

  def minimal_user_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "usr_minimal123",
      "first_name" => "John"
    })
  end

  def user_without_name_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "usr_noname456",
      "metadata" => %{
        "internal_id" => "abc123"
      },
      "photo_url" => "https://example.com/photo.jpg"
    })
  end

  def user_with_complex_metadata_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "usr_complex789",
      "first_name" => "Letty",
      "last_name" => "Ortiz",
      "metadata" => %{
        "preferences" => %{
          "notifications" => true,
          "language" => "es"
        },
        "tags" => ["mechanic", "racer"],
        "score" => 9.8,
        "joined_at" => "2024-01-15T10:30:00Z"
      },
      "photo_url" => "https://toretti.family/people/letty.jpg"
    })
  end

  def user_with_nil_fields_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "usr_nilfields",
      "first_name" => nil,
      "last_name" => nil,
      "metadata" => nil,
      "photo_url" => nil
    })
  end

  def updated_user_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "usr_01j9dwavghe1ttppewekjjkfrx",
      "first_name" => "Brian",
      "last_name" => "O'Conner-Toretto",
      "metadata" => %{
        "email" => "brian@fbi.gov",
        "user_id" => 1234,
        "status" => "undercover"
      },
      "photo_url" => "https://fbi.gov/agents/brian.jpg"
    })
  end

  def token_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "token" =>
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoidXNyXzAxajlkd2F2Z2hlMXR0cHBld2VrampqZnJ4IiwiaWF0IjoxNzAzMDAwMDAwLCJleHAiOjE3MDMwMDM2MDB9.abc123xyz"
    })
  end
end
