#Requires AutoHotkey v2.0
#Include JSON.ahk

Class Webhook {
    __New(url) {
        this.winhttp := ComObject("WinHttp.WinHttpRequest.5.1")
        this.url := url
    }

    Get(id) => this.Send("GET", id)

    Post(payload) => this.Send("POST", , payload)

    Patch(id, payload) => this.Send("PATCH", id, payload)

    Send(method, id := "", payload := "") {
        if ((method = "GET" or method = "PATCH") and id = "") and ((method = "POST" or method = "PATCH") and payload = "")
            throw ValueError

        this.winHttp.Open(method, this.url (method = "POST" ? "?wait=1" : "/messages/" id), false)
        this.winHttp.SetRequestHeader("Content-Type", "application/json")
        this.winHttp.Send(payload)
        this.winHttp.WaitForResponse()

        if (this.winHttp.status = 200)
            return JSON.parse(this.winHttp.ResponseText)
    }

    Payload(fields, color) => '{"embeds": [{"color": "' color '","fields": ' JSON.stringify(fields) '}]}'
}
