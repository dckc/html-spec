require utils/textutil.tcl
require utils/auxfile.tcl
require specs/tfmt.tcl

global xtrainfo; 	# stuff that doesn't appear in the document
set xtrainfo(WG)	"HTML Working Group"
set xtrainfo(EXPIREDATE)	"In six months"

environment counter prefix "" number 0

specification xrefs {

    {elements "h1t h2t h3t h4t"} {
	START {
	    set title [content]
	    withNode parent { setprop reftitle $title } 
	}
    }
    {element h1} {
	START {
		global secmap
		set refnumber [counter get number]
		incr refnumber 
		counter set number $refnumber
		setprop refnumber $refnumber
		setprop level 1
		setprop pageno [getauxinfo pageno [docpostl]]
		set secmap($refnumber) [docpostl]
		counter bgroup  prefix $refnumber  number 0  level 2
	}
	END {
		counter egroup
	}
    }
    {elements "h2 h3 h4"} {
        START {
		global secmap
		counter set number [set number [expr [counter get number]+1]]
		set refnumber "[counter get prefix].$number"
		setprop refnumber $refnumber
		setprop level [counter get level]
		setprop pageno [getauxinfo pageno [docpostl]]
		set secmap($refnumber) [docpostl]
		counter bgroup \
			prefix	$refnumber \
			number	0 \
			level	[expr [counter get level] + 1]
	}
	END {
		counter egroup
	}
    }
}

proc reftext {refid} {
    set reftext "???"
    withNode doctree el withattval id $refid {
	set refnumber [query propval refnumber]
	set reftitle [query propval reftitle]
	set reftext "$refnumber, \"$reftitle\"";
    }
    return $reftext
}

# docpostl: return 'treeloc document position' of current node
proc docpostl {} {
    return [lreverse [query* ancestor seqno]]
}

### Extract stuff from frontmatter:
#
# heuristic to extract authors' last names for RFC footer.
# Assume names are formatted as "F. Lastname".
# %%% Does not distinguish primary/secondary authors;
# %%% could lead to very long footers with multiple authors.
#

proc docauthors {} {
    # docroot treeloc "1 1 1" locates the PAPERFRONT element
    set lastnames ""
    foreach author \
	[query* docroot treeloc "1 1 1" \
		child element author child element name \
		subtree content] {
	if [regexp {([A-Z]\.) *(.*)} $author dummy1 initial lastname] {
	    lappend lastnames $lastname
	}
    }
    return [join $lastnames ", "]
}

proc docnumber {} {
    return [string trim [join \
	    [query docroot treeloc "1 1 1" subtree element DOCNUM \
			subtree cdata content]]]
}

# doctitle: select line 1 of <TITLE> element (which may have multiple lines)
proc doctitle {} {
    return [string trim [join \
		[query docroot treeloc "1 1 1" \
			child element TITLE \
			treeloc "1 1" \
			subtree cdata content]]]
}

proc docdate {} {
    return [string trim [join \
		[query docroot treeloc "1 1 1" child element DATE \
			subtree cdata content]]]
}

#
# First-page header
#
proc page1lhead {} {
    global xtrainfo
    return [list \
	$xtrainfo(WG) \
	"INTERNET-DRAFT" \
	[docnumber] \
	"Expires: $xtrainfo(EXPIREDATE)" ]
}

proc page1rhead {} {
    set headlines ""
    withNode docroot treeloc "1 1 1" subtree element AUTHOR {
	foreachNode subtree elements {NAME ALINE} {
	    lappend headlines [string trim [content]]
	    # if ADDRESS not found for an author, check refid
	}
    }
    lappend headlines [docdate]
    return $headlines
}

proc openFile {sysid} {
    global env
    if [info exists env(ENTITYPATH)] {
	foreach dir [split $env(ENTITYPATH) ":"] {
	    if [file exists $dir/$sysid] {
		return [open $dir/$sysid r]
	    }
	}
    }
    if [file exists $sysid] {
	return [open $sysid r]
    }
    return ""
}
