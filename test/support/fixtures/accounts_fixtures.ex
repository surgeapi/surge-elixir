defmodule Surge.AccountsFixtures do
  @moduledoc """
  Fixtures to help with testing Accounts.
  """

  def account_fixture(attrs) do
    {organization_attrs, attrs} = Map.pop(attrs, "organization", %{})

    Enum.into(attrs, %{
      "id" => nil,
      "name" => nil,
      "time_zone" => nil,
      "organization" => organization_fixture(organization_attrs),
      "brand_name" => nil
    })
  end

  def organization_fixture(attrs) do
    {address_attrs, attrs} = Map.pop(attrs, "address", %{})
    {contact_attrs, attrs} = Map.pop(attrs, "contact", %{})

    Enum.into(attrs, %{
      "registered_name" => nil,
      "type" => nil,
      "address" => address_fixture(address_attrs),
      "identifier" => nil,
      "email" => nil,
      "contact" => contact_fixture(contact_attrs),
      "country" => nil,
      "industry" => nil,
      "regions_of_operation" => [],
      "identifier_type" => nil,
      "stock_exchange" => nil,
      "stock_symbol" => nil,
      "website" => nil,
      "mobile_number" => nil
    })
  end

  def address_fixture(attrs) do
    Enum.into(attrs, %{
      "name" => nil,
      "line1" => nil,
      "region" => nil,
      "country" => nil,
      "line2" => nil,
      "locality" => nil,
      "postal_code" => nil
    })
  end

  def contact_fixture(attrs) do
    Enum.into(attrs, %{
      "title" => nil,
      "email" => nil,
      "first_name" => nil,
      "last_name" => nil,
      "phone_number" => nil,
      "title_other" => nil
    })
  end
end
