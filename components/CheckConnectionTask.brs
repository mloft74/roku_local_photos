function Init()
    print "[CheckConnectionTask] Init"
    m.top.functionName = "CheckConnection"

    m.port = CreateObject("roMessagePort")

    m.xfer = CreateObject("roUrlTransfer")
    m.xfer.SetPort(m.port)
    m.registrySection = CreateObject("roRegistrySection", "rokuLocalPhotos")
end function

function CheckConnection()
    print "[CheckConnectionTask] CheckConnection"
    m.top.message = CheckConnectionInternal()
    m.top.control = "done"
end function

function CheckConnectionInternal() as string
    if not m.registrySection.Exists("serverIp")
        return "Server IP not set"
    end if

    serverIp = m.registrySection.Read("serverIp")
    if serverIp = invalid or serverIp = ""
        return "IP not set"
    end if

    m.xfer.SetUrl(serverIp + "/api/ping")
    if not m.xfer.AsyncGetToString()
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

        message = response.message
        if message = invalid
            return "Could not find message on response"
        else if message = ""
            return "Message on response was empty"
        else if message = "pong"
            return "Connected"
        else
            return message
        end if
    end while
end function
