

package require Tk

set howMany 0
set timeLeft 0
set hoursLeft 0

set fontFamily Eurostile


trace add variable howMany write updateDisplay

proc updateDisplay {args} {
    global howMany
    global timeLeft
    global hoursLeft

    set timeLeft [clock format $howMany -format %M:%S]
    set hoursLeft [expr $howMany / 3600]
}


proc makeGUI {} {
    wm title . {timer}

    font create FCounter -size 240 -family $::fontFamily
    font create FCounterSmall -size 36 -family $::fontFamily

    pack [frame .f_time -padx 50] -side top -expand 1
    pack [label .f_time.l_timeLeftHours -font FCounterSmall\
          -padx 0 -textvariable hoursLeft\
         ] -side left -anchor ne -ipady 40
    pack [label .f_time.l_timeLeftHoursMark -font FCounterSmall\
          -padx 0 -text h\
         ] -side left -anchor ne -ipady 40
    pack [label .f_time.l_timeLeft -font FCounter\
          -textvariable timeLeft\
         ] -side left

    pack [frame .f_buttons] -side bottom -anchor s 

    foreach time {5 10 15 20 25 30} {
        pack [button .f_buttons.b_$time -text $time\
              -command "startTimer $time"\
             ] -side left
    }
    makeCustomTimeWidgets
    pack [button .f_buttons.b_stop -text reset\
          -command resetTimer\
         ] -padx 20 -side left
    pack [button .f_buttons.b_pause -text pause\
          -command pauseTimer -state disabled\
         ] -side left
    
    update idletasks
}


proc makeCustomTimeWidgets {} {
    pack [frame .f_buttons.f_customTime] -side left
    pack [entry .f_buttons.f_customTime.e_customTime\
          -validate key\
          -validatecommand "validateCustomTime %S %P" -width 3\
         ] -side left
    bind .f_buttons.f_customTime.e_customTime <Return> startCustomTimer
    button .f_buttons.f_customTime.b_start\
           -text start -command startCustomTimer
}

proc validateCustomTime {char value} {
    if {$value == {}} {
        set value 0
        hideStartButton
        return true
    }

    if [string is digit $char] {
        showStartButton
        set timeLen [string length $value]
        if {$timeLen > 3} {
            .f_buttons.f_customTime.e_customTime configure -width [expr {$timeLen + 1}]
        } else {
            .f_buttons.f_customTime.e_customTime configure -width 3
        }
        return true
    } else {
        return false
    }
}

proc startCustomTimer {} {
    focus .
    set customTime [.f_buttons.f_customTime.e_customTime get]
    regexp {^0*(\d+)$} $customTime _dummy customTime
    startTimer $customTime
}



proc startTimer {time} {
    after cancel timerSeconds
    set ::howMany [expr $time * 60]
    timerSeconds
    enablePauseButton
    resetPauseButton
    bind . <space> {pauseTimer}
    focus .
}


proc pauseTimer {} {
    after cancel timerSeconds
    .f_buttons.b_pause configure -text resume -command resumeTimer
    bind . <space> {resumeTimer}
}

proc resumeTimer {} {
    timerSeconds
    .f_buttons.b_pause configure -text pause -command pauseTimer
    bind . <space> {pauseTimer}
    focus .
}

proc resetPauseButton {} {
    if [string equal [.f_buttons.b_pause cget -text] resume] {
        .f_buttons.b_pause configure -command pauseTimer -text pause
    }
}

proc enablePauseButton {} {
    .f_buttons.b_pause configure -state normal
}

proc disablePauseButton {} {
    .f_buttons.b_pause configure -state disabled
}


proc resetTimer {} {
    after cancel timerSeconds
    set ::howMany 0
    resetPauseButton
    disablePauseButton
    bind . <space> {}
    focus .
}


proc showStartButton {args} {
    pack .f_buttons.f_customTime.b_start -side left
}

proc hideStartButton {args} {
    pack forget .f_buttons.f_customTime.b_start
}



proc checkIfMissingFont {} {
    if ![regexp -- $::fontFamily [font actual FCounter]] {
        tk_messageBox -title {missing font} \
            -message "The look of this application has been optimized\
                for the '$::fontFamily' font. You can download it for\
                free from:\nhttp://www.fontpalace.com"
    }
}


proc timerSeconds {} {
    global timesUp
    global howMany
    
    if {$howMany > 0} {
        incr howMany -1
        after 1000 "timerSeconds"
    } else {
        #toggle the variable
        set timesUp [expr {[incr timesUp]%2}]
    }
    return
}


makeGUI
updateDisplay
checkIfMissingFont

