function init()
    print "[NextImageTask] init"
    m.top.functionName = "nextImage"

    m.port = createObject("roMessagePort")

    m.xfer = createObject("roUrlTransfer")
    m.xfer.setPort(m.port)
    m.registrySection = createObject("roRegistrySection", "rokuLocalPhotos")
end function

function nextImage()
    print "[NextImageTask] nextImage"
    result = nextImageInternal()
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

function nextImageInternal() as object
    print "[NextImageTask] nextImageInternal | "
    if not m.registrySection.exists("serverIp")
        print "[NextImageTask] nextImageInternal | Server IP not set"
        return invalid
    end if

    serverIp = m.registrySection.read("serverIp")
    if serverIp = invalid or serverIp = ""
        print "[NextImageTask] nextImageInternal | IP not set"
        return invalid
    end if

    m.xfer.setUrl(serverIp + "/api/image/take_next")
    if not m.xfer.asyncGetToString()
        print "[NextImageTask] nextImageInternal | Failed to start request"
        return invalid
    end if

    while true
        msg = wait(0, m.port)
        if msg = invalid
            print "[NextImageTask] nextImageInternal | Roku message port returned invalid"
            return invalid
        end if

        msgType = type(msg)
        if not msgType = "roUrlEvent"
            print "[NextImageTask] nextImageInternal | Got wrong event type from port: " + msgType
            return invalid
        end if
        if not msg.getInt() = 1
            continue while
        end if

        if not msg.getResponseCode() = 200
            print msg.getFailureReason()
            return invalid
        end if

        responseStr = msg.getString()
        if responseStr = invalid
            print "[NextImageTask] nextImageInternal | Could not get response"
            return invalid
        else if responseStr = ""
            print "[NextImageTask] nextImageInternal | Response was empty"
            return invalid
        end if

        response = parseJson(responseStr)
        if response = invalid
            print "[NextImageTask] nextImageInternal | Could not parse response"
            return invalid
        end if

        fileName = getFileName(response)
        width = getWidth(response)
        height = getHeight(response)
        if fileName = invalid or width = invalid or height = invalid
            return invalid
        end if

        return { fileName: fileName, width: width, height: height }
    end while
end function

function getFileName(input as object) as string
    print "[NextImageTask] getFileName"
    fileName = input.fileName
    if fileName = invalid
        print "[NextImageTask] getFileName | fileName invalid"
        return invalid
    else if fileName = ""
        print "[NextImageTask] getFileName | fileName empty"
        return invalid
    end if
    return fileName
end function

function getWidth(input as object) as integer
    print "[NextImageTask] getWidth"
    width = input.width
    if width = invalid
        print "[NextImageTask] getWidth | width invalid"
        return invalid
    else if width = 0
        print "[NextImageTask] getWidth | width 0"
        return invalid
    end if
    return width
end function

function getHeight(input as object) as integer
    print "[NextImageTask] getHeight"
    height = input.height
    if height = invalid
        print "[NextImageTask] getHeight | height invalid"
        return invalid
    else if height = 0
        print "[NextImageTask] getHeight | height 0"
        return invalid
    end if
    return height
end function
