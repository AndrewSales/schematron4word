<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    
    <ns prefix="w" uri="http://schemas.microsoft.com/office/word/2003/wordml"/>
    
    <let name="allowed-para-styles" value="('articlehead', 'bodytext', 'bibhead', 'bib')"/>
    
    <let name="citation-refs" value="//w:r[w:rPr/w:rStyle/@w:val = 'bibref']"/>
    
    <pattern id="date">
        <!-- bad date format -->
        <rule context="w:r[w:rPr/w:rStyle/@w:val='bibdate']">
            <assert test=". castable as xs:date">text styled as 'bibdate' must be in the format 'YYYY-MM-DD'; got '<value-of select="."/>'</assert>
        </rule>
    </pattern>
    
    <pattern id="unexpected-para-style">
        <!-- non-empty body text -->
        <rule context="w:p[not(parent::w:ftr) and not(parent::w:footnote) and not(parent::w:endnote)][w:r]">
            <report test="not(w:pPr/w:pStyle/@w:val = $allowed-para-styles)">unexpected para style '<value-of select="w:pPr/w:pStyle/@w:val"/>'; expected one of: <value-of select="$allowed-para-styles"/></report>
        </rule>
    </pattern>
    
    <pattern id="untagged-bibref">
        <!-- '[n]' in a text run -->
        <rule context="w:r[not(w:rPr/w:rStyle/@w:val = ('bibref', 'bibnum'))]">
            <report test="matches(., '\[[0-9]+\]')">found possible unstyled citation reference</report>
        </rule>
    </pattern>
    
    <pattern id="broken-citation-link">
        <!-- citation number not referred to -->
        <rule context="w:r[w:rPr/w:rStyle/@w:val = 'bibnum']">
            <assert test=". = $citation-refs">could not find a citation reference to this citation: '<value-of select="."/>'</assert>
        </rule>
    </pattern>
    
    <pattern id="missing-bib-heading">
        <!-- no heading for the bibliography -->
        <rule context="w:p[w:pPr/w:pStyle/@w:val = 'bib'][not(preceding::w:p[w:pPr/w:pStyle/@w:val = 'bib'])]">
            <assert test="preceding::w:p[w:pPr/w:pStyle/@w:val = 'bibhead']">no bibliography heading found</assert>
        </rule>
    </pattern>
    
    <pattern id="bad-date-simplified">
        <!-- bad date format -->
        <rule context="span[@style='bibdate']">
            <assert test=". castable as xs:date">text styled as 'bibdate' must be in the format 'YYYY-MM-DD'; got '<value-of select="."/>'</assert>
        </rule>
    </pattern>
    
    <!-- TODO:
        missing abstract heading (hang off first para in doc)
    -->
    
</schema>