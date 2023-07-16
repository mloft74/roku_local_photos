function init()
    print "[CheckConnectionTask] init"
    m.top.functionName = "checkConnection"

    m.port = createObject("roMessagePort")

    m.xfer = createObject("roUrlTransfer")
    m.xfer.setPort(m.port)
    m.registrySection = createObject("roRegistrySection", "rokuLocalPhotos")
end function

function checkConnection()
    print "[CheckConnectionTask] checkConnection"
    m.top.message = checkConnectionInternal()
end function

function checkConnectionInternal() as string
    if not m.registrySection.exists("serverIp")
        return "Server IP not set"
    end if

    serverIp = m.registrySection.read("serverIp")
    if serverIp = invalid or serverIp = ""
        return "IP not set"
    end if

    m.xfer.setUrl(serverIp + "/api/ping")
    if not m.xfer.asyncGetToString()
        return "Failed to start request"
    end if

    while true
        msg = wait(0, m.port)
        if msg = invalid
            return "Roku message port returned invalid"
        end if

        msgType = type(msg)
        if not msgType = "roUrlEvent"
            return "Got wrong event type from port: " + msgType
        end if
        if not msg.getInt() = 1
            continue while
        end if

        if not msg.getResponseCode() = 200
            return msg.getFailureReason()
        end if

        responseStr = msg.getString()
        if responseStr = invalid
            return "Could not get response"
        else if responseStr = ""
            return "Response was empty"
        end if

        response = parseJson(responseStr)
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
