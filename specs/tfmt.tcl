###
# tfmt.tcl
# simple-minded text formatter
#

require utils/textutil.tcl

environment paragraph \
	pagewidth 72 width 64 indent 4 parskip 1 baseindent 4

proc adjustMargins {lm rm} {
    paragraph set \
	width  [expr [paragraph get width] - $lm - $rm] \
	indent [expr [paragraph get indent] + $lm]
}

proc setMargins {lm rm} {
    paragraph set \
	width  [expr [paragraph get pagewidth] - $lm - $rm] \
	indent $lm
}

proc narrower {n} { adjustMargins $n $n }

proc fullwidth {} {
    paragraph set indent 0 width [paragraph get pagewidth]
}

global fout; if {![info exists fout]} {set fout stdout}
global words; set words ""
global lines; set lines ""
global blanklines; set blanklines 0
global lineno pageno paginating pagelen;
set pageno 0; set lineno 0; set paginating 0
set pagelen 58
global useformfeeds; set useformfeeds 1

proc cdata {text} {
    global words
    append words $text
}

proc parbreak {} {
    global words
    global lines
    append lines [wordwrap [split $words] [paragraph get width]]
    set words ""
}

proc parlines {} {
    global lines
    parbreak;
    set parlines $lines
    set lines ""
    return $parlines
}

proc par {} {
    addlines [indent [parlines] [paragraph get indent]]
    nl [paragraph get parskip];
}

proc addlines {lines} {
    global blanklines
    foreach line $lines { lineout $line }
    if [llength $lines] {
	set blanklines 0
    }
    return;
}
proc nl {{n 1}} {
    global blanklines
    while {$blanklines < $n} {
	lineout {}
	incr blanklines
    }
    return;
}

proc lineout {line} {
    global fout paginating
    if !$paginating {
	puts $fout $line
	return;
    }
    global lineno pageno paginating pagelen;
    if {$lineno == 0} {
	set head [makeheader];
	putlines $head $fout
	incr lineno [llength $head]
    }
    puts $fout $line
    if {[incr lineno] >= $pagelen} pagebreak;
}

#
# primitive widow control: 
# (or is this an orphan?  Anyway, the one that's at the bottom of the page)
# 
proc needlines {n} {
    global lineno pagelen paginating
    if !$paginating return;
    if {$pagelen - $lineno < $n} pagebreak;
}

proc pagebreak {} {
    global paginating pagelen lineno pageno useformfeeds
    global fout
    if !$paginating return
    while {$lineno < $pagelen} { puts $fout ""; incr lineno }
    putlines [makefooter] $fout
    if $useformfeeds { puts $fout "\014"}
    incr pageno
    set lineno 0
    # make 'nl' stop adding blanks: (%%% 'nl n>pagelen' infinite loop)
    global blanklines; set blanklines $pagelen
    return;
}

# 'nlines' is length of page including header and footer.
# %%% Assume footer is 2 lines.
proc paginate {nlines} {
    global pageno paginating pagelen
    set pageno 1
    if {$nlines} {
	set paginating 1
	set pagelen $nlines
	incr pagelen -2
    } else {
	set paginating 0
    }
}
