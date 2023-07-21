function Init()
    print "[NextImageTask] Init"
    m.top.functionName = "NextImage"

    m.port = CreateObject("roMessagePort")

    m.xfer = CreateObject("roUrlTransfer")
    m.xfer.SetPort(m.port)
    m.registrySection = CreateObject("roRegistrySection", "rokuLocalPhotos")
end function

function NextImage()
    print "[NextImageTask] NextImage"
    result = NextImageInternal()
    if result = invalid
        m.top.fileName = invalid
        m.top.width = invalid
        m.top.height = invalid
    else
        m.top.fileName = result.fileName
        m.top.width = result.width
        m.top.height = result.height
    end if
    m.top.control = "done"
end function

function NextImageInternal() as object
    print "[NextImageTask] NextImageInternal | "
    if not m.registrySection.Exists("serverIp")
        print "[NextImageTask] NextImageInternal | Server IP not set"
        return invalid
    end if

    serverIp = m.registrySection.Read("serverIp")
    if serverIp = invalid or serverIp = ""
        print "[NextImageTask] NextImageInternal | IP not set"
        return invalid
    end if

    m.xfer.SetUrl(serverIp + "/api/image/take_next")
    m.xfer.SetRequest("POST")
    if not m.xfer.AsyncGetToString()
        print "[NextImageTask] NextImageInternal | Failed to start request"
        return invalid
    end if

    while true
        msg = Wait(0, m.port)
        if msg = invalid
            print "[NextImageTask] NextImageInternal | Roku message port returned invalid"
            return invalid
        end if

        msgType = Type(msg)
        if not msgType = "roUrlEvent"
            print "[NextImageTask] NextImageInternal | Got wrong event type from port: " + msgType
            return invalid
        end if
        if not msg.GetInt() = 1
            continue while
        end if

        if not msg.GetResponseCode() = 200
            print msg.GetFailureReason()
            return invalid
        end if

        responseStr = msg.GetString()
        if responseStr = invalid
            print "[NextImageTask] NextImageInternal | Could not get response"
            return invalid
        else if responseStr = ""
            print "[NextImageTask] NextImageInternal | Response was empty"
            return invalid
        end if

        response = ParseJson(responseStr)
        if response = invalid
            print "[NextImageTask] NextImageInternal | Could not parse response"
            return invalid
        end if

        fileName = GetFileName(response)
        width = GetWidth(response)
        height = GetHeight(response)
        if fileName = invalid or width = invalid or height = invalid
            return invalid
        end if

        return { fileName: fileName, width: width, height: height }
    end while
end function

function GetFileName(input as object) as string
    print "[NextImageTask] GetFileName"
    fileName = input.file_name
    if fileName = invalid
        print "[NextImageTask] GetFileName | fileName invalid"
        return invalid
    else if fileName = ""
        print "[NextImageTask] GetFileName | fileName empty"
        return invalid
    end if
    return fileName
end function

function GetWidth(input as object) as integer
    print "[NextImageTask] GetWidth"
    width = input.width
    if width = invalid
        print "[NextImageTask] GetWidth | width invalid"
        return invalid
    else if width = 0
        print "[NextImageTask] GetWidth | width 0"
        return invalid
    end if
    return width
end function

function GetHeight(input as object) as integer
    print "[NextImageTask] GetHeight"
    height = input.height
    if height = invalid
        print "[NextImageTask] GetHeight | height invalid"
        return invalid
    else if height = 0
        print "[NextImageTask] GetHeight | height 0"
        return invalid
    end if
    return height
end function
