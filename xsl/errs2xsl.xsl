<!--this script produces XSLT to embed comments in the original instance
		
		A comment in WordML is effected by AML (Annotation Markup Language).
		
		Points to note:
		
		o An aml:annotation/@w:type='Word.Comment.Start' should be placed at 
			the start of a commented paragraph, an aml:annotation/@w:type='Word.Comment.End'
			after its last run child (w:r). 
			N.B. For an *inline* comment, only the run in question is wrapped.
		
		o	Multiple comments may reference the same region.
		
		o Comments must have a unique ID. This is provided by the $pos variable, since
			the IDs must also be in numerical order. 
		
		o The template named 'insert-comment' below shows the format comments should take.
			The ID of the comment start/end should match the ID of the 
			aml:annotation/@type='Word.Comment'. (The @aml:createDate is a nicety and may be
			omitted - Word will provide a default value at render-time.

-->
			
<xsl:stylesheet
  version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:out='http://www.w3.org/1999/XSL/TransformAlias'
  xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
	xmlns:xs="http://www.w3.org/2001/XMLSchema">

<xsl:namespace-alias
  result-prefix="xsl"
  stylesheet-prefix="out" />
  
<xsl:output method="xml" indent='no'/>
	
<xsl:variable name="errors" select="(//svrl:failed-assert|//svrl:successful-report)"/>
<xsl:key name="error-by-location" match="svrl:failed-assert | svrl:successful-report" use="@location"/>
	
<xsl:template match="/">

<xsl:comment>auto-generated by errs2xsl.xsl</xsl:comment>

<!--the auto-generated stylesheet-->
<out:stylesheet version='2.0'
	xmlns:w="http://schemas.microsoft.com/office/word/2003/wordml"
  xmlns:v="urn:schemas-microsoft-com:vml"
  xmlns:w10="urn:schemas-microsoft-com:office:word"
  xmlns:sl="http://schemas.microsoft.com/schemaLibrary/2003/core"
  xmlns:aml="http://schemas.microsoft.com/aml/2001/core"
  xmlns:wx="http://schemas.microsoft.com/office/word/2003/auxHint"
  xmlns:o="urn:schemas-microsoft-com:office:office"
  xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882">

	<out:output indent='no'/>

	<!--timestamp param for use in Word comments-->  
	<out:param name="timestamp" select="current-dateTime()" />
	<out:param name="debug" select="false()" />

	<out:template match="/">
		<out:comment>auto-generated by wordqa</out:comment>
		<out:apply-templates/>
	</out:template>
	
	<xsl:variable name="doc" select="root()"/>
	
	<xsl:for-each select="distinct-values($errors/@location)">
		<xsl:variable name="err" select="key('error-by-location', ., $doc)"/>
		<xsl:apply-templates select="$err[1]">
			<xsl:with-param name="messages" select="$err/svrl:text"/>
		</xsl:apply-templates>
	</xsl:for-each>
	
	<!--N.B. elements and attributes in the aml namespace are ignored-->
	<out:template match='aml:* | @aml:* | w:docSuppData'/>
	
	<out:template match='w:wordDocument/@w:macrosPresent'>
		<!--we are suppressing binary data (macros), so this must be 'no'-->
	</out:template>
	
	<out:template match='*'>
		<out:copy>
			<out:apply-templates select='@*'/>
			<out:apply-templates/>
		</out:copy>	
	</out:template>
	
	<out:template match='@*'>
		<out:copy/>
	</out:template>
	
	<out:template match='//text()'>
		<out:copy/>
	</out:template>	
				
	<!--Word paras-->
	<out:template match='w:p' mode='annotate'>
		<out:param name="message" />
		<out:variable name='id' select='generate-id(.)'/>	
		<out:variable name='pos' select='count( preceding::* ) + count( ancestor-or-self::* )'/>

		<xsl:text>&#xA;</xsl:text><xsl:comment>*COMMENT START MARKERS*</xsl:comment>

		<!--if it's a naughty node, insert a comment start marker here-->
		<!--comment start marker(s)-->	
		<out:apply-templates select="$message" mode='start-comment'>
			<out:with-param name='pos' select='$pos'/>
		</out:apply-templates>

		<w:p>
			<!--strip existing aml:*-->
			<out:apply-templates select='*'/>

			<xsl:text>&#xA;</xsl:text><xsl:comment>*COMMENT END MARKERS*</xsl:comment>

			<!--comment end marker(s)-->
			<out:apply-templates select="$message" mode='end-comment'>
				<out:with-param name='pos' select='$pos'/>
			</out:apply-templates>
			
			<xsl:text>&#xA;</xsl:text><xsl:comment>*COMMENT CONTENT*</xsl:comment>
			
			<!--now the actual comment content-->
			<out:apply-templates select="$message" mode="comment-text">
				<out:with-param name="id" select="$pos"/>
			</out:apply-templates>
		</w:p>			
	</out:template>
	
	<!--Word runs (=inline styles/formatting)-->
	<out:template match="w:r" mode="annotate">
		<out:param name="message" />
		<out:variable name="id" select="generate-id(.)"/>
		<out:variable name="pos"
			select="count( preceding::* ) + count( ancestor-or-self::* )"/>

		<xsl:text>&#xA;</xsl:text>
		<xsl:comment>*COMMENT START MARKERS*</xsl:comment>

		<!--if it's a naughty node, insert a comment start marker here-->
		<!--comment start marker(s)-->
		<out:apply-templates select="$message" mode='start-comment'>
			<out:with-param name='pos' select='$pos'/>
		</out:apply-templates>

		<w:r>
			<out:apply-templates select="*"/>
		</w:r>

		<xsl:text>&#xA;</xsl:text>
		<xsl:comment>*COMMENT END MARKERS*</xsl:comment>

		<!--comment end marker(s)-->
		<out:apply-templates select="$message" mode='end-comment'>
			<out:with-param name='pos' select='$pos'/>
		</out:apply-templates>

		<xsl:text>&#xA;</xsl:text>
		<xsl:comment>*COMMENT CONTENT*</xsl:comment>

		<!--now the actual comment content-->
		<out:apply-templates select="$message" mode="comment-text">
			<out:with-param name="id" select="$pos"/>
		</out:apply-templates>
	</out:template>	
	
	<out:template match="svrl:text" mode="start-comment">
		<out:param name="pos"/>
		<out:call-template name="annotation">
			<out:with-param name="att-name" select="'Word.Comment.Start'"/>
			<out:with-param name="att-value" select="$pos"/>
		</out:call-template>
	</out:template>
	
	<out:template match="svrl:text" mode="end-comment">
		<out:param name="pos"/>
		<out:call-template name="annotation">
			<out:with-param name="att-name" select="'Word.Comment.End'"/>
			<out:with-param name="att-value" select="$pos"/>
		</out:call-template>
	</out:template>
	
	<out:template match='svrl:text' mode='comment-text'>
		<out:param name='id'/>
		<w:r>
			<w:rPr>
				<w:rStyle w:val="CommentReference"/>
			</w:rPr>
			<aml:annotation aml:author='QA' w:type='Word.Comment' w:initials='QA'>
				<out:attribute name="aml:id" select='$id'/>
				<out:attribute name="aml:createdate" select='$timestamp'/>
				<aml:content>
					<w:p>
						<w:pPr><w:pStyle w:val='CommentText'/></w:pPr>
						<w:r>
							<w:rPr><w:rStyle w:val='CommentReference'/></w:rPr>
							<w:annotationRef/>
						</w:r>
						<w:r>
							<w:t>
								<out:value-of select='.'/>
							</w:t>
						</w:r>
					</w:p>
				</aml:content>
			</aml:annotation>
		</w:r>	
	</out:template>
	
	<out:template name="annotation">
		<out:param name='att-name'/>
		<out:param name='att-value'/>
		<aml:annotation>
			<out:attribute name="w:type">
				<out:value-of select='$att-name'/>
			</out:attribute>		
			<out:attribute name="aml:id">
				<out:value-of select='$att-value'/>
			</out:attribute>
		</aml:annotation>		
	</out:template>
	
	<!--Word PIs-->
	<out:template match='processing-instruction("mso-application")'>
		<out:copy-of select='.'/>
	</out:template>
	
	</out:stylesheet>	
	
</xsl:template>
	
	<xsl:template match="svrl:failed-assert | svrl:successful-report">
		<xsl:param name="messages" />
		<out:template>
			<xsl:attribute name="match">
				<xsl:apply-templates select="@location"/>
			</xsl:attribute>
			<out:apply-templates select="." mode="annotate">
				<out:with-param name='message'><xsl:sequence select="$messages"/></out:with-param>
			</out:apply-templates>
		</out:template>
	</xsl:template>
	
	<!-- the Steps in XPaths we use to generate key matches need to be QNames,
	whereas those reported by the ISO Schematron XSLT implementation are in the form
	*:p[namespace-uri()='...']. 
	This template removes the namespace predicate and inserts the correct prefix. -->
	<xsl:template match="svrl:failed-assert/@location | svrl:successful-report/@location" as="xs:string">
		<xsl:variable name="norm">
			<xsl:for-each select="tokenize(., '/\*:')[position() > 1]">	<!-- split by '/*:' -->
				<xsl:text>/</xsl:text>
				<xsl:variable name="tokens" select="tokenize(., '\[')"/>
				<xsl:variable name="ns-uri" select="substring-before( substring-after($tokens[2], &quot;namespace-uri()='&quot;), &quot;'&quot;)"/>
				<xsl:choose>
					<xsl:when test="$ns-uri = 'http://schemas.microsoft.com/office/word/2003/wordml'">w:</xsl:when>
					<xsl:when test="$ns-uri = 'http://schemas.microsoft.com/office/word/2003/auxHint'">wx:</xsl:when>
					<xsl:when test="$ns-uri = 'urn:schemas-microsoft-com:vml'">v:</xsl:when>
					<xsl:when test="$ns-uri = 'urn:schemas-microsoft-com:office:word'">w10:</xsl:when>
					<xsl:when test="$ns-uri = 'http://schemas.microsoft.com/schemaLibrary/2003/core'">sl:</xsl:when>
					<xsl:when test="$ns-uri = 'http://schemas.microsoft.com/aml/2001/core'">aml:</xsl:when>
					<xsl:when test="$ns-uri = 'urn:schemas-microsoft-com:office:office'">o:</xsl:when>
					<xsl:when test="$ns-uri = 'uuid:C2F41010-65B3-11d1-A29F-00AA00C14882'">dt:</xsl:when>
					<!-- N.B. others may be required! -->
					<xsl:otherwise><xsl:message>unrecognised namespace: <xsl:value-of select="$ns-uri"/></xsl:message></xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="$tokens[1]"/>[<xsl:value-of select="$tokens[3]"/>	
			</xsl:for-each>
		</xsl:variable>
		<xsl:sequence select="$norm"/>
	</xsl:template>
	
</xsl:stylesheet>