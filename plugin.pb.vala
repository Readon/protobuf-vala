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

private string decode_string (uint8[] buffer, size_t length, size_t offset)
{
    var value = new StringBuilder ();
    for (var i = 0; i < length; i++)
    {
        value.append_c ((char) buffer[offset]);
        offset++;
    }

    return value.str;
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
        stderr.printf ("Unknown wire type %d\n", wire_type);
        return 0;
    }
}

public class CodeGeneratorRequest
{
    List<string> file_to_generate;
    string? parameter;
    List<FileDescriptorProto> proto_file;

    public void decode (uint8[] buffer, size_t length, size_t offset = 0)
    {
        while (offset < length)
        {
            var key = decode_varint (buffer, length, ref offset);
            var wire_type = key & 0x7;
            var field_number = key >> 3;
            int varint;
            var value_length = get_value_length (wire_type, out varint, buffer, length, ref offset);
            // FIXME: Check remaining space

            switch (field_number)
            {
            case 1:
                file_to_generate.append (decode_string (buffer, value_length, offset));
                break;
            case 2:
                parameter = decode_string (buffer, value_length, offset);
                break;
            case 15:
                var f = new FileDescriptorProto ();
                f.decode (buffer, offset + value_length, offset);
                proto_file.append (f);
                break;
            default:
                stderr.printf ("Unknown CodeGeneratorRequest field %d\n", field_number);
                Process.exit (1);
                // Skip unknown data
            }

            offset += value_length;
        }

        if (offset != length)
            stderr.printf ("Unused %zu octets on end of CodeGeneratorRequest\n", offset - length);
    }

    public string to_string ()
    {
        var text = "";

        if (file_to_generate != null)
        {
            text += "file_to_generate=[";
            foreach (var f in file_to_generate)
                text += "\"%s\" ".printf (f);
            text += "] ";
        }

        if (parameter != null)
            text += "parameter=\"%s\" ".printf (parameter);

        if (proto_file != null)
        {
            text += "proto_file=[";
            foreach (var f in proto_file)
                text += "{ %s } ".printf (f.to_string ());
            text += "] ";
        }

        return text;
    }
}

private void encode_varint (int value, uint8[] buffer, ref size_t offset)
{
    var v = value;
    while (true)
    {
        var next_v = v >> 7;
        var o = (uint8) v & 0x7F;
        if (next_v != 0)
            o |= 0x80;
        buffer[offset] = o;
        offset--;
        if (next_v == 0)
            return;
        v = next_v;
    }
}

private void encode_string (string value, uint8[] buffer, ref size_t offset)
{
    offset -= value.length;
    for (var i = 0; value[i] != '\0'; i++)
        buffer[offset + i + 1] = value[i];
    encode_varint (value.length, buffer, ref offset);
}

public class CodeGeneratorResponse
{
    public List<File> file;

    public size_t encode (uint8[] buffer, size_t offset)
    {
        var start = offset;

        // FIXME: Reverse the list
        foreach (var v in file)
        {
            var n_written = v.encode (buffer, offset);
            offset -= n_written;
            encode_varint ((int) n_written, buffer, ref offset);
            encode_varint ((15 << 3) | 0x2, buffer, ref offset);
        }

        return start - offset;
    }
}

public class File
{
    public string? name;
    public string? content;

    public size_t encode (uint8[] buffer, size_t offset)
    {
        var start = offset;

        if (content != null)
        {
            encode_string (content, buffer, ref offset);
            encode_varint ((15 << 3) | 0x2, buffer, ref offset);
        }
        if (name != null)
        {
            encode_string (name, buffer, ref offset);
            encode_varint ((1 << 3) | 0x2, buffer, ref offset);
        }

        return start - offset;
    }
}