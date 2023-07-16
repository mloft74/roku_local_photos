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
    endif

    serverIp = m.registrySection.read("serverIp")
    if serverIp = invalid or serverIp = ""
        return "IP not set"
    endif

    m.xfer.setUrl(serverIp + "/api/ping")
    if not m.xfer.asyncGetToString()
        return "Failed to start request"
    endif

    while true
        msg = wait(0, m.port)
        msgType = type(msg)
        if not msgType = "roUrlEvent"
            return "Got wrong event type from port: " + msgType
        endif
        if not msg.getInt() = 1
            continue while
        endif

        if not msg.getResponseCode() = 200
            return msg.getFailureReason()
        endif

        responseStr = msg.getString()
        if responseStr = invalid
            return "Could not get response"
        else if responseStr = ""
            return "Response was empty"
        endif

        response = parseJson(responseStr)
        if response = invalid
            return "Could not parse response"
        endif

        message = response.message
        if message = invalid
            return "Could not find message on response"
        else if message = ""
            return "Message on response was empty"
        else if message = "pong"
            return "Connected"
        else
            return message
        endif
    endwhile
end function
