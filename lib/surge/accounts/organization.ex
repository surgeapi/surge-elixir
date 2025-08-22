defmodule Surge.Accounts.Organization do
  @moduledoc """
  The legal entity on whose behalf the account will be operated.
  """

  @type address :: %{
          name: String.t(),
          line1: String.t(),
          line2: String.t(),
          locality: String.t(),
          region: String.t(),
          postal_code: String.t(),
          country: String.t()
        }

  @type title :: :ceo | :cfo | :director | :gm | :vp | :general_counsel | :other

  @type contact :: %{
          email: String.t() | nil,
          first_name: String.t() | nil,
          last_name: String.t() | nil,
          phone_number: String.t() | nil,
          title: title() | nil,
          title_other: String.t() | nil
        }

  @type industry ::
          :agriculture
          | :automotive
          | :banking
          | :construction
          | :consumer
          | :education
          | :electronics
          | :energy
          | :engineering
          | :fast_moving_consumer_goods
          | :financial
          | :fintech
          | :food_and_beverage
          | :government
          | :healthcare
          | :hospitality
          | :insurance
          | :jewelry
          | :legal
          | :manufacturing
          | :media
          | :not_for_profit
          | :oil_and_gas
          | :online
          | :professional_services
          | :raw_materials
          | :real_estate
          | :religion
          | :retail
          | :technology
          | :telecommunications
          | :transportation
          | :travel

  @type organization_type ::
          :co_op
          | :government
          | :llc
          | :non_profit
          | :partnership
          | :private_corporation
          | :public_corporation
          | :sole_proprietor

  @type region ::
          :africa
          | :asia
          | :australia
          | :europe
          | :latin_america
          | :usa_and_canada

  @type stock_exchange ::
          :amex
          | :amx
          | :asx
          | :b3
          | :bme
          | :bse
          | :fra
          | :icex
          | :jpx
          | :jse
          | :krx
          | :lon
          | :nasdaq
          | :none
          | :nse
          | :nyse
          | :omx
          | :other
          | :sehk
          | :sgx
          | :sse
          | :sto
          | :swx
          | :szse
          | :tsx
          | :twse
          | :vse

  @type t :: %__MODULE__{
          address: address() | nil,
          contact: contact() | nil,
          country: String.t() | nil,
          email: String.t() | nil,
          identifier: String.t() | nil,
          identifier_type: :ein | nil,
          industry: industry() | nil,
          mobile_number: String.t() | nil,
          regions_of_operation: list(region()),
          registered_name: String.t() | nil,
          stock_exchange: stock_exchange() | nil,
          stock_symbol: String.t() | nil,
          type: organization_type() | nil,
          website: String.t() | nil
        }

  defstruct [
    :address,
    :contact,
    :country,
    :email,
    :identifier,
    :identifier_type,
    :industry,
    :mobile_number,
    :regions_of_operation,
    :registered_name,
    :stock_exchange,
    :stock_symbol,
    :type,
    :website
  ]

  @doc """
  Converts JSON response to Organization struct.

  ## Examples

      iex> data = %{"registered_name" => "ACME Corp", "type" => "llc"}
      iex> Surge.Accounts.Organization.from_json(data)
      %Surge.Accounts.Organization{registered_name: "ACME Corp", type: :llc}
  """
  @spec from_json(map()) :: t()
  def from_json(data) when is_map(data) do
    %__MODULE__{
      address: parse_address(data["address"]),
      contact: parse_contact(data["contact"]),
      country: data["country"],
      email: data["email"],
      identifier: data["identifier"],
      identifier_type: parse_identifier_type(data["identifier_type"]),
      industry: parse_industry(data["industry"]),
      mobile_number: data["mobile_number"],
      regions_of_operation: parse_regions_of_operation(data["regions_of_operation"]),
      registered_name: data["registered_name"],
      stock_exchange: parse_stock_exchange(data["stock_exchange"]),
      stock_symbol: data["stock_symbol"],
      type: parse_organization_type(data["type"]),
      website: data["website"]
    }
  end

  # Private

  @spec parse_address(map() | nil) :: address() | nil
  defp parse_address(nil), do: nil

  defp parse_address(address) when is_map(address) do
    %{
      name: address["name"],
      line1: address["line1"],
      line2: address["line2"],
      locality: address["locality"],
      region: address["region"],
      postal_code: address["postal_code"],
      country: address["country"]
    }
  end

  @spec parse_contact(map() | nil) :: contact() | nil
  defp parse_contact(nil), do: nil

  defp parse_contact(contact) when is_map(contact) do
    %{
      email: contact["email"],
      first_name: contact["first_name"],
      last_name: contact["last_name"],
      phone_number: contact["phone_number"],
      title: parse_title(contact["title"]),
      title_other: contact["title_other"]
    }
  end

  defp parse_identifier_type(nil), do: nil
  defp parse_identifier_type("ein"), do: :ein
  defp parse_identifier_type(_), do: nil

  @spec parse_industry(String.t() | nil) :: industry() | nil
  defp parse_industry(nil), do: nil
  defp parse_industry("agriculture"), do: :agriculture
  defp parse_industry("automotive"), do: :automotive
  defp parse_industry("banking"), do: :banking
  defp parse_industry("construction"), do: :construction
  defp parse_industry("consumer"), do: :consumer
  defp parse_industry("education"), do: :education
  defp parse_industry("electronics"), do: :electronics
  defp parse_industry("energy"), do: :energy
  defp parse_industry("engineering"), do: :engineering
  defp parse_industry("fast_moving_consumer_goods"), do: :fast_moving_consumer_goods
  defp parse_industry("financial"), do: :financial
  defp parse_industry("fintech"), do: :fintech
  defp parse_industry("food_and_beverage"), do: :food_and_beverage
  defp parse_industry("government"), do: :government
  defp parse_industry("healthcare"), do: :healthcare
  defp parse_industry("hospitality"), do: :hospitality
  defp parse_industry("insurance"), do: :insurance
  defp parse_industry("jewelry"), do: :jewelry
  defp parse_industry("legal"), do: :legal
  defp parse_industry("manufacturing"), do: :manufacturing
  defp parse_industry("media"), do: :media
  defp parse_industry("not_for_profit"), do: :not_for_profit
  defp parse_industry("oil_and_gas"), do: :oil_and_gas
  defp parse_industry("online"), do: :online
  defp parse_industry("professional_services"), do: :professional_services
  defp parse_industry("raw_materials"), do: :raw_materials
  defp parse_industry("real_estate"), do: :real_estate
  defp parse_industry("religion"), do: :religion
  defp parse_industry("retail"), do: :retail
  defp parse_industry("technology"), do: :technology
  defp parse_industry("telecommunications"), do: :telecommunications
  defp parse_industry("transportation"), do: :transportation
  defp parse_industry("travel"), do: :travel
  defp parse_industry(_), do: nil

  @spec parse_organization_type(String.t() | nil) :: organization_type() | nil
  defp parse_organization_type(nil), do: nil
  defp parse_organization_type("co_op"), do: :co_op
  defp parse_organization_type("government"), do: :government
  defp parse_organization_type("llc"), do: :llc
  defp parse_organization_type("non_profit"), do: :non_profit
  defp parse_organization_type("partnership"), do: :partnership
  defp parse_organization_type("private_corporation"), do: :private_corporation
  defp parse_organization_type("public_corporation"), do: :public_corporation
  defp parse_organization_type("sole_proprietor"), do: :sole_proprietor
  defp parse_organization_type(_), do: nil

  @spec parse_regions_of_operation(list(String.t()) | nil) :: list(region())
  defp parse_regions_of_operation(nil), do: []

  defp parse_regions_of_operation(regions) when is_list(regions) do
    regions
    |> Enum.map(&parse_region/1)
    |> Enum.reject(&is_nil/1)
  end

  @spec parse_region(String.t()) :: region() | nil
  defp parse_region("africa"), do: :africa
  defp parse_region("asia"), do: :asia
  defp parse_region("australia"), do: :australia
  defp parse_region("europe"), do: :europe
  defp parse_region("latin_america"), do: :latin_america
  defp parse_region("usa_and_canada"), do: :usa_and_canada
  defp parse_region(_), do: nil

  @spec parse_stock_exchange(String.t() | nil) :: stock_exchange() | nil
  defp parse_stock_exchange(nil), do: nil
  defp parse_stock_exchange("amex"), do: :amex
  defp parse_stock_exchange("amx"), do: :amx
  defp parse_stock_exchange("asx"), do: :asx
  defp parse_stock_exchange("b3"), do: :b3
  defp parse_stock_exchange("bme"), do: :bme
  defp parse_stock_exchange("bse"), do: :bse
  defp parse_stock_exchange("fra"), do: :fra
  defp parse_stock_exchange("icex"), do: :icex
  defp parse_stock_exchange("jpx"), do: :jpx
  defp parse_stock_exchange("jse"), do: :jse
  defp parse_stock_exchange("krx"), do: :krx
  defp parse_stock_exchange("lon"), do: :lon
  defp parse_stock_exchange("nasdaq"), do: :nasdaq
  defp parse_stock_exchange("none"), do: :none
  defp parse_stock_exchange("nse"), do: :nse
  defp parse_stock_exchange("nyse"), do: :nyse
  defp parse_stock_exchange("omx"), do: :omx
  defp parse_stock_exchange("other"), do: :other
  defp parse_stock_exchange("sehk"), do: :sehk
  defp parse_stock_exchange("sgx"), do: :sgx
  defp parse_stock_exchange("sse"), do: :sse
  defp parse_stock_exchange("sto"), do: :sto
  defp parse_stock_exchange("swx"), do: :swx
  defp parse_stock_exchange("szse"), do: :szse
  defp parse_stock_exchange("tsx"), do: :tsx
  defp parse_stock_exchange("twse"), do: :twse
  defp parse_stock_exchange("vse"), do: :vse
  defp parse_stock_exchange(_), do: nil

  @spec parse_title(String.t() | nil) :: title() | nil
  defp parse_title(nil), do: nil
  defp parse_title("ceo"), do: :ceo
  defp parse_title("cfo"), do: :cfo
  defp parse_title("director"), do: :director
  defp parse_title("gm"), do: :gm
  defp parse_title("vp"), do: :vp
  defp parse_title("general_counsel"), do: :general_counsel
  defp parse_title("other"), do: :other
  defp parse_title(_), do: nil
end
