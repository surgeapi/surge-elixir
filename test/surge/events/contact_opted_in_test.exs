defmodule Surge.Events.ContactOptedInTest do
  use ExUnit.Case, async: true
  alias Surge.Events.ContactOptedIn

  describe "from_json/1" do
    test "parses complete campaign approved event" do
      data = %{
        "id" => "cpn_01jjnn7s0zfx5tdcsxjfy93et2"
      }

      event = ContactOptedIn.from_json(data)
      assert event.id == "cpn_01jjnn7s0zfx5tdcsxjfy93et2"
    end
  end
end
