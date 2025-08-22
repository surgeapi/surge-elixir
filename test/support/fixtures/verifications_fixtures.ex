defmodule Surge.VerificationsFixtures do
  @moduledoc """
  Fixtures to help with testing Verifications.
  """

  def verification_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "vfn_01jayh15c2f2xamftg0xpyq1nj",
      "attempt_count" => 0,
      "phone_number" => "+18015551234",
      "status" => "pending"
    })
  end

  def verified_verification_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "vfn_01jayh15c2f2xamftg0xpyq1nj",
      "attempt_count" => 1,
      "phone_number" => "+18015551234",
      "status" => "verified"
    })
  end

  def exhausted_verification_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "vfn_01jayh15c2f2xamftg0xpyq1nj",
      "attempt_count" => 3,
      "phone_number" => "+18015551234",
      "status" => "exhausted"
    })
  end

  def expired_verification_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "vfn_01jayh15c2f2xamftg0xpyq1nj",
      "attempt_count" => 0,
      "phone_number" => "+18015551234",
      "status" => "expired"
    })
  end

  def minimal_verification_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "vfn_minimal123"
    })
  end

  def verification_with_nil_fields_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "vfn_nilfields",
      "attempt_count" => nil,
      "phone_number" => nil,
      "status" => nil
    })
  end

  def verification_with_unknown_status_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => "vfn_unknown",
      "attempt_count" => 0,
      "phone_number" => "+18015559999",
      "status" => "cancelled"
    })
  end

  def verification_check_ok_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "result" => "ok",
      "verification" => verified_verification_fixture()
    })
  end

  def verification_check_incorrect_pending_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "result" => "incorrect",
      "verification" => %{
        "id" => "vfn_01jayh15c2f2xamftg0xpyq1nj",
        "attempt_count" => 1,
        "phone_number" => "+18015551234",
        "status" => "pending"
      }
    })
  end

  def verification_check_incorrect_exhausted_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "result" => "incorrect",
      "verification" => exhausted_verification_fixture()
    })
  end

  def verification_check_expired_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "result" => "expired",
      "verification" => expired_verification_fixture()
    })
  end

  def verification_check_already_verified_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "result" => "already_verified",
      "verification" => verified_verification_fixture()
    })
  end

  def verification_check_with_nil_fields_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "result" => nil,
      "verification" => nil
    })
  end

  def verification_check_with_unknown_result_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "result" => "unknown_result",
      "verification" => verification_fixture()
    })
  end

  def verification_check_minimal_fixture(attrs \\ %{}) do
    Enum.into(attrs, %{
      "result" => "ok",
      "verification" => minimal_verification_fixture()
    })
  end
end
