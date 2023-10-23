#Requires AutoHotkey v2.0
; https://www.autohotkey.com/boards/viewtopic.php?t=67317

Class Date {
    static Compare(dateA, dateB) => dateA >= dateB ? true : false

    static Parse(str, flip := false, standardFormat := false, short := false) {
        m3 := ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        mf := ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
        e2 := "i)(?:(\d{1,2}+)[\s\.\-\/,]+)?(\d{1,2}|(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\w*)[\s\.\-\/,]+(\d{2,4})"
        str := RegExReplace(str, "((?:" . SubStr(e2, 42, 47) . ")\w*)(\s*)(\d{1,2})\b", "$3$2$1", &a, 1)
        d1 := d2 := d3 := t1 := t2 := t3 := t4 := 0
    
        if RegExMatch(str, "i)^\s*(?:(\d{4})([\s\-:\/])(\d{1,2})\2(\d{1,2}))?"
            . "(?:\s*[T\s](\d{1,2})([\s\-:\/])(\d{1,2})(?:\6(\d{1,2})\s*(?:(Z)|(\+|\-)?"
            . "(\d{1,2})\6(\d{1,2})(?:\6(\d{1,2}))?)?)?)?\s*$", &i)
        {
            d3 := i.1
            d2 := i.3
            d1 := i.4
            try t1 := i.5
            try t2 := i.7
            try t3 := i.8
        }
        else if !RegExMatch(str, "^\W*(\d{1,2}+)(\d{2})\W*$", &t) {
            RegExMatch(str, "i)(\d{1,2})\s*:\s*(\d{1,2}):*\s*(:*\d{1,2})?\s*([ap]m)?", &t)
            RegExMatch(str, e2, &d)
            d1 := d.1
            d2 := d.2
            d3 := d.3
            try t1 := t.1
            try t2 := t.2
            try t3 := t.3
            try t4 := t.4
        }
    
        (this.HasValue(m3, d2) ? d2 := this.HasValue(m3, d2) : 0)
        (this.HasValue(mf, d2) ? d2 := this.HasValue(mf, d2) : 0)
        (!t1 ? t1 := 0 : 0)
        (!t2 ? t2 := 0 : 0)
        (!t3 ? t3 := 0 : 0)
    
        d3 := (d3 ? (StrLen(d3) = 2 ? 20 : "") d3 : A_YYYY)
        d2 := this.LongNum((d2 ? d2 : A_MM), 2)
        d1 := this.LongNum((d1 ? d1 : A_DD), 2)
        t1 := this.LongNum(t1 + (t4 ? (t1 = 12 ? (t4 = "am" ? -12 : 0) : (t4 = "am" ? 0 : 12)) : 0), 2)
        t2 := this.LongNum(t2, 2)
        t3 := this.LongNum(t3, 2)
    
        ; if day and month come out backwards, make flip=1
        d := d3 (flip ? d1 d2 : d2 d1) t1 t2 t3
    
        ; if short=1, if there's no time, just send the first 8 digits
        (short && SubStr(d, 9, 6) = "000000") ? d := SubStr(d, 1, 8) : ""
    
        ;if you want your date in a standard format, standardFormat=1. You can edit this to be your own standard format.
        (standardFormat) ? d := SubStr(d, 1, 4) "-" SubStr(d, 5, 2) "-" SubStr(d, 7, 2) : ""
    
        return d
    }

    static HasValue(haystack, needle) {
        if !(IsObject(haystack)) || (haystack.Length = 0)
            return 0
        for index, value in haystack
            if (value = needle)
                return index
        return 0
    }
    
    static LongNum(n := 0, digits := 2) {
        while (StrLen(n) < digits)
            n := "0" n
    
        return n
    }
}