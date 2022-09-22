defmodule Instream.Encoder.LineTest do
  use ExUnit.Case

  alias Instream.Encoder.Line

  test "empty point list" do
    assert "" = Line.encode([])
  end

  test "empty point (no effective fields/tags)" do
    measurement = "test_empty"

    point = %{
      measurement: measurement,
      fields: %{
        value: nil
      },
      tags: %{
        value: nil
      },
      timestamp: nil
    }

    assert ^measurement = Line.encode([point])
  end

  test "simplest valid point" do
    expected = "disk_free value=442221834240i"

    point = %{
      measurement: "disk_free",
      fields: %{
        value: 442_221_834_240
      },
      timestamp: nil
    }

    assert ^expected = Line.encode([point])
  end

  test "with integer timestamp" do
    expected = "disk_free value=442221834240i 1435362189575692182"

    point = %{
      measurement: "disk_free",
      fields: %{
        value: 442_221_834_240
      },
      timestamp: 1_435_362_189_575_692_182
    }

    assert ^expected = Line.encode([point])
  end

  test "with RFC3339 timestamp" do
    expected = "disk_free value=442221834240i 1435362189575692000"

    point = %{
      measurement: "disk_free",
      fields: %{
        value: 442_221_834_240
      },
      timestamp: "2015-06-26T23:43:09.575692000+00:00"
    }

    assert ^expected = Line.encode([point])
  end

  test "with tags" do
    expected = "disk_free,disk_type=SSD,hostname=server01 value=442221834240i"

    point = %{
      measurement: "disk_free",
      fields: %{
        value: 442_221_834_240
      },
      tags: %{
        hostname: "server01",
        disk_type: "SSD"
      },
      timestamp: nil
    }

    assert ^expected = Line.encode([point])
  end

  test "with tags and timestamp" do
    expected = "disk_free,disk_type=SSD,hostname=server01 value=442221834240i 1435362189575692182"

    point = %{
      measurement: "disk_free",
      fields: %{
        value: 442_221_834_240
      },
      tags: %{
        hostname: "server01",
        disk_type: "SSD"
      },
      timestamp: 1_435_362_189_575_692_182
    }

    assert ^expected = Line.encode([point])
  end

  test "multiple fields" do
    expected = ~S(disk_free disk_type="SSD",free_space=442221834240i 1435362189575692182)

    point = %{
      measurement: "disk_free",
      fields: %{
        free_space: 442_221_834_240,
        disk_type: "SSD"
      },
      timestamp: 1_435_362_189_575_692_182
    }

    assert ^expected = Line.encode([point])
  end

  test "escaping commas and spaces" do
    expected =
      ~S(total\ disk\ free,volumes=/net\,/home\,/ value=442221834240i 1435362189575692182)

    point = %{
      measurement: "total disk free",
      tags: %{
        volumes: "/net,/home,/"
      },
      fields: %{
        value: 442_221_834_240
      },
      timestamp: 1_435_362_189_575_692_182
    }

    assert ^expected = Line.encode([point])
  end

  test "escaping equals signs" do
    expected = ~S(disk_free,a\=b=y\=z value=442221834240i)

    point = %{
      measurement: "disk_free",
      tags: %{
        "a=b" => "y=z"
      },
      fields: %{
        value: 442_221_834_240
      },
      timestamp: nil
    }

    assert ^expected = Line.encode([point])
  end

  test "with backslash in tag value" do
    expected = ~S(disk_free,path=C:\Windows value=442221834240i)

    point = %{
      measurement: "disk_free",
      tags: %{
        path: ~S(C:\Windows)
      },
      fields: %{
        value: 442_221_834_240
      },
      timestamp: nil
    }

    assert ^expected = Line.encode([point])
  end

  test "escaping field key" do
    expected =
      ~S(disk_free value=442221834240i,working\ directories="C:\My Documents\Stuff for examples,C:\My Documents")

    point = %{
      measurement: "disk_free",
      fields: %{
        "value" => 442_221_834_240,
        "working directories" => ~S(C:\My Documents\Stuff for examples,C:\My Documents)
      },
      timestamp: nil
    }

    assert ^expected = Line.encode([point])
  end

  test "showing all escaping and quoting together" do
    expected =
      ~S("measurement\ with\ quotes",tag\ key\ with\ spaces=tag\,value\,with"commas" field_key\\\\="string field value, only \" need be quoted")

    point = %{
      measurement: ~S("measurement with quotes"),
      tags: %{
        "tag key with spaces" => ~S(tag,value,with"commas")
      },
      fields: %{
        ~S(field_key\\\\) => ~S(string field value, only " need be quoted)
      },
      timestamp: nil
    }

    assert ^expected = Line.encode([point])
  end

  test "multiple points" do
    expected = ~s(multiline value="first"\nmultiline value="second")

    points = [
      %{
        measurement: "multiline",
        fields: %{value: "first"}
      },
      %{
        measurement: "multiline",
        fields: %{value: "second"}
      }
    ]

    assert ^expected = Line.encode(points)
  end
end
