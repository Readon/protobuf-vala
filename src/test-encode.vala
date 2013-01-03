public static int main (string[] args)
{
    check_encode_varint (0, "00");
    check_encode_varint (1, "01");
    check_encode_varint (127, "7F");
    check_encode_varint (128, "8001");
    check_encode_varint (16383, "FF7F");
    check_encode_varint (16384, "808001");

    // FIXME: double

    // FIXME: float

    check_encode_int64 (0, "00");
    check_encode_int64 (1, "01");
    check_encode_int64 (-1, "FFFFFFFFFFFFFFFFFF01");
    check_encode_int64 (int64.MAX, "FFFFFFFFFFFFFFFF7F");
    check_encode_int64 (int64.MIN, "80808080808080808001"); // FIXME: Double check these

    check_encode_uint64 (0, "00");
    check_encode_uint64 (1, "01");
    check_encode_uint64 (uint64.MAX, "FFFFFFFFFFFFFFFFFF01");

    check_encode_int32 (0, "00");
    check_encode_int32 (1, "01");
    check_encode_int32 (-1, "FFFFFFFFFFFFFFFFFF01");
    check_encode_int32 (int32.MAX, "FFFFFFFF07");
    check_encode_int32 (int32.MIN, "80808080F8FFFFFFFF01"); // FIXME: Double check these

    // FIXME: fixed64

    // FIXME: fixed32

    check_encode_bool (false, "00");
    check_encode_bool (true, "01");

    check_encode_string ("", "");
    check_encode_string ("123", "313233");

    // FIXME: bytes

    check_encode_uint32 (0, "00");
    check_encode_uint32 (1, "01");
    check_encode_uint32 (uint32.MAX, "FFFFFFFF0F");

    // FIXME: sfixed32

    // FIXME: sfixed64

    check_encode_sint32 (0, "00");
    check_encode_sint32 (1, "02");
    check_encode_sint32 (2, "04");
    check_encode_sint32 (-1, "01");
    check_encode_sint32 (-2, "03");
    check_encode_sint32 (int32.MAX, "FEFFFFFFFFFFFFFFFF01"); // FIXME: Double check these
    check_encode_sint32 (int32.MIN, "FFFFFFFFFFFFFFFFFF01"); // FIXME: Double check these

    // FIXME: sint64

    return 0;
}

private void check_encode_varint (size_t value, string expected)
{
    var buffer = new Protobuf.EncodeBuffer (100);
    buffer.encode_varint (value);
    var result = buffer_to_string (buffer);
    if (result != expected)
        stderr.printf ("encode_varint (%zu) -> \"%s\", expected \"%s\"\n", value, result, expected);
}

private void check_encode_int64 (int64 value, string expected)
{
    var buffer = new Protobuf.EncodeBuffer (100);
    buffer.encode_int64 (value);
    var result = buffer_to_string (buffer);
    if (result != expected)
        stderr.printf ("encode_int64 (%lli) -> \"%s\", expected \"%s\"\n", value, result, expected);
}

private void check_encode_uint64 (uint64 value, string expected)
{
    var buffer = new Protobuf.EncodeBuffer (100);
    buffer.encode_uint64 (value);
    var result = buffer_to_string (buffer);
    if (result != expected)
        stderr.printf ("encode_uint64 (%llu) -> \"%s\", expected \"%s\"\n", value, result, expected);
}

private void check_encode_int32 (int32 value, string expected)
{
    var buffer = new Protobuf.EncodeBuffer (100);
    buffer.encode_int32 (value);
    var result = buffer_to_string (buffer);
    if (result != expected)
        stderr.printf ("encode_int32 (%d) -> \"%s\", expected \"%s\"\n", value, result, expected);
}

private void check_encode_bool (bool value, string expected)
{
    var buffer = new Protobuf.EncodeBuffer (100);
    buffer.encode_bool (value);
    var result = buffer_to_string (buffer);
    if (result != expected)
        stderr.printf ("encode_bool (%s) -> \"%s\", expected \"%s\"\n", value.to_string (), result, expected);
}

private void check_encode_string (string value, string expected)
{
    var buffer = new Protobuf.EncodeBuffer (100);
    buffer.encode_string (value);
    var result = buffer_to_string (buffer);
    if (result != expected)
        stderr.printf ("encode_string (%s) -> \"%s\", expected \"%s\"\n", value.to_string (), result, expected);
}

private void check_encode_uint32 (uint32 value, string expected)
{
    var buffer = new Protobuf.EncodeBuffer (100);
    buffer.encode_uint32 (value);
    var result = buffer_to_string (buffer);
    if (result != expected)
        stderr.printf ("encode_uint32 (%llu) -> \"%s\", expected \"%s\"\n", value, result, expected);
}

private void check_encode_sint32 (int32 value, string expected)
{
    var buffer = new Protobuf.EncodeBuffer (100);
    buffer.encode_sint32 (value);
    var result = buffer_to_string (buffer);
    if (result != expected)
        stderr.printf ("encode_sint32 (%d) -> \"%s\", expected \"%s\"\n", value, result, expected);
}

private string buffer_to_string (Protobuf.EncodeBuffer buffer)
{
    var value = "";

    var data = buffer.data;
    for (var i = 0; i < data.length; i++)
        value += "%02X".printf (data[i]);

    return value;
}
