namespace Protobuf
{
    private int decode_varint (uint8[] buffer, size_t length, ref size_t offset)
    {
        int value = 0;
        var shift = 0;

        while (true)
        {
            var b = buffer[offset];
            offset++;
            value = value | (b & 0x7F) << shift;
            if ((b & 0x80) == 0)
                return value;
            shift += 7;
        }
    }
    
    private double decode_double (uint8[] buffer, size_t length, size_t offset)
    {
        offset += 8;
        return 0.0; // FIXME
    }

    private string decode_string (uint8[] buffer, size_t length, size_t offset)
    {
        var value = new GLib.StringBuilder.sized (length - offset);
        while (offset < length)
        {
            value.append_c ((char) buffer[offset]);
            offset++;
        }

        return value.str;
    }

    private uint8[] decode_bytes (uint8[] buffer, size_t length, size_t offset)
    {
        var value = new uint8[length - offset];
        var start = offset;
        for (var i = start; i < length; i++)
        {
            value[i - start] = buffer[i];
            offset++;
        }

        return value;
    }

    private size_t get_value_length (int wire_type, out int varint, uint8[] buffer, size_t length, ref size_t offset)
    {
        varint = 0;
        switch (wire_type)
        {
        case 0: //varint
            var o = offset;
            varint = decode_varint (buffer, length, ref o);
            return o - offset;
        case 1: //64-bit
            return 8;
        case 2: //length-delimited
            return decode_varint (buffer, length, ref offset);
        case 5: //32-bit
            return 4;
        default: //FIXME: throw error
            GLib.stderr.printf ("Unknown wire type %d\n", wire_type);
            return 0;
        }
    }

    private void encode_varint (size_t value, uint8[] buffer, ref size_t offset)
    {
        var n_octets = 1;
        var v = value;
        while (v != 0)
        {
            v >>= 7;
            n_octets++;
        }
        offset -= n_octets;

        v = value;
        for (var i = 0; i < n_octets - 1; i++)
        {
            buffer[offset + i + 1] = 0x80 | (uint8) (v & 0x7F);
            v >>= 7;
        }
        buffer[offset + n_octets] = (uint8) (v & 0x7F);
    }

    private size_t encode_double (double value, uint8[] buffer, ref size_t offset)
    {
        offset -= 8;
        // FIXME
        return 8;
    }

    private size_t encode_string (string value, uint8[] buffer, ref size_t offset)
    {
        offset -= value.length;
        for (var i = 0; value[i] != '\0'; i++)
            buffer[offset + i + 1] = value[i];

        return value.length;
    }

    private size_t encode_bytes (uint8[] value, uint8[] buffer, ref size_t offset)
    {
        offset -= value.length;
        for (var i = 0; value[i] != '\0'; i++)
            buffer[offset + i + 1] = value[i];

        return value.length;
    }
}
