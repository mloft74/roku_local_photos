function init()
    print "[MainMenu] init"

    m.serverIpValue = m.top.findNode("serverIpValue")
    m.serverIpValue.text = "random text"

    m.mainMenuOptions = m.top.findNode("mainMenuOptions")
    m.mainMenuOptions.observeField("itemSelected", "onItemSelected")

    m.registrySection = CreateObject("roRegistrySection", "rokuLocalPhotos")

    m.top.setFocus(true)
end function

function onItemSelected()
    print "[MainMenu] onItemSelected"
    index = m.mainMenuOptions.itemSelected
    if index = 0 then
        onCheckConnection()
    else if index = 1 then
        onSetServerIp()
    else
        unknownOptionTitle = m.mainMenuOptions.content.getChild(index).title
        print "unhandled option: " + unknownOptionTitle
    end if
end function

function onCheckConnection()
    print "[MainMenu] onCheckConnection"
    serverIp = m.registrySection.read("serverIp")
    m.serverIpValue.text = serverIp
end function

function onSetServerIp()
    print "[MainMenu] onSetServerIp"
    m.registrySection.write("serverIp", "test word")
    m.registrySection.flush()
end function
