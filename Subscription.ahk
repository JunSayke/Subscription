#Requires AutoHotkey v2.0
#Include Webhook.ahk
#Include CNG.ahk
#Include DateParser.ahk

Class Subscription extends Webhook {
    ; Return a user fields map object.
    static CreateUserField(key, devices, expiration, subscriptions) {
        fields := [
            Map("name", "License Key", "value", key),
            Map("name", "Expiration", "value", expiration, "inline", true), 
            Map("name", "Devices", "value", devices, "inline", true),
            Map("name", "Subscriptions", "value", subscriptions),
        ]
        return fields
    }

    ; Return a user map object.
    static CreateUser(key, devices, expiration, subscriptions) {
        user := Map()
        user["License Key"] := key
        user["Devices"] := devices
        user["Expiration"] := expiration
        user["Subscriptions"] := subscriptions
        return user
    }

    ; Return user expiration status.
    static CheckExpiry(user) {
        expiration := Date.Parse(user["Expiration"])
        status := user["Expiration"] = "Lifetime" ? "Lifetime License" 
                : Date.Compare(expiration, A_NowUTC + 8) ? FormatTime(expiration, "MMMM dd, yyyy") 
                : "Expired License"
        return status
    }

    ; Return a user map object from JSON.
    static Extract(JSON) {
        user := Map()
        for i, v in JSON {
            user[v["name"]] := v["value"]
        }
        return user
    }

    ; Display user map object details and set A_Clipboard to user license key.
    static DisplayUser(user) {
        A_Clipboard := user["License Key"]
        MsgBox("License Key:`t" user["License Key"] "`nExpiration:`t" user["Expiration"] "`nDevices:`t`t" user["Devices"] "`nSubscriptions:`t" user["Subscriptions"] "`nStatus:`t`t" Subscription.CheckExpiry(user))
    }

    static CreateLicenseKeyIni() => IniWrite("your_license_key", "licensekey.ini", "subscription", "license_key")

    static ExtractLicenseKeyIni() => IniRead("licensekey.ini", "subscription", "license_key")

    static Encrypt(key) => Encrypt.String("AES", "CBC", key, "Hunyo_Encryption", "v1.0")
    
    static Decrypt(key) => Decrypt.String("AES", "CBC", key, "Hunyo_Encryption", "v1.0")
    
    __New(url) {
        this.url := url
        
        if not FileExist("licensekey.ini") 
            Subscription.CreateLicenseKeyIni()
    }

    ; Accept license key as a parameter and return a user map object value.
    GetKey(key) {
        key := Subscription.Decrypt(key)
        if JSON := this.Get(key) {
            user := Subscription.Extract(JSON["embeds"][1]["fields"])
            return this.AppendDevice(user, 1)
        }
    }

    ; Accept user map object as a parameter and return a new user map object value.
    SetKey(user) {
        key := Subscription.Decrypt(user["License Key"])
        user := Subscription.CreateUserField(user["License Key"], user["Devices"], user["Expiration"], user["Subscriptions"])
        payload := Subscription.Payload(user)
        if JSON := this.Patch(key, payload)
            return Subscription.Extract(JSON["embeds"][1]["fields"])
    }

    ; Accept expiration and subscriptions as a parameters and return a new user map object value.
    CreateKey(expiration, subscriptions) {
        fields := [Map("name", "Generating User Account. . .", "value", "")]
        payload := Subscription.Payload(fields)
        if JSON := this.Post(payload) {
            key := Subscription.Encrypt(JSON["id"])
            user := Subscription.CreateUser(key, 0, expiration, subscriptions)
            return this.SetKey(user)
        }
    }

    ; Accept user map object and count as a parameters and return a new user map object value.
    AppendDevice(user, count) {
        user["Devices"] += count
        return this.SetKey(user)
    }
}