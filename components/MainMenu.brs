function init()
    print "[MainMenu] init"

    m.registrySection = createObject("roRegistrySection", "rokuLocalPhotos")
    serverIp = m.registrySection.read("serverIp")

    m.serverIpValue = m.top.findNode("serverIpValue")
    if serverIp <> invalid and serverIp <> "" then
        m.serverIpValue.text = serverIp
    else
        m.serverIpValue.text = "IP not set"
    end if

    m.mainMenuOptions = m.top.findNode("mainMenuOptions")
    m.mainMenuOptions.observeField("itemSelected", "onItemSelected")

    m.top.setFocus(true)
end function

function onItemSelected()
    print "[MainMenu] onItemSelected"
    index = m.mainMenuOptions.itemSelected
    if index = 0 then
        checkConnection()
    else if index = 1 then
        openServeIpDialog()
    else
        unknownOptionTitle = m.mainMenuOptions.content.getChild(index).title
        print "unhandled option: " + unknownOptionTitle
    end if
end function

function checkConnection()
    print "[MainMenu] checkConnection"
end function

function openServeIpDialog()
    print "[MainMenu] openServeIpDialog"
    dialog = createObject("roSGNode", "StandardKeyboardDialog")
    dialog.id = "serverIpDialog"
    dialog.title = "Server IP"
    dialog.buttons = ["Done"]

    dialog.observeField("buttonSelected", "saveServerIp")

    m.top.dialog = dialog
end function

function saveServerIp()
    print "[MainMenu] saveServerIp"

    serverIp = m.top.dialog.text

    m.serverIpValue.text = serverIp

    m.registrySection.write("serverIp", serverIp)
    m.registrySection.flush()

    m.top.dialog.unobserveField("buttonSelected")
    m.top.dialog.close = true
end function
