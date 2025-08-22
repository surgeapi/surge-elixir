defmodule Surge.Accounts.OrganizationTest do
  use ExUnit.Case, async: true

  alias Surge.Accounts.Organization

  describe "from_json/1" do
    test "parses complete organization data" do
      data = %{
        "registered_name" => "DT Precision Auto LLC",
        "type" => "llc",
        "country" => "US",
        "identifier_type" => "ein",
        "identifier" => "123456789",
        "industry" => "automotive",
        "website" => "https://dtprecisionauto.com",
        "regions_of_operation" => ["usa_and_canada", "latin_america"],
        "stock_exchange" => "nyse",
        "stock_symbol" => "DTPA",
        "email" => "dom@dtprecisionauto.com",
        "mobile_number" => "+13235556439",
        "address" => %{
          "name" => "DT Precision Auto",
          "line1" => "2640 Huron St",
          "line2" => "Suite 100",
          "locality" => "Los Angeles",
          "region" => "CA",
          "postal_code" => "90065",
          "country" => "US"
        },
        "contact" => %{
          "first_name" => "Dominic",
          "last_name" => "Toretto",
          "email" => "dom@dtprecisionauto.com",
          "phone_number" => "+13235556439",
          "title" => "ceo",
          "title_other" => nil
        }
      }

      org = Organization.from_json(data)

      assert org.registered_name == "DT Precision Auto LLC"
      assert org.type == :llc
      assert org.country == "US"
      assert org.identifier_type == :ein
      assert org.identifier == "123456789"
      assert org.industry == :automotive
      assert org.website == "https://dtprecisionauto.com"
      assert org.regions_of_operation == [:usa_and_canada, :latin_america]
      assert org.stock_exchange == :nyse
      assert org.stock_symbol == "DTPA"
      assert org.email == "dom@dtprecisionauto.com"
      assert org.mobile_number == "+13235556439"

      assert org.address.name == "DT Precision Auto"
      assert org.address.line1 == "2640 Huron St"
      assert org.address.line2 == "Suite 100"
      assert org.address.locality == "Los Angeles"
      assert org.address.region == "CA"
      assert org.address.postal_code == "90065"
      assert org.address.country == "US"

      assert org.contact.first_name == "Dominic"
      assert org.contact.last_name == "Toretto"
      assert org.contact.email == "dom@dtprecisionauto.com"
      assert org.contact.phone_number == "+13235556439"
      assert org.contact.title == :ceo
      assert is_nil(org.contact.title_other)
    end

    test "handles nil address and contact" do
      data = %{
        "registered_name" => "Simple Corp",
        "address" => nil,
        "contact" => nil
      }

      org = Organization.from_json(data)

      assert org.registered_name == "Simple Corp"
      assert is_nil(org.address)
      assert is_nil(org.contact)
    end

    test "parses all organization types" do
      types = [
        {"co_op", :co_op},
        {"government", :government},
        {"llc", :llc},
        {"non_profit", :non_profit},
        {"partnership", :partnership},
        {"private_corporation", :private_corporation},
        {"public_corporation", :public_corporation},
        {"sole_proprietor", :sole_proprietor}
      ]

      for {input, expected} <- types do
        org = Organization.from_json(%{"type" => input})
        assert org.type == expected
      end
    end

    test "parses all industries" do
      industries = [
        {"agriculture", :agriculture},
        {"automotive", :automotive},
        {"banking", :banking},
        {"construction", :construction},
        {"consumer", :consumer},
        {"education", :education},
        {"electronics", :electronics},
        {"energy", :energy},
        {"engineering", :engineering},
        {"fast_moving_consumer_goods", :fast_moving_consumer_goods},
        {"financial", :financial},
        {"fintech", :fintech},
        {"food_and_beverage", :food_and_beverage},
        {"government", :government},
        {"healthcare", :healthcare},
        {"hospitality", :hospitality},
        {"insurance", :insurance},
        {"jewelry", :jewelry},
        {"legal", :legal},
        {"manufacturing", :manufacturing},
        {"media", :media},
        {"not_for_profit", :not_for_profit},
        {"oil_and_gas", :oil_and_gas},
        {"online", :online},
        {"professional_services", :professional_services},
        {"raw_materials", :raw_materials},
        {"real_estate", :real_estate},
        {"religion", :religion},
        {"retail", :retail},
        {"technology", :technology},
        {"telecommunications", :telecommunications},
        {"transportation", :transportation},
        {"travel", :travel}
      ]

      for {input, expected} <- industries do
        org = Organization.from_json(%{"industry" => input})
        assert org.industry == expected
      end
    end

    test "parses all regions of operation" do
      regions = [
        {"africa", :africa},
        {"asia", :asia},
        {"australia", :australia},
        {"europe", :europe},
        {"latin_america", :latin_america},
        {"usa_and_canada", :usa_and_canada}
      ]

      for {input, expected} <- regions do
        org = Organization.from_json(%{"regions_of_operation" => [input]})
        assert org.regions_of_operation == [expected]
      end
    end

    test "parses all stock exchanges" do
      exchanges = [
        {"amex", :amex},
        {"amx", :amx},
        {"asx", :asx},
        {"b3", :b3},
        {"bme", :bme},
        {"bse", :bse},
        {"fra", :fra},
        {"icex", :icex},
        {"jpx", :jpx},
        {"jse", :jse},
        {"krx", :krx},
        {"lon", :lon},
        {"nasdaq", :nasdaq},
        {"none", :none},
        {"nse", :nse},
        {"nyse", :nyse},
        {"omx", :omx},
        {"other", :other},
        {"sehk", :sehk},
        {"sgx", :sgx},
        {"sse", :sse},
        {"sto", :sto},
        {"swx", :swx},
        {"szse", :szse},
        {"tsx", :tsx},
        {"twse", :twse},
        {"vse", :vse}
      ]

      for {input, expected} <- exchanges do
        org = Organization.from_json(%{"stock_exchange" => input})
        assert org.stock_exchange == expected
      end
    end

    test "parses all contact titles" do
      titles = [
        {"ceo", :ceo},
        {"cfo", :cfo},
        {"director", :director},
        {"gm", :gm},
        {"vp", :vp},
        {"general_counsel", :general_counsel},
        {"other", :other}
      ]

      for {input, expected} <- titles do
        org = Organization.from_json(%{"contact" => %{"title" => input}})
        assert org.contact.title == expected
      end
    end

    test "handles unknown enum values" do
      data = %{
        "type" => "unknown_type",
        "industry" => "unknown_industry",
        "stock_exchange" => "unknown_exchange",
        "identifier_type" => "unknown_identifier",
        "contact" => %{
          "title" => "unknown_title"
        },
        "regions_of_operation" => ["unknown_region", "usa_and_canada"]
      }

      org = Organization.from_json(data)

      assert is_nil(org.type)
      assert is_nil(org.industry)
      assert is_nil(org.stock_exchange)
      assert is_nil(org.identifier_type)
      assert is_nil(org.contact.title)
      # Only valid regions are included
      assert org.regions_of_operation == [:usa_and_canada]
    end

    test "handles nil enum values" do
      data = %{
        "type" => nil,
        "industry" => nil,
        "stock_exchange" => nil,
        "identifier_type" => nil,
        "regions_of_operation" => nil
      }

      org = Organization.from_json(data)

      assert is_nil(org.type)
      assert is_nil(org.industry)
      assert is_nil(org.stock_exchange)
      assert is_nil(org.identifier_type)
      assert org.regions_of_operation == []
    end

    test "handles contact with other title" do
      data = %{
        "contact" => %{
          "first_name" => "Jane",
          "last_name" => "Doe",
          "email" => "jane@example.com",
          "phone_number" => "+15551234567",
          "title" => "other",
          "title_other" => "Chief Innovation Officer"
        }
      }

      org = Organization.from_json(data)

      assert org.contact.title == :other
      assert org.contact.title_other == "Chief Innovation Officer"
    end

    test "handles minimal organization data" do
      data = %{}

      org = Organization.from_json(data)

      assert is_nil(org.registered_name)
      assert is_nil(org.type)
      assert is_nil(org.country)
      assert is_nil(org.identifier_type)
      assert is_nil(org.identifier)
      assert is_nil(org.industry)
      assert is_nil(org.website)
      assert org.regions_of_operation == []
      assert is_nil(org.stock_exchange)
      assert is_nil(org.stock_symbol)
      assert is_nil(org.email)
      assert is_nil(org.mobile_number)
      assert is_nil(org.address)
      assert is_nil(org.contact)
    end

    test "parses partial address data" do
      data = %{
        "address" => %{
          "line1" => "123 Main St",
          "locality" => "Anytown",
          "country" => "US"
        }
      }

      org = Organization.from_json(data)

      assert org.address.line1 == "123 Main St"
      assert org.address.locality == "Anytown"
      assert org.address.country == "US"
      assert is_nil(org.address.name)
      assert is_nil(org.address.line2)
      assert is_nil(org.address.region)
      assert is_nil(org.address.postal_code)
    end

    test "parses partial contact data" do
      data = %{
        "contact" => %{
          "email" => "contact@example.com",
          "first_name" => "John"
        }
      }

      org = Organization.from_json(data)

      assert org.contact.email == "contact@example.com"
      assert org.contact.first_name == "John"
      assert is_nil(org.contact.last_name)
      assert is_nil(org.contact.phone_number)
      assert is_nil(org.contact.title)
      assert is_nil(org.contact.title_other)
    end

    test "handles multiple regions of operation" do
      data = %{
        "regions_of_operation" => ["usa_and_canada", "europe", "asia", "unknown"]
      }

      org = Organization.from_json(data)

      # Unknown regions are filtered out
      assert org.regions_of_operation == [:usa_and_canada, :europe, :asia]
    end

    test "handles empty regions of operation list" do
      data = %{
        "regions_of_operation" => []
      }

      org = Organization.from_json(data)

      assert org.regions_of_operation == []
    end
  end
end
