require specs/snafu.tcl

proc main {} {
    global finalversion; set finalversion 1
    global tocdepth; set tocdepth 2
    readauxfile
    process xrefs
    selectNode docroot
    paginate 58
    show
    writeauxfile
}


# only a few SDATA entities used in the document...
global sdataMap
array set sdataMap {
	{[ccedil]}	{c}
	{[gt    ]}	{>}
	{[lt    ]}	{<}
	{[nbsp  ]}	{ }
	{[amp   ]}	{&}
	{[mdash ]}	{--}
}

### Formatting spec:
#

specification plaintext {

	{dataent withdcn ASCII within LISTING} {
	    DATAENT {
		if {[query? sysid]&&[set fp [openFile [query sysid]]]!=""} {
		    doListing $fp
		    close $fp
		} else {
		    cdata "*** "
		    cdata "Error processing entity reference "
		    cdata "&[query ename];"
		    cdata " ***"
		    puts stderr "Error processing reference &[query ename];"
		    where
		}
	    }
	}
	{dataent} {
	    DATAENT	{
		paragraph bgroup indent 0
		cdata "*** "
		cdata "Can't process entity reference "
		cdata "&[query ename]; with DCN [query dcn] just yet.  "
		cdata "Sorry for the inconvenience." 
		cdata " ***"
		par 
		paragraph egroup
		puts stderr "&[query ename]: don't grok DCN [query dcn]."
	    }
	}

	{textnode within LISTING} {
	    CDATA 	{
		addlines [indent \
				[list [detabline [content]]] \
				[paragraph get baseindent]]
	    }
	    RE		{ }
	}

	{element LISTING}  {
	    START 	{ par; nl; needlines 3; paragraph bgroup pagewidth 72 }
	    END		{ nl ; paragraph egroup }
	}

	{textnode within P} {
	    CDATA	{ cdata [content] }
	    SDATA	{ 
		global sdataMap
		if [info exists sdataMap([content])] {
		    cdata $sdataMap([content])
		} else {
		    puts stderr "No SDATA map for [content]"
		}
	    }
	    RE  	{ cdata " " }
	}

	{element P} {
	    START { needlines 1 }
	    END { par }
	}
	{element NOTE} {
	    START { 
		par;	 # if inside a paragraph
		nl 1;
		paragraph bgroup 
		narrower [paragraph get baseindent]
		cdata "NOTE - "
	    }
	    END {
		paragraph egroup; nl 1
	    }
	}

	{textnode ancestor elements "h1t h2t h3t h4t h5t h6t"} { 
	    CDATA	{ cdata [content] }
	    RE  	{ cdata " " }
	}
	{elements "h1t h2t h3t h4t h5t h6t"} {
	    START { 
		nl 2; needlines 3;
		pagemark;
		paragraph bgroup indent 0 width 64
		cdata "[query parent propval refnumber].  "
	    }
	    END {
		par; nl;
		paragraph egroup
	    }
	}

	{element ABSTRACT} {
	    START {
		nl 2
		paragraph bgroup 
		addlines [center {"ABSTRACT"} [paragraph get width]]
		nl 1
	    }
	}
	{element COPYRITE} {
	    START {
		paragraph bgroup
		fullwidth
	    }
	    END {
		paragraph egroup
	    }
	}
	{element TOC} {
	    START { 
		global tocdepth
		nl 1;
		needlines 15;
		addlines [center [list "CONTENTS"] [paragraph get pagewidth]]
		nl 2;
		makeToc $tocdepth;
		nl 2
		needlines 15;
	    }
	}

	{elements "OL UL"} {
	    START {
		par;
		paragraph bgroup licount 0
		adjustMargins [paragraph get baseindent] 0
	    }
	    END {
		paragraph egroup
	    }
	}
	{element LI in UL} {
	    START { cdata " * " }
	    END { par; nl 1 }
	}
	{element LI in OL} {
	    START { 
		set number [paragraph get licount]
		incr number
		paragraph set licount $number
		cdata " ${number}. "
	    }
	    END { par; nl 1 }
	}
	{element TL} {
	    START { nl }
	    END { nl }
	}
	{element TLIT} {
	    START {
		paragraph bgroup parskip 0 width 24
	    }
	    END {par; paragraph egroup}
	}
	{element TLID} {
	    START {
		paragraph bgroup 
	        adjustMargins 8 0
	    }
	    END { par; nl 1;  paragraph egroup }
	}

	{element HDREF withatt REFID} {
	    START {
		cdata [reftext [query attval refid]]
	    }
	}

	{element URI} {
	    START { cdata "<URL:" }
	    END { cdata ">" }
	}
	{element Q} {
	    START { cdata {``}}
	    END   { cdata {''}}
	}
	{element TAG} {
	    START { cdata {<}}
	    END   { cdata {>}}
	}
	{element CODE} {
	    START { cdata {`}}
	    END   { cdata {'}}
	}
	{element EMPH} {
	    START { cdata {_}}
	    END   { cdata {_}}
	}
	{element MBOX} {
	    START { cdata {<}}
	    END   { cdata {>}}
	}

	{element SPAPER} {
	    START 	{ addlines [page1header] }
	    END		{ pagebreak; }
	}
	{textnode within LINE in TITLE} {
	    CDATA	{ cdata [content] }
	}
	{element LINE in TITLE} {
	    END {
		addlines [center [parlines] [paragraph get pagewidth]]
	    }
	}
	{element TITLE} {
	    START { nl 2 }
	    END { nl 2 }
	}

	{el} {
	    START { set missing([query gi]) 1 }
	}
	{textnode within BODY} {
	    CDATA {
		puts stderr "Unaccounted-for body text: <[content]>"
		where
	    }
	}
}

proc makeToc {{tocdepth 1}} {
    foreachNode doctree el hasprop refnumber {
	if {[query propval level] <= $tocdepth} {
	    addlines [indent [list [tocline]] [paragraph get indent]]
	}
    }
}

proc tocline {} {
    set refnumber [query propval refnumber]
    set reftitle [query propval reftitle]
    set pgnum [query propval pageno]
    set width [paragraph get width]

    set head [format "%-6s %s" $refnumber $reftitle]
    incr width -[string length "$head  $pgnum"]
    return "$head [repeatstr "." $width] $pgnum"
}

proc page1header {} {
    return [adjoin [ljust [page1lhead] 36] [rjust [page1rhead] 36] ""]
}


#
# Page header for second and subsequent pages:
#

proc pageheader {} {
    # for RFCs:
    #return [threepart "[docnumber]" " [doctitle] " [docdate] 72]
    # for I-Ds:
    return [threepart "INTERNET-DRAFT" " [doctitle] " [docdate] 72]
}
proc pagefooter {} {
    return [threepart [docauthors] "" "\[Page [thepagenum]]" 72]
}
proc thepagenum {} {
    global pageno
    return $pageno
}

proc makeheader {} {
    global pageno
    if {$pageno != 1} { return [list [pageheader] ""] }
    return {}
}
proc makefooter {} {
    return [list "" [pagefooter]]
}

proc doListing {fp {lmargin 0}} {
    set lineno 0
    set pagewidth [expr [paragraph get pagewidth] - $lmargin]
    set lines {}
    while {[gets $fp line] != -1} {
	set line [detabline $line 8]
	set prefix [repeatstr { } $lmargin]
	while {[string length $line] > $pagewidth} {
	    lappend lines \
		"${prefix}[string range $line 0 [expr $pagewidth - 2]]\\"
	    set line [string range $line $pagewidth end]
	    if {$lmargin >= 3} {
		set prefix " & [repeatstr { } [expr $lmargin - 3]"
	    }
	}
	lappend lines "${prefix}${line}"
    }
    addlines $lines
}

proc doNumberedListing {fp {linecount 5}} {
    set lineno 0
    set pagewidth [expr [paragraph get pagewidth] - 6]
    set lines {}
    while {[gets $fp line] != -1} {
	incr lineno
	set line [detabline $line 8]
	if {$linecount != 0 && $lineno % $linecount == 0} { 
	    set prefix "[format %3d $lineno]  "
	} else {
	    set prefix "     "
	}
	while {[string length $line] > $pagewidth} {
	    lappend lines \
		"${prefix}[string range $line 0 [expr $pagewidth - 1]]\\"
	    set line [string range $line $pagewidth end]
	    set prefix "  &  "
	}
	lappend lines "${prefix}${line}"
    }
    addlines $lines
}

### Interactive utilities:
#
proc toc {{depth 99}} {
    set toplevel -1
    foreachNode subtree hasprop refnumber { 
	set level [query propval level];
	if {$toplevel == -1} { set toplevel $level }
	if { $level < $toplevel + $depth } {
	    puts "[query propval refnumber]  [query propval reftitle]"
	}
    }
}

proc where {} {
    withNode ancestor hasprop refnumber {
	puts "[query propval refnumber]  [query propval reftitle]"
    }
}

proc section {secnum} {
    global secmap
    if {![info exists secmap($secnum)]} {
	return 0
    }
    selectNode docroot treeloc $secmap($secnum)
}

proc show {{filename -}} {
    global missing fout
    if [info exists missing] { unset missing }
    set missing(x) x; unset missing(x)
    if {$filename != "-"} {
	set fout [open $filename w]
    }
    process plaintext 
    if {$filename != "-"} {
	close $fout
	set fout stdout
    }
    #puts [lsort [array names missing]]
}

set dfnMap(x) x
proc makeIndex {} {
    global dfnMap
    unset dfnMap
    foreachNode doctree element TLIT {
	lappend dfnMap([content]) [docpostl]
    }
}

proc describe {text} {
    global dfnMap
    if [info exists dfnMap($text)] {
	foreach loc $dfnMap($text) {
	    withNode docroot treeloc $loc parent {
		puts ""
		where
		puts "" 
		show
		puts "" 
	    }
	}
    } else {
	puts "No description for '$text'"
    }
}


### Page references:
global finalversion; set finalversion 0
proc pagemark {} {
    global pageno finalversion
    if !$finalversion return;
    withNode ancestor hasprop refnumber {
	setauxinfo pageno [docpostl] $pageno
    }
}

