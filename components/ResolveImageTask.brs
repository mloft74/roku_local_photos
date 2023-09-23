function Init()
    print "[ResolveImageTask] Init"
    m.top.functionName = "ResolveImage"

    m.port = CreateObject("roMessagePort")

    m.xfer = CreateObject("roUrlTransfer")
    m.xfer.SetPort(m.port)
    m.registrySection = CreateObject("roRegistrySection", "rokuLocalPhotos")
end function

function ResolveImage()
    print "[ResolveImageTask] ResolveImage"
    m.top.message = ResolveImageInternal()
    m.top.control = "done"
end function

function ResolveImageInternal() as string
    if not m.registrySection.Exists("serverIp")
        return "Server IP not set"
    end if

    serverIp = m.registrySection.Read("serverIp")
    if serverIp = invalid or serverIp = ""
        return "IP not set"
    end if

    m.xfer.SetUrl(serverIp + "/api/image/resolve")
    m.xfer.AddHeader("content-type", "application/json")
    body = {}
    body["fileName"] = m.top.fileName
    json = FormatJson(body)
    if not m.xfer.AsyncPostFromString(json)
        return "Failed to start request"
    end if

    while true
        msg = Wait(0, m.port)
        if msg = invalid
            return "Roku message port returned invalid"
        end if

        msgType = Type(msg)
        if msgType <> "roUrlEvent"
            return "Got wrong event type from port: " + msgType
        end if
        if msg.GetInt() <> 1
            continue while
        end if

        if msg.GetResponseCode() <> 200
            return msg.GetFailureReason()
        end if

        responseStr = msg.GetString()
        if responseStr = invalid
            return "Could not get response"
        else if responseStr = ""
            return "Response was empty"
        end if

        response = ParseJson(responseStr)
        if response = invalid
            return "Could not parse response"
        end if

        resolveStatus = response.resolveStatus
        if resolveStatus = invalid
            return "Could not find resolveStatus on response"
        else if resolveStatus = ""
            return "Resolve status on response was empty"
        else
            return resolveStatus
        end if
    end while
end function
