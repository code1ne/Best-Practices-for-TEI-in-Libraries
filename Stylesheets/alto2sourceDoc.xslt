<?xml version="1.0" encoding="UTF-8"?>
<!-- script for converting alto files to TEI <sourceDoc> (<surface type="page"> fragment) - by Th. Stäcker (thomas.staecker@ulb.tu-darmstadt.de; University Library of  Darmstadt, 2018-01-13).  
   This script is meant to be a proof of principle and doesn't cover all elements of the alto standard. It converts a page (OCRed file) only. For many pages a suitable wrapper has to be put in place. 
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:alto="http://www.loc.gov/standards/alto/ns-v2#"
    xmlns:altoPrev="http://schema.ccs-gmbh.com/ALTO"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all" version="2.0">

  
  <xsl:param name="facsBase" select="'http://www.example.org/project/pageImages/IMG%PN00%.jpg'"/>
  <xsl:param name="pageNum">
    <!-- We can put various hueristics in here to try to guess page # -->
    <xsl:variable name="infn" select="tokenize( base-uri(/),'/')[last()]"/>
    <xsl:choose>
      <xsl:when test="matches( $infn, '^\d+')">
        <xsl:value-of select="replace( $infn, '^(\d+).*','$1')"/>
      </xsl:when>
      <xsl:when test="matches( $infn, '\d+\.xml$')">
        <xsl:value-of select="replace( $infn, '(\d+\)\.xml$','$1')"/>
      </xsl:when>
      <xsl:otherwise>9999</xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:output encoding="UTF-8" method="xml"/>

    <xsl:template match="/alto:alto">
      <sourceDoc source="{base-uri(/)}">
        <xsl:apply-templates select="alto:Layout"/>
      </sourceDoc>
    </xsl:template>

    <xsl:template match="alto:Layout">
        <!--
          <tei:surface> takes on the <alto:Page> element and contains the absolute coordinates of
          the image in pixel (this should be described in the teiHeader). As a rule they should be
          taken from the master image (highest available resolution)
        -->
        <surface xml:id="{alto:Page/@ID}" type="page">
            <!--
              The image source is not included in this alto file and supplemented here manually
              for the sake of reproducibility; add (#page=1 etc.) -->
            <xsl:attribute name="facs"
                >https://quod.lib.umich.edu/cache/h/i/s/hiss1111.0127.005/00000001.tif.1.pdf</xsl:attribute>
            <xsl:attribute name="ulx">0</xsl:attribute>
            <xsl:attribute name="uly">0</xsl:attribute>
            <xsl:attribute name="lrx">
                <xsl:value-of select="alto:Page/@WIDTH"/>
            </xsl:attribute>
            <xsl:attribute name="lry">
                <xsl:value-of select="alto:Page/@HEIGHT"/>
            </xsl:attribute>
            <!-- Printspace -->
            <zone>
                <xsl:attribute name="type">
                    <xsl:text>print_space</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="ulx">
                    <xsl:value-of select="alto:Page/alto:PrintSpace/@HPOS"/>
                </xsl:attribute>
                <xsl:attribute name="uly">
                    <xsl:value-of select="alto:Page/alto:PrintSpace/@VPOS"/>
                </xsl:attribute>
                <xsl:attribute name="lrx">
                    <xsl:value-of
                        select="(alto:Page/alto:PrintSpace/@HPOS + alto:Page/alto:PrintSpace/@WIDTH)"
                    />
                </xsl:attribute>
                <xsl:attribute name="lry">
                    <xsl:value-of
                        select="(alto:Page/alto:PrintSpace/@VPOS + alto:Page/alto:PrintSpace/@HEIGHT)"
                    />
                </xsl:attribute>
                <xsl:apply-templates/>
            </zone>

        </surface>

    </xsl:template>

    <xsl:template match="alto:TextBlock">
        <zone>
            <xsl:attribute name="type">
                <xsl:text>text_block</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="ulx">
                <xsl:value-of select="@HPOS"/>
            </xsl:attribute>
            <xsl:attribute name="uly">
                <xsl:value-of select="@VPOS"/>
            </xsl:attribute>
            <xsl:attribute name="lrx">
                <xsl:value-of select="(@HPOS + @WIDTH)"/>
            </xsl:attribute>
            <xsl:attribute name="lry">
                <xsl:value-of select="(@VPOS + @HEIGHT)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </zone>
    </xsl:template>

    <xsl:template match="alto:TextLine">
        <line>
            <xsl:attribute name="type">
                <xsl:text>text_line</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="ulx">
                <xsl:value-of select="@HPOS"/>
            </xsl:attribute>
            <xsl:attribute name="uly">
                <xsl:value-of select="@VPOS"/>
            </xsl:attribute>
            <xsl:attribute name="lrx">
                <xsl:value-of select="(@HPOS + @WIDTH)"/>
            </xsl:attribute>
            <xsl:attribute name="lry">
                <xsl:value-of select="(@VPOS + @HEIGHT)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </line>
    </xsl:template>

    <xsl:template match="alto:String">
        <zone>
            <xsl:attribute name="type">
                <xsl:text>word</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="ulx">
                <xsl:value-of select="@HPOS"/>
            </xsl:attribute>
            <xsl:attribute name="uly">
                <xsl:value-of select="@VPOS"/>
            </xsl:attribute>
            <xsl:attribute name="lrx">
                <xsl:value-of select="(@HPOS + @WIDTH)"/>
            </xsl:attribute>
            <xsl:attribute name="lry">
                <xsl:value-of select="(@VPOS + @HEIGHT)"/>
            </xsl:attribute>
            <xsl:value-of select="@CONTENT"/>
            <xsl:apply-templates/>
        </zone>
    </xsl:template>

    <xsl:template match="alto:GraphicalElement | alto:Illustration">
        <zone>
            <xsl:attribute name="type">
                <xsl:text>graphical_element</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="ulx">
                <xsl:value-of select="@HPOS"/>
            </xsl:attribute>
            <xsl:attribute name="uly">
                <xsl:value-of select="@VPOS"/>
            </xsl:attribute>
            <xsl:attribute name="lrx">
                <xsl:value-of select="(@HPOS + @WIDTH)"/>
            </xsl:attribute>
            <xsl:attribute name="lry">
                <xsl:value-of select="(@VPOS + @HEIGHT)"/>
            </xsl:attribute>
            <xsl:value-of select="@CONTENT"/>
            <xsl:apply-templates/>
        </zone>

    </xsl:template>

</xsl:stylesheet>
