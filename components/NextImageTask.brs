function Init()
    m.top.taskNumber = m.global.nextNumberForNextTaskImage
    m.global.nextNumberForNextTaskImage += 1
    PrintWithTaskNumber("Init")
    m.top.functionName = "NextImage"

    m.port = CreateObject("roMessagePort")

    m.xfer = CreateObject("roUrlTransfer")
    m.xfer.SetPort(m.port)
    m.registrySection = CreateObject("roRegistrySection", "rokuLocalPhotos")
end function

function PrintWithTaskNumber(msg as string)
    print "[NextImageTask] "; msg; " > taskNumber:"; m.top.taskNumber
end function

function NextImage()
    PrintWithTaskNumber("NextImage")
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
    PrintWithTaskNumber("NextImage | done")
end function

function NextImageInternal() as object
    PrintWithTaskNumber("NextImageInternal")
    if not m.registrySection.Exists("serverIp")
        PrintWithTaskNumber("NextImageInternal | Server IP not set")
        return invalid
    end if

    serverIp = m.registrySection.Read("serverIp")
    if serverIp = invalid or serverIp = ""
        PrintWithTaskNumber("NextImageInternal | IP not set")
        return invalid
    end if

    m.xfer.SetUrl(serverIp + "/api/image/take_next")
    m.xfer.SetRequest("POST")
    if not m.xfer.AsyncGetToString()
        PrintWithTaskNumber("NextImageInternal | Failed to start request")
        return invalid
    end if

    while true
        msg = Wait(0, m.port)
        if msg = invalid
            PrintWithTaskNumber("NextImageInternal | Roku message port returned invalid")
            return invalid
        end if

        msgType = Type(msg)
        if msgType <> "roUrlEvent"
            PrintWithTaskNumber("NextImageInternal | Got wrong event type from port: " + msgtype)
            return invalid
        end if
        if msg.GetInt() <> 1
            continue while
        end if

        if msg.GetResponseCode() <> 200
            PrintWithTaskNumber(msg.GetFailureReason())
            return invalid
        end if

        responseStr = msg.GetString()
        if responseStr = invalid
            PrintWithTaskNumber("NextImageInternal | Could not get response")
            return invalid
        else if responseStr = ""
            PrintWithTaskNumber("NextImageInternal | Response was empty")
            return invalid
        end if

        response = ParseJson(responseStr)
        if response = invalid
            PrintWithTaskNumber("NextImageInternal | Could not parse response")
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
    PrintWithTaskNumber("GetFileName")
    fileName = input.file_name
    if fileName = invalid
        PrintWithTaskNumber("GetFileName | fileName invalid")
        return invalid
    else if fileName = ""
        PrintWithTaskNumber("GetFileName | fileName empty")
        return invalid
    end if
    return fileName
end function

function GetWidth(input as object) as integer
    PrintWithTaskNumber("GetWidth")
    width = input.width
    if width = invalid
        PrintWithTaskNumber("GetWidth | width invalid")
        return invalid
    else if width = 0
        PrintWithTaskNumber("GetWidth | width 0")
        return invalid
    end if
    return width
end function

function GetHeight(input as object) as integer
    PrintWithTaskNumber("GetHeight")
    height = input.height
    if height = invalid
        PrintWithTaskNumber("GetHeight | height invalid")
        return invalid
    else if height = 0
        PrintWithTaskNumber("GetHeight | height 0")
        return invalid
    end if
    return height
end function
