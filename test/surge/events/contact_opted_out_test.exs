defmodule Surge.Events.ContactOptedOutTest do
  use ExUnit.Case, async: true
  alias Surge.Events.ContactOptedOut

  describe "from_json/1" do
    test "parses complete campaign approved event" do
      data = %{
        "id" => "cpn_01jjnn7s0zfx5tdcsxjfy93et2"
      }

      event = ContactOptedOut.from_json(data)
      assert event.id == "cpn_01jjnn7s0zfx5tdcsxjfy93et2"
    end
  end
end
