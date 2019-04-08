local fPath = "./resources/[system]/cadvanced/storage/"

function updateFile(type, payload)
    local fullPath = fPath .. type
    local f = assert(io.open(fullPath, "w"))
    io.output(f)
    io.write(json.encode(payload))
    io.close(f)
end