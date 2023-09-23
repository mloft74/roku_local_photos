function Init()
    m.top.taskNumber = m.global.nextNumberForCurrentImageTask
    m.global.nextNumberForCurrentImageTask += 1
    PrintWithTaskNumber("Init")
    m.top.functionName = "CurrentImage"

    m.port = CreateObject("roMessagePort")

    m.xfer = CreateObject("roUrlTransfer")
    m.xfer.SetPort(m.port)
    m.registrySection = CreateObject("roRegistrySection", "rokuLocalPhotos")
end function

function PrintWithTaskNumber(msg as string)
    print "[CurrentImageTask > taskNumber:"; m.top.taskNumber; "] "; msg
end function

function CurrentImage()
    PrintWithTaskNumber("CurrentImage")
    result = CurrentImageInternal()
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
    PrintWithTaskNumber("CurrentImage | done")
end function

function CurrentImageInternal() as object
    PrintWithTaskNumber("CurrentImageInternal")
    if not m.registrySection.Exists("serverIp")
        PrintWithTaskNumber("CurrentImageInternal | Server IP not set")
        return invalid
    end if

    serverIp = m.registrySection.Read("serverIp")
    if serverIp = invalid or serverIp = ""
        PrintWithTaskNumber("CurrentImageInternal | IP not set")
        return invalid
    end if

    m.xfer.SetUrl(serverIp + "/api/image/current")
    if not m.xfer.AsyncGetToString()
        PrintWithTaskNumber("CurrentImageInternal | Failed to start request")
        return invalid
    end if

    while true
        msg = Wait(0, m.port)
        if msg = invalid
            PrintWithTaskNumber("CurrentImageInternal | Roku message port returned invalid")
            return invalid
        end if

        msgType = Type(msg)
        if msgType <> "roUrlEvent"
            PrintWithTaskNumber("CurrentImageInternal | Got wrong event type from port: " + msgtype)
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
            PrintWithTaskNumber("CurrentImageInternal | Could not get response")
            return invalid
        else if responseStr = ""
            PrintWithTaskNumber("CurrentImageInternal | Response was empty")
            return invalid
        end if

        response = ParseJson(responseStr)
        if response = invalid
            PrintWithTaskNumber("CurrentImageInternal | Could not parse response")
            return invalid
        end if

        image = response.image
        if image = invalid
            PrintWithTaskNumber("CurrentImageInternal | No image available")
            return invalid
        end if

        fileName = GetFileName(image)
        width = GetWidth(image)
        height = GetHeight(image)
        if fileName = invalid or width = invalid or height = invalid
            return invalid
        end if

        return { fileName: fileName, width: width, height: height }
    end while
end function

function GetFileName(input as object) as object
    PrintWithTaskNumber("GetFileName")
    fileName = input.fileName
    if fileName = invalid
        PrintWithTaskNumber("GetFileName | fileName invalid")
        return invalid
    else if fileName = ""
        PrintWithTaskNumber("GetFileName | fileName empty")
        return invalid
    end if
    return fileName
end function

function GetWidth(input as object) as object
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

function GetHeight(input as object) as object
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
