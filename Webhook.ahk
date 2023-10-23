#Requires AutoHotkey v2.0
#Include JSON.ahk

Class Webhook {
    static Payload(fields, color := 32768) => '{"embeds": [{"color": "' color '","fields": ' JSON.stringify(fields) '}]}'

    __New(url) {
        this.url := url
    }

    Send(method, messageId := "", payload := "") {
        static winhttp := ComObject("WinHttp.WinHttpRequest.5.1")

        if ((method = "GET" or method = "PATCH") and messageId = "") and ((method = "POST" or method = "PATCH") and payload = "")
            throw ValueError

        message := this.url . (method = "POST" ? "?wait=1" : "/messages/" messageId)
        winhttp.Open(method, message, false)
        winhttp.SetRequestHeader("Content-Type", "application/json")
        winhttp.Send(payload)
        winhttp.WaitForResponse()

        if (winHttp.StatusText = "OK")
            return JSON.parse(winhttp.ResponseText)
    }

    ; Send a GET request to discord webhook.
    Get(messageId) => this.Send("GET", messageId)
 
    ; Send a POST request to discord webhook.
    Post(payload) => this.Send("POST",, payload)

    ; Send a PATCH request to discord webhook.
    Patch(messageId, payload) => this.Send("PATCH", messageId, payload)
}
















; winhttp := ComObject("WinHttp.WinHttpRequest.5.1")
; winhttp.Open("GET", "https://drive.google.com/uc?export=download&id=1yJ4tJqVhlZiKLoKbfwZFC2ZE7CPLT3yu", false)
; winhttp.Send()
; winhttp.WaitForResponse()
; response := winhttp.ResponseText

; if RegExMatch(response, "webhook.(.*)`nmain.(.*)`nusers.(.*)", &match) {
;     bot := Webhook(match[1])
;     downloadLink := Map("name", "Download", "value", "Download Link")
;     buildVersion := Map("name", "Version", "value", "v1.0.0")
;     bot.Patch(match[2], Webhook.Payload([downloadLink, buildVersion], 32768))
;     bot.Patch(match[3], '{"embeds": [{"color": 32768, "title": "Online Users", "description": "' A_ComputerName '"}]}')
; }