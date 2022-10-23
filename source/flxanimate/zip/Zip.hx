package flxanimate.zip;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.zip.Reader;
import haxe.zip.Entry;
#if lime
import lime._internal.format.Deflate;
#end

class Zip
{
    var i:haxe.io.Input;
    var reader:Reader;
    public function new(i)
    {
        this.i = i;
        reader = new Reader(i);
    }

    function readZipDate()
    {
       @:privateAccess
       return reader.readZipDate();
    }

    function readExtraFields(length)
    {
       @:privateAccess
       return reader.readExtraFields(length);
    }

    public function readEntryHeader():Entry
    {
       return reader.readEntryHeader();
    }

    public function read():List<Entry>
    {
       return reader.read();
    }

    public static function readZip(i:haxe.io.Bytes)
    {
        var r = new Reader(new BytesInput(i));
        return r.read();
    }
    public static function unzip(f:List<Entry>):List<Entry>
    {
        for (list in f)
        {
            if (list.compressed)
            {
                #if !lime
                var s = haxe.io.Bytes.alloc(list.fileSize);
                var c = new haxe.zip.Uncompress(-15);
                var r = c.execute(list.data, 0, s, 0);
                c.close();
                if (!r.done || r.read != list.data.length || r.write != list.fileSize)
                    throw "Invalid compressed data for " + list.fileName;
                list.data = s;
                #else
                    list.data = Deflate.decompress(list.data);
                #end
                list.compressed = false;
                list.dataSize = list.fileSize;
            }
        }
        return f;
    }
}
