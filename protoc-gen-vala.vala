public class ProtocVala
{
}

public static int main (string[] args)
{
    var buf = new uint8[1024];
    var n_read = stdin.read (buf); // FIXME: Read all
    stderr.printf ("%zu\n", n_read);
    if (n_read < 0)
        return 1;

    //for (var i = 0; i < n_read; i++)
    //    stderr.printf ("%02X", buf[i]);
    //stderr.printf ("\n");

    var req = new CodeGeneratorRequest ();
    req.decode (buf, n_read);

    stderr.printf ("{ %s }\n", req.to_string ());

    return 0;
}
