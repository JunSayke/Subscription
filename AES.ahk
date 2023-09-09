#Requires AutoHotkey v2.0
#Include CNG.ahk

Class AES {
    __New(pass, iv) {
        this.pass := pass
        this.iv := iv
    }

    Encrypt(key) => Encrypt.String("AES", "CBC", key, this.pass, this.iv)
    Decrypt(key) => Decrypt.String("AES", "CBC", key, this.pass, this.iv)
}