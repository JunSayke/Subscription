#Requires AutoHotkey v2.0
#Include Webhook.ahk
#Include AES.ahk

Class Subscription {
    static __New() {
        this.winhttp := ComObject("WinHttp.WinHttpRequest.5.1")
        this.webhook := Webhook("https://discord.com/api/webhooks/1147841574693261352/okFioJpdI9ugLaUGCH4myTN9vCyHtPLXQPpG5sHqw4q276YaJ7J9-WsME9wVubz-qoXc")
        this.aes := AES("Hunyo_Encryption", "v1.0")
    }

    static GetKey(key) {
        if JSON := this.webhook.Get(this.aes.Decrypt(key))
            return this.ExtractKey(JSON["embeds"][1]["fields"])
    }

    static SetKey(expiration, subscription) {
        payload := this.webhook.Payload([Map("name", "Generating Key. . .", "value", "")], 1127128)
        if JSON := this.webhook.Post(payload) {
            payload := this.webhook.Payload([Map("name", "Key", "value", this.aes.Encrypt(JSON["id"])), Map("name", "Expiration", "value", expiration, "inline", true), Map("name", "Subscription", "value", subscription, "inline", true)], 1127128)
            if JSON := this.webhook.Patch(JSON["id"], payload)
                return this.ExtractKey(JSON["embeds"][1]["fields"])
        }
    }

    static UpdateKey(key) {

    }

    static CheckKey(key) {

    }

    static DisplayKey(user) {
        MsgBox("Key: " user["key"] "`nExpiration: " user["expiration"] "`tSubscription: " user["subscription"])
    }

    static ExtractKey(JSON) {
        user := Map()
        for i, v in JSON {
            switch v.Get("name") {
                case "Key":
                    user["key"] := v.Get("value")
                case "Expiration":
                    user["expiration"] := v.Get("value")
                case "Subscription":
                    user["subscription"] := v.Get("value")
            }
        }
        return user
    }
}

Subscription.DisplayKey(Subscription.GetKey("loCKyxG9iomtmHAak5hseyl/Nu3WTItyku7gXAV6+o4="))
; Subscription.SetKey("lifetime", "admin")