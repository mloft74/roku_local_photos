function init()
    print "[CheckConnectionTask] init"
    m.top.functionName = "checkConnection"

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

    xfer = CreateObject("roUrlTransfer")
    xfer.setUrl(serverIp + "/api/ping")
    responseStr = xfer.getToString()
    if responseStr = invalid
        return "Could not get response"
    else if responseStr = ""
        return "Response was empty"
    endif

    response = parseJson(xfer.getToString())
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
end function
