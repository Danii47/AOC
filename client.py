#!/usr/bin/python3
import zlib, base64
exec(zlib.decompress(base64.b64decode('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')))
