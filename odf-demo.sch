<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    
    <ns prefix="text" uri="urn:oasis:names:tc:opendocument:xmlns:text:1.0"/>
    <ns prefix="office" uri="urn:oasis:names:tc:opendocument:xmlns:office:1.0"/>
    <ns prefix="style" uri="urn:oasis:names:tc:opendocument:xmlns:style:1.0"/>
    
    <let name="allowed-para-styles" value="('articlehead', 'bodytext', 'bibhead', 'bib', 
        //style:style[@style:parent-style-name = 'articlehead']/@style:name) "/>
    
    <let name="citation-refs" value="//text:span[@text:style-name = 'bibref']"/>
    
    <pattern id="date">
        <!-- bad date format -->
        <rule context="text:span[@text:style-name = 'bibdate']">
            <assert test=". castable as xs:date">text styled as 'bibdate' must be in the format 'YYYY-MM-DD'; got '<value-of select="."/>'</assert>
        </rule>
    </pattern>
    
    <pattern id="unexpected-para-style">
        <!-- non-empty body text -->
        <rule context="office:body//text:p[text()] | office:body//text:h[text()]">
            <report test="not(@text:style-name = $allowed-para-styles)">unexpected para style '<value-of select="@text:style-name"/>'; expected one of: <value-of select="$allowed-para-styles"/></report>
        </rule>
    </pattern>
    
    <pattern id="untagged-bibref">
        <!-- '[n]' in a text run -->
        <rule context="text:span[not(@text:style-name = ('bibref', 'bibnum'))]">
            <report test="matches(., '\[[0-9]+\]')">found possible unstyled citation reference</report>
        </rule>
    </pattern>
    
    <pattern id="broken-citation-link">
        <!-- citation number not referred to -->
        <rule context="text:span[@text:style-name = 'bibnum']">
            <assert test=". = $citation-refs">could not find a citation reference to this citation: '<value-of select="."/>'</assert>
        </rule>
    </pattern>
    
    <pattern id="missing-bib-heading">
        <!-- no heading for the bibliography -->
        <rule context="office:body//text:p[@text:style-name = 'bib'][not(preceding::text:p[@text:style-name = 'bib'])]">
            <assert test="preceding::text:p[@text:style-name = 'bibhead']">no bibliography heading found</assert>
        </rule>
    </pattern>
</schema>