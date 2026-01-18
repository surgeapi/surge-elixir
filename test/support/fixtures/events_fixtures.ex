defmodule Surge.EventsFixtures do
  @moduledoc """
  This module defines test fixtures for `Surge.Events` data.
  """

  def call_ended_fixture(attrs \\ %{}) do
    Map.merge(
      %{
        "id" => "call_01jjnn7s0zfx5tdcsxjfy93et2",
        "contact" => %{
          "id" => "ctc_01ja88cboqffhswjx8zbak3ykk",
          "phone_number" => "+18015551234"
        },
        "duration" => 184,
        "initiated_at" => "2025-03-31T21:01:37Z",
        "status" => "completed"
      },
      attrs
    )
  end

  def call_ended_busy_fixture do
    %{
      "id" => "call_busy123",
      "contact" => %{
        "id" => "ctc_busy456",
        "phone_number" => "+14155552468"
      },
      "duration" => 0,
      "initiated_at" => "2025-03-31T22:15:00Z",
      "status" => "busy"
    }
  end

  def call_ended_canceled_fixture do
    %{
      "id" => "call_canceled789",
      "contact" => %{
        "id" => "ctc_cancel012",
        "phone_number" => "+12125553690"
      },
      "duration" => 5,
      "initiated_at" => "2025-03-31T23:30:45Z",
      "status" => "canceled"
    }
  end

  def call_ended_failed_fixture do
    %{
      "id" => "call_failed345",
      "contact" => %{
        "id" => "ctc_fail678",
        "phone_number" => "+13105554812"
      },
      "duration" => 0,
      "initiated_at" => "2025-04-01T00:45:00Z",
      "status" => "failed"
    }
  end

  def call_ended_missed_fixture do
    %{
      "id" => "call_missed901",
      "contact" => %{
        "id" => "ctc_miss234",
        "phone_number" => "+16175555024"
      },
      "duration" => 0,
      "initiated_at" => "2025-04-01T01:00:00Z",
      "status" => "missed"
    }
  end

  def call_ended_no_answer_fixture do
    %{
      "id" => "call_noanswer567",
      "contact" => %{
        "id" => "ctc_noanswer890",
        "phone_number" => "+17135556136"
      },
      "duration" => 0,
      "initiated_at" => "2025-04-01T02:15:30Z",
      "status" => "no_answer"
    }
  end

  def call_ended_minimal_fixture do
    %{
      "id" => "call_minimal123"
    }
  end

  def call_ended_with_nulls_fixture do
    %{
      "id" => "call_nulls456",
      "contact" => nil,
      "duration" => nil,
      "initiated_at" => nil,
      "status" => nil
    }
  end

  def call_ended_invalid_datetime_fixture do
    %{
      "id" => "call_baddate789",
      "contact" => %{
        "id" => "ctc_baddate012",
        "phone_number" => "+18005557248"
      },
      "duration" => 100,
      "initiated_at" => "not-a-valid-datetime",
      "status" => "completed"
    }
  end

  def call_ended_unknown_status_fixture do
    %{
      "id" => "call_unknown345",
      "contact" => %{
        "id" => "ctc_unknown678",
        "phone_number" => "+19005558360"
      },
      "duration" => 50,
      "initiated_at" => "2025-04-01T03:30:00Z",
      "status" => "unknown_status"
    }
  end

  def call_ended_with_extra_contact_fields_fixture do
    %{
      "id" => "call_extra901",
      "contact" => %{
        "id" => "ctc_extra234",
        "phone_number" => "+12025559472",
        "name" => "John Doe",
        "email" => "john@example.com",
        "tags" => ["vip", "priority"]
      },
      "duration" => 300,
      "initiated_at" => "2025-04-01T04:45:00Z",
      "status" => "completed"
    }
  end

  def conversation_created_fixture(attrs \\ %{}) do
    Map.merge(
      %{
        "id" => "cnv_01jav8xy7fe4nsay3c9deqxge9",
        "phone_number" => %{
          "id" => "pn_01jsjwe4d9fx3tpymgtg958d9w",
          "number" => "+18015556789",
          "type" => "local"
        },
        "contact" => %{
          "id" => "ctc_01ja88cboqffhswjx8zbak3ykk",
          "first_name" => "Dominic",
          "last_name" => "Toretto",
          "phone_number" => "+18015551234"
        }
      },
      attrs
    )
  end

  def conversation_created_toll_free_fixture do
    %{
      "id" => "cnv_tollfree123",
      "phone_number" => %{
        "id" => "pn_tollfree456",
        "number" => "+18885551234",
        "type" => "toll_free"
      },
      "contact" => %{
        "id" => "ctc_tollfree789",
        "first_name" => "Brian",
        "last_name" => "O'Conner",
        "phone_number" => "+13105554567"
      }
    }
  end

  def conversation_created_minimal_fixture do
    %{
      "id" => "cnv_minimal123"
    }
  end

  def conversation_created_with_nulls_fixture do
    %{
      "id" => "cnv_nulls456",
      "phone_number" => nil,
      "contact" => nil
    }
  end

  def conversation_created_with_full_contact_fixture do
    %{
      "id" => "cnv_fullcontact789",
      "phone_number" => %{
        "id" => "pn_full012",
        "number" => "+12125559876",
        "type" => "local"
      },
      "contact" => %{
        "id" => "ctc_full345",
        "email" => "letty@ortiz.family",
        "first_name" => "Letty",
        "last_name" => "Ortiz",
        "metadata" => %{
          "car" => "Jensen Interceptor",
          "team" => "Fast Family"
        },
        "phone_number" => "+14155557890"
      }
    }
  end

  def conversation_created_unknown_phone_type_fixture do
    %{
      "id" => "cnv_unknown678",
      "phone_number" => %{
        "id" => "pn_unknown901",
        "number" => "+19995551234",
        "type" => "unknown_type"
      },
      "contact" => %{
        "id" => "ctc_unknown234",
        "phone_number" => "+16175553456"
      }
    }
  end

  def conversation_created_missing_fields_fixture do
    %{
      "id" => "cnv_partial567",
      "contact" => %{
        "id" => "ctc_partial890",
        "phone_number" => "+17135552468"
      }
    }
  end

  def conversation_created_extra_fields_fixture do
    %{
      "id" => "cnv_extra123",
      "phone_number" => %{
        "id" => "pn_extra456",
        "number" => "+18005557890",
        "type" => "local",
        "capabilities" => ["sms", "mms", "voice"],
        "status" => "active"
      },
      "contact" => %{
        "id" => "ctc_extra789",
        "phone_number" => "+12025551234"
      },
      "created_at" => "2025-04-01T10:30:00Z",
      "extra_field" => "should be ignored"
    }
  end

  def message_delivered_fixture(attrs \\ %{}) do
    Map.merge(
      %{
        "id" => "msg_01jjnn7s0zfx5tdcsxjfy93et2",
        "body" => "Dude, I almost had you!",
        "attachments" => [
          %{
            "id" => "att_01jjnn75vgepj8bnnttfw1st5s",
            "type" => "image",
            "url" => "https://toretto.family/skyline.jpg"
          }
        ],
        "delivered_at" => "2024-10-21T23:29:42Z",
        "conversation" => %{
          "id" => "cnv_01jav8xy7fe4nsay3c9deqxge9",
          "phone_number" => %{
            "id" => "pn_01jsjwe4d9fx3tpymgtg958d9w",
            "number" => "+18015556789",
            "type" => "local"
          },
          "contact" => %{
            "email" => "dom@toretto.family",
            "id" => "ctc_01ja88cboqffhswjx8zbak3ykk",
            "first_name" => "Dominic",
            "last_name" => "Toretto",
            "metadata" => %{
              "car" => "1970 Dodge Charger R/T"
            },
            "phone_number" => "+18015551234"
          }
        }
      },
      attrs
    )
  end

  def link_followed_fixture(attrs \\ %{}) do
    Map.merge(
      %{
        "id" => "lnk_01kedctzhxexdbr5xf2bht5q84",
        "message_id" => "msg_01jjnn7s0zfx5tdcsxjfy93et2",
        "url" => "https://yoursite.com/something?param=true"
      },
      attrs
    )
  end

  def message_delivered_minimal_fixture do
    %{
      "id" => "msg_minimal123"
    }
  end

  def message_delivered_with_nulls_fixture do
    %{
      "id" => "msg_nulls456",
      "body" => nil,
      "attachments" => nil,
      "delivered_at" => nil,
      "conversation" => nil
    }
  end

  def message_delivered_no_attachments_fixture do
    %{
      "id" => "msg_noatt789",
      "body" => "Just text, no attachments",
      "attachments" => [],
      "delivered_at" => "2024-10-22T10:15:30Z",
      "conversation" => %{
        "id" => "cnv_noatt012",
        "phone_number" => %{
          "id" => "pn_noatt345",
          "number" => "+18885551234",
          "type" => "toll_free"
        },
        "contact" => %{
          "id" => "ctc_noatt678",
          "phone_number" => "+14155552468"
        }
      }
    }
  end

  def message_delivered_multiple_attachments_fixture do
    %{
      "id" => "msg_multi901",
      "body" => "Check out these photos!",
      "attachments" => [
        %{
          "id" => "att_image234",
          "type" => "image",
          "url" => "https://example.com/photo1.jpg"
        },
        %{
          "id" => "att_video567",
          "type" => "video",
          "url" => "https://example.com/video.mp4"
        },
        %{
          "id" => "att_audio890",
          "type" => "audio",
          "url" => "https://example.com/sound.mp3"
        }
      ],
      "delivered_at" => "2024-10-22T15:45:00Z",
      "conversation" => %{
        "id" => "cnv_multi123",
        "phone_number" => %{
          "id" => "pn_multi456",
          "number" => "+12125559876",
          "type" => "local"
        },
        "contact" => %{
          "id" => "ctc_multi789",
          "first_name" => "Mia",
          "phone_number" => "+13105553690"
        }
      }
    }
  end

  def message_delivered_invalid_datetime_fixture do
    %{
      "id" => "msg_baddate012",
      "body" => "Invalid date test",
      "delivered_at" => "not-a-valid-datetime",
      "conversation" => %{
        "id" => "cnv_baddate345",
        "phone_number" => %{
          "id" => "pn_baddate678",
          "number" => "+17135554812",
          "type" => "local"
        },
        "contact" => %{
          "id" => "ctc_baddate901",
          "phone_number" => "+16175555024"
        }
      }
    }
  end

  def message_delivered_unknown_attachment_type_fixture do
    %{
      "id" => "msg_unkatt234",
      "body" => "Unknown attachment type",
      "attachments" => [
        %{
          "id" => "att_unk567",
          "type" => "unknown_type",
          "url" => "https://example.com/file.xyz"
        }
      ],
      "delivered_at" => "2024-10-22T20:00:00Z",
      "conversation" => %{
        "id" => "cnv_unkatt890",
        "phone_number" => %{
          "id" => "pn_unkatt123",
          "number" => "+18005556136",
          "type" => "local"
        },
        "contact" => %{
          "id" => "ctc_unkatt456",
          "phone_number" => "+19005557248"
        }
      }
    }
  end

  def message_delivered_partial_conversation_fixture do
    %{
      "id" => "msg_partconv789",
      "body" => "Partial conversation data",
      "delivered_at" => "2024-10-23T08:30:00Z",
      "conversation" => %{
        "id" => "cnv_partial012"
        # Missing phone_number and contact
      }
    }
  end

  def message_delivered_with_extra_fields_fixture do
    %{
      "id" => "msg_extra345",
      "body" => "Message with extra fields",
      "attachments" => [],
      "delivered_at" => "2024-10-23T12:00:00Z",
      "conversation" => %{
        "id" => "cnv_extra678",
        "phone_number" => %{
          "id" => "pn_extra901",
          "number" => "+12025558360",
          "type" => "local"
        },
        "contact" => %{
          "id" => "ctc_extra234",
          "phone_number" => "+13105559472"
        }
      },
      "sent_at" => "2024-10-23T11:59:45Z",
      "extra_field" => "should be ignored",
      "status" => "delivered"
    }
  end

  # MessageFailed fixtures
  def message_failed_fixture(attrs \\ %{}) do
    Map.merge(
      %{
        "id" => "msg_01jjnn7s0zfx5tdcsxjfy93et2",
        "body" => "Dude, I almost had you!",
        "attachments" => [
          %{
            "id" => "att_01jjnn75vgepj8bnnttfw1st5s",
            "type" => "image",
            "url" => "https://toretto.family/skyline.jpg"
          }
        ],
        "conversation" => %{
          "id" => "cnv_01jav8xy7fe4nsay3c9deqxge9",
          "phone_number" => %{
            "id" => "pn_01jsjwe4d9fx3tpymgtg958d9w",
            "number" => "+18015556789",
            "type" => "local"
          },
          "contact" => %{
            "email" => "dom@toretto.family",
            "id" => "ctc_01ja88cboqffhswjx8zbak3ykk",
            "first_name" => "Dominic",
            "last_name" => "Toretto",
            "metadata" => %{
              "car" => "1970 Dodge Charger R/T"
            },
            "phone_number" => "+18015551234"
          }
        },
        "failed_at" => "2024-10-21T23:29:42Z",
        "failure_reason" => "carrier_error"
      },
      attrs
    )
  end

  def message_failed_invalid_number_fixture do
    %{
      "id" => "msg_invalid123",
      "body" => "Test message",
      "failed_at" => "2024-10-22T10:00:00Z",
      "failure_reason" => "invalid_number",
      "conversation" => %{
        "id" => "cnv_invalid456",
        "phone_number" => %{
          "id" => "pn_invalid789",
          "number" => "+18885551234",
          "type" => "toll_free"
        },
        "contact" => %{
          "id" => "ctc_invalid012",
          "phone_number" => "+19999999999"
        }
      }
    }
  end

  def message_failed_blocked_fixture do
    %{
      "id" => "msg_blocked345",
      "body" => "Blocked message",
      "failed_at" => "2024-10-22T11:00:00Z",
      "failure_reason" => "blocked",
      "conversation" => %{
        "id" => "cnv_blocked678"
      }
    }
  end

  def message_failed_spam_detected_fixture do
    %{
      "id" => "msg_spam901",
      "body" => "Free money!!! Click here!!!",
      "failed_at" => "2024-10-22T12:00:00Z",
      "failure_reason" => "spam_detected",
      "conversation" => %{
        "id" => "cnv_spam234"
      }
    }
  end

  def message_failed_rate_limited_fixture do
    %{
      "id" => "msg_rate567",
      "body" => "Too many messages",
      "failed_at" => "2024-10-22T13:00:00Z",
      "failure_reason" => "rate_limited",
      "conversation" => %{
        "id" => "cnv_rate890"
      }
    }
  end

  def message_failed_unknown_reason_fixture do
    %{
      "id" => "msg_unknown123",
      "body" => "Unknown failure",
      "failed_at" => "2024-10-22T14:00:00Z",
      "failure_reason" => "unknown_reason",
      "conversation" => %{
        "id" => "cnv_unknown456"
      }
    }
  end

  # MessageSent fixtures
  def message_sent_fixture(attrs \\ %{}) do
    Map.merge(
      %{
        "id" => "msg_01jjnn7s0zfx5tdcsxjfy93et2",
        "body" => "Dude, I almost had you!",
        "attachments" => [
          %{
            "id" => "att_01jjnn75vgepj8bnnttfw1st5s",
            "type" => "image",
            "url" => "https://toretto.family/skyline.jpg"
          }
        ],
        "sent_at" => "2024-10-21T23:29:41Z",
        "conversation" => %{
          "id" => "cnv_01jav8xy7fe4nsay3c9deqxge9",
          "phone_number" => %{
            "id" => "pn_01jsjwe4d9fx3tpymgtg958d9w",
            "number" => "+18015556789",
            "type" => "local"
          },
          "contact" => %{
            "email" => "dom@toretto.family",
            "id" => "ctc_01ja88cboqffhswjx8zbak3ykk",
            "first_name" => "Dominic",
            "last_name" => "Toretto",
            "metadata" => %{
              "car" => "1970 Dodge Charger R/T"
            },
            "phone_number" => "+18015551234"
          }
        }
      },
      attrs
    )
  end

  def message_sent_minimal_fixture do
    %{
      "id" => "msg_sent_minimal123"
    }
  end

  def message_sent_with_nulls_fixture do
    %{
      "id" => "msg_sent_nulls456",
      "body" => nil,
      "attachments" => nil,
      "sent_at" => nil,
      "conversation" => nil
    }
  end

  # MessageReceived fixtures
  def message_received_fixture(attrs \\ %{}) do
    Map.merge(
      %{
        "id" => "msg_01jav96823f9x9054d6gyzpp16",
        "body" => "I don't have friends, I got family.",
        "attachments" => [
          %{
            "id" => "att_01jav8z6x1j4m1b3w8v2jz7j3r",
            "type" => "image",
            "url" => "https://toretto.family/image.jpg"
          }
        ],
        "received_at" => "2024-10-22T23:32:49Z",
        "conversation" => %{
          "id" => "cnv_01jav8xy7fe4nsay3c9deqxge9",
          "phone_number" => %{
            "id" => "pn_01jsjwe4d9fx3tpymgtg958d9w",
            "number" => "+18015556789",
            "type" => "local"
          },
          "contact" => %{
            "id" => "ctc_01ja88cboqffhswjx8zbak3ykk",
            "first_name" => "Dominic",
            "last_name" => "Toretto",
            "phone_number" => "+18015551234"
          }
        }
      },
      attrs
    )
  end

  def message_received_minimal_fixture do
    %{
      "id" => "msg_recv_minimal123"
    }
  end

  def message_received_with_nulls_fixture do
    %{
      "id" => "msg_recv_nulls456",
      "body" => nil,
      "attachments" => nil,
      "received_at" => nil,
      "conversation" => nil
    }
  end

  def message_received_no_attachments_fixture do
    %{
      "id" => "msg_recv_noatt789",
      "body" => "Text only message from contact",
      "attachments" => [],
      "received_at" => "2024-10-23T09:15:30Z",
      "conversation" => %{
        "id" => "cnv_recv_noatt012",
        "phone_number" => %{
          "id" => "pn_recv_noatt345",
          "number" => "+17135556789",
          "type" => "local"
        },
        "contact" => %{
          "id" => "ctc_recv_noatt678",
          "first_name" => "Letty",
          "last_name" => "Ortiz",
          "phone_number" => "+14155552345"
        }
      }
    }
  end

  # Event wrapper fixtures
  def event_message_received_fixture(attrs \\ %{}) do
    Map.merge(
      %{
        "account_id" => "acct_01japd271aeatb7txrzr2xj8sg",
        "type" => "message.received",
        "data" => message_received_fixture()["data"] || message_received_fixture()
      },
      attrs
    )
  end

  def event_message_sent_fixture do
    %{
      "account_id" => "acct_01japd271aeatb7txrzr2xj8sg",
      "type" => "message.sent",
      "data" => message_sent_fixture()
    }
  end

  def event_message_delivered_fixture do
    %{
      "account_id" => "acct_01japd271aeatb7txrzr2xj8sg",
      "type" => "message.delivered",
      "data" => message_delivered_fixture()
    }
  end

  def event_message_failed_fixture do
    %{
      "account_id" => "acct_01japd271aeatb7txrzr2xj8sg",
      "type" => "message.failed",
      "data" => message_failed_fixture()
    }
  end

  def event_call_ended_fixture do
    %{
      "account_id" => "acct_01japd271aeatb7txrzr2xj8sg",
      "type" => "call.ended",
      "data" => call_ended_fixture()
    }
  end

  def event_conversation_created_fixture do
    %{
      "account_id" => "acct_01japd271aeatb7txrzr2xj8sg",
      "type" => "conversation.created",
      "data" => conversation_created_fixture()
    }
  end

  def event_minimal_fixture do
    %{
      "account_id" => "acct_minimal123",
      "type" => "message.received",
      "data" => %{
        "id" => "msg_minimal456"
      }
    }
  end

  def event_unknown_type_fixture do
    %{
      "account_id" => "acct_unknown789",
      "type" => "unknown.event",
      "data" => %{
        "id" => "unknown_012"
      }
    }
  end

  def event_with_nulls_fixture do
    %{
      "account_id" => nil,
      "type" => nil,
      "data" => nil
    }
  end

  def event_missing_data_fixture do
    %{
      "account_id" => "acct_nodata345",
      "type" => "message.received"
    }
  end

  def event_missing_type_fixture do
    %{
      "account_id" => "acct_notype678",
      "data" => %{
        "id" => "msg_notype901"
      }
    }
  end
end

