;;;
;;; Lazy nickname coloring script
;;;
;;; Color all nicknames automatically by calculating a numeric hash over the nickname.
;;; The calculated number is used to pick a (space delimited) color from the %colors variable
;;;  (set in "on START" event).
;;; Colors are made configurable because yellow on white is annoying, and you may want to use
;;;  black or white depending on your background color.
;;;

;; Initialize

on 1:START: {
  .initialize_coloring
}

alias initialize_coloring {
  ; use the following colors only
  .set %colors 1 2 3 4 5 6 7 9 10 11 12 13 14 15

  ; reset all entries in the clist
  while ($cnick(1)) {
    .uncolor_nick $cnick(1)
  }
}

;; Events

; Parse the /names <channel> response(s)
raw 353:*: {
  var %names = $4-
  var %i = 1
  var %n = $gettok(%names,0,32)
  while (%i <= %n) {
    var %current_nick = $gettok(%names,%i,32)
    var %firstchar = $mid(%current_nick, 1, 1)
    while (%firstchar isin @+%) {

      %current_nick = $mid(%current_nick, 2)
      %firstchar = $mid(%current_nick, 1, 1)
    }
    .color_nick %current_nick

    inc %i
  }
}

; Handle nick changes/joins/quits
on 1:NICK: {
  .uncolor_nick $nick
  .color_nick $newnick
}

on 1:JOIN:*: {
  .color_nick $nick
}

on 1:QUIT: {
  .uncolor_nick $nick
}

;; Helper functions

; usage: color_nick <nickname>
alias color_nick {
  if (!%colors) {
    .initialize_coloring
  }
  var %colors_idx = $calc($hash($1, 16) % $numtok(%colors, 32)) + 1
  var %nick_color = $gettok(%colors, %colors_idx, 32)
  .cnick $1 %nick_color
}

; usage: uncolor_nick <nickname>
alias uncolor_nick {
  .cnick -r $1
}
