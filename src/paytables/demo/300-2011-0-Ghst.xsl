<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet version="1.0" exclude-result-prefixes="java" extension-element-prefixes="my-ext" xmlns:lxslt="http://xml.apache.org/xslt" xmlns:java="http://xml.apache.org/xslt/java" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:my-ext="ext1">
<xsl:import href="HTML-CCFR.xsl"/>
<xsl:output indent="no" method="xml" omit-xml-declaration="yes"/>
<xsl:template match="/">
<xsl:apply-templates select="*"/>
<xsl:apply-templates select="/output/root[position()=last()]" mode="last"/>
<br/>
</xsl:template>
<lxslt:component prefix="my-ext" functions="formatJson retrievePrizeTable retrievePatternWins">
<lxslt:script lang="javascript">
					
					var debugFeed = [];
					var debugFlag = false;
					
					// Format instant win JSON results.
					// @param jsonContext String JSON results to parse and display.
					// @param bingoColumns String of Bingo Symbols.
					function formatJson(jsonContext, translations, patternDef, convertedPrizeValues, bingoColumns, convertedPatternWins, patternNames)
					{
						var scenario = getScenario(jsonContext);
						var bingoSymbols = bingoColumns.split(",");
						var drawnNumbers = (scenario.split("|")[0]).split(",");
						var bingoCardData = (scenario.split("|")[1]).split(",");
						var prizePatterns = patternDef.split("|");
						var prizeValues = (convertedPrizeValues.substring(1)).split('|');
						var patternWins = (convertedPatternWins.substring(1)).split('|');
						var bingoPatterns = patternNames.split(",");
						
						
						registerDebugText("Pattern Wins Count: " + patternWins.length);
						for(var i = 0; i &lt; patternWins.length; ++i)
						{
							registerDebugText("Win[" + i + "]: " + patternWins[i]);
						
						}
						
						var r = [];
						
						// Output Bingo Patterns
						/////////////////////////////
						r.push('&lt;table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed;display:inline-block"&gt;');
						
							r.push('&lt;table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable" style="table-layout:fixed;display:inline-block"&gt;');
							r.push('&lt;tr&gt;&lt;td class="tablehead" colspan="' + bingoSymbols.length + '"&gt;');
							r.push(getTranslationByName("prizePatterns", translations));
							r.push('&lt;/td&gt;');
							r.push('&lt;/tr&gt;');
							
							for(var row = 0; row &lt; bingoSymbols.length; ++row)
							{
								r.push('&lt;tr class="tablebody" height="20"&gt;');
							}
							
							r.push('&lt;tr&gt;&lt;td class="tablehead" colspan="' + bingoSymbols.length + '"&gt;');
							r.push(getTranslationByName("winsPerPattern", translations));
							r.push('&lt;/td&gt;');
							r.push('&lt;/tr&gt;');
							
							r.push('&lt;/table&gt;');
						
							for(var pattern = 0; pattern &lt; prizePatterns.length; ++pattern)
							{
								r.push('&lt;table border="0" cellpadding="2" cellspacing="1" class="gameDetailsTable" style="table-layout:fixed;display:inline-block"&gt;');
								
								r.push('&lt;tr&gt;');
								r.push('&lt;td class="tablehead" colspan="' + bingoSymbols.length + '"&gt;');
								r.push(getTranslationByName(bingoPatterns[pattern], translations));
								r.push('&lt;/td&gt;');
								r.push('&lt;/tr&gt;');
								
								for(var row = 0; row &lt; bingoSymbols.length; ++row)
								{
									var rowSpots = prizePatterns[pattern].split(",")[row];
									r.push('&lt;tr height="20"&gt;');
									for(var spot = 0; spot &lt; bingoSymbols.length; ++spot)
									{
										r.push('&lt;td class="tablebody" width="20"&gt;');
										r.push(rowSpots[spot]);
										r.push('&lt;/td&gt;');
									}
									r.push('&lt;/tr&gt;');
								}
								
								r.push('&lt;tr&gt;');
								r.push('&lt;td class="tablehead bold" colspan="' + bingoSymbols.length + '"&gt;');
								r.push(patternWins[pattern]);
								r.push('&lt;/td&gt;');
								r.push('&lt;/tr&gt;');
								
								r.push('&lt;/table&gt;');
							}
						
						r.push('&lt;/table&gt;');

						// Output Bingo Card Data
						////////////////////////////
						r.push('&lt;table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed"&gt;');
						r.push('&lt;tr&gt;&lt;td class="tablehead" colspan="' + bingoSymbols.length + '"&gt;');
						r.push(getTranslationByName("bingoCardNumbers", translations));
						r.push('&lt;/td&gt;');
						r.push('&lt;/tr&gt;');
						
						r.push('&lt;tr&gt;');
						for(var i = 0; i &lt; bingoSymbols.length; ++i)
						{
							r.push('&lt;td class="tablehead"&gt;');
							r.push(bingoSymbols[i]);
							r.push('&lt;/td&gt;');
						}
						r.push('&lt;/tr&gt;');
						
						for(var x = 0; x &lt; bingoSymbols.length; ++x)
						{	
							r.push('&lt;tr&gt;');
							for(var y = 0; y &lt; bingoSymbols.length; ++y)
							{
								var data = bingoCardData[y * bingoSymbols.length + x];
								if(data == "FREE")
								{
									r.push('&lt;td class="tablebody bold"&gt;');
									r.push(getTranslationByName("freeSpace", translations));
								}
								else if(checkMatch(drawnNumbers, data))
								{
									r.push('&lt;td class="tablebody bold"&gt;');
									r.push(getTranslationByName("youMatched", translations) + ": " + data);
								}
								else
								{
									r.push('&lt;td class="tablebody"&gt;');
									r.push(data);
								}
								r.push('&lt;/td&gt;');								
							}
							r.push('&lt;/tr&gt;');
						}
						r.push('&lt;/table&gt;');
						
						// Output Drawn Numbers
						r.push('&lt;table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed"&gt;');
						r.push('&lt;tr&gt;&lt;td class="tablehead" width="100%"&gt;');
						r.push(getTranslationByName("drawnNumbers", translations));
						r.push('&lt;/td&gt;');
						r.push('&lt;/tr&gt;');
						
						for(var num = 0; num &lt; drawnNumbers.length; ++num)
						{
							r.push('&lt;tr&gt;');	
							r.push('&lt;td class="tablebody" width="100%"&gt;');
							r.push(drawnNumbers[num]);
							r.push('&lt;/td&gt;');
							r.push('&lt;/tr&gt;');	
						}				
							
						r.push('&lt;/table&gt;');
						
						////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						// !DEBUG OUTPUT TABLE
						if(debugFlag)
						{
							// DEBUG TABLE
							//////////////////////////////////////
							r.push('&lt;table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed"&gt;');
							for(var idx = 0; idx &lt; debugFeed.length; ++idx)
							{
								r.push('&lt;tr&gt;');
								r.push('&lt;td class="tablebody"&gt;');
								r.push(debugFeed[idx]);
								r.push('&lt;/td&gt;');
								r.push('&lt;/tr&gt;');
							}
							r.push('&lt;/table&gt;');
						}

						return r.join('');
					}
					
					// Input: Json document string containing 'scenario' at root level.
					// Output: Scenario value.
					function getScenario(jsonContext)
					{
						// Parse json and retrieve scenario string.
						var jsObj = JSON.parse(jsonContext);
						var scenario = jsObj.scenario;

						// Trim null from scenario string.
						scenario = scenario.replace(/\0/g, '');

						return scenario;
					}
					
					// Input: List of winning numbers and the number to check
					// Output: true is number is contained within winning numbers or false if not
					function checkMatch(winningNums, boardNum)
					{
						for(var i = 0; i &lt; winningNums.length; ++i)
						{
							if(winningNums[i] == boardNum)
							{
								return true;
							}
						}
						
						return false;
					}
					
					// Input: Json document string containing 'amount' at root level.
					// Output: Price Point value.
					function getPricePoint(jsonContext)
					{
						// Parse json and retrieve price point amount
						var jsObj = JSON.parse(jsonContext);
						var pricePoint = jsObj.amount;

						return pricePoint;
					}
					
					//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					// Input: A list of Price Points and the available Prize Structures for the game as well as the wagered price point
					// Output: A string of the specific prize structure for the wagered price point
					function retrievePrizeTable(pricePoints, prizeTables, wageredPricePoint)
					{
						var pricePointList = pricePoints.split(",");
						var prizeTableStrings = prizeTables.split("|");
						
						
						for(var i = 0; i &lt; pricePoints.length; ++i)
						{
							if(wageredPricePoint == pricePointList[i])
							{
								registerDebugText("Price Point " + pricePointList[i] + " table: " + prizeTableStrings[i]);
								return prizeTableStrings[i];
							}
						}
						
						return "";
					}
					
					////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					// Input: The scenario data in the Json Response, the pattern Prize Values, the pattern names and the pattern def
					// Output: A string of the specific pattern wins for the entire scenario
					function retrievePatternWins(jsonContext, prizeTable, patternNames, patternDef)
					{
						var scenario = getScenario(jsonContext);
						var drawnNumbers = (scenario.split("|")[0]).split(",");
						var bingoCardData = (scenario.split("|")[1]).split(",");
						var prizePatterns = patternDef.replace(/,/g,'').split("|");
						var patternList = patternNames.split(",");
						var prizeTableList = prizeTable.split(",");
						var linePatterns = ["XXXXX--------------------",
											"-----XXXXX---------------",
											"----------XXXXX----------",
											"---------------XXXXX-----",
											"--------------------XXXXX",
											"X----X----X----X----X----",
											"-X----X----X----X----X---",
											"--X----X----X----X----X--",
											"---X----X----X----X----X-",
											"----X----X----X----X----X",
											"X-----X-----X-----X-----X",
											"----X---X---X---X---X----"];
											
						var patternWinsString = "";			
						for (var i = 0; i &lt; patternList.length; ++i)
						{
							if(i != 0)
							{
								patternWinsString += ",";
							}
							// BlackOut,Z,X,4Corners,Line
							switch(patternList[i])
							{
								case "BlackOut":
								case "Z":
								case "X":
								case "4Corners":
									if(checkForExclusivePattern(drawnNumbers, bingoCardData, prizePatterns[i]))
									{
										patternWinsString += prizeTableList[i];
									}
									else
									{
										patternWinsString += "0";
									}
									break;
								case "Line":
									var linesAwarded = checkForLinesPattern(drawnNumbers, bingoCardData, linePatterns);
									
									if(linesAwarded != 0)
									{
										patternWinsString += (prizeTableList[i] * linesAwarded);
									}
									else
									{
										patternWinsString += "0";
									}
									break;
							}
							registerDebugText("Wins Awarded: " + patternWinsString);
						}
						
						return patternWinsString;
					}
					
					function checkForExclusivePattern(drawnNumbers, bingoCardData, prizePattern)
					{
						for(var cell = 0; cell &lt; prizePattern.length; ++cell)
						{
							if(prizePattern[cell] == "X")
							{
								var singleMatch = false;
								for(var drawn = 0; drawn &lt; drawnNumbers.length; ++drawn)
								{
									if(bingoCardData[cell] == "FREE" || drawnNumbers[drawn] == bingoCardData[cell])
									{
										singleMatch = true;
										break;
									}
								}
								if(!singleMatch)
									return false;
							}
						}
						
						return true;
					}
					
					function checkForLinesPattern(drawnNumbers, bingoCardData, linePatterns)
					{
						var linesAwarded = 0;
						for(var line = 0; line &lt; linePatterns.length; ++line)
						{
							if(checkForExclusivePattern(drawnNumbers, bingoCardData, linePatterns[line]))
							{
								linesAwarded++;
								registerDebugText("Line Pattern Awarded(" + linesAwarded + "): " + linePatterns[line]);
							}
						}
						
						registerDebugText(linesAwarded);
						
						return linesAwarded;
					}
					
					////////////////////////////////////////////////////////////////////////////////////////
					function registerDebugText(debugText)
					{
						debugFeed.push(debugText);
					}
					
					/////////////////////////////////////////////////////////////////////////////////////////
					function getTranslationByName(keyName, translationNodeSet)
					{
						var index = 1;
						while(index &lt; translationNodeSet.item(0).getChildNodes().getLength())
						{
							var childNode = translationNodeSet.item(0).getChildNodes().item(index);
							
							if(childNode.getAttribute("key") == keyName)
							{
								return childNode.getAttribute("value");
							}
							
							index += 2;
						}
					}
					
					
				</lxslt:script>
</lxslt:component>
<xsl:template match="root" mode="last">
<table border="0" cellpadding="1" cellspacing="1" width="100%" class="gameDetailsTable">
<tr>
<td valign="top" class="subheader">
<xsl:value-of select="//translation/phrase[@key='totalWager']/@value"/>
<xsl:value-of select="': '"/>
<xsl:call-template name="Utils.ApplyConversionByLocale">
<xsl:with-param name="multi" select="/output/denom/percredit"/>
<xsl:with-param name="value" select="//ResultData/WagerOutcome[@name='Game.Total']/@amount"/>
<xsl:with-param name="code" select="/output/denom/currencycode"/>
<xsl:with-param name="locale" select="//translation/@language"/>
</xsl:call-template>
</td>
</tr>
<tr>
<td valign="top" class="subheader">
<xsl:value-of select="//translation/phrase[@key='totalWins']/@value"/>
<xsl:value-of select="': '"/>
<xsl:call-template name="Utils.ApplyConversionByLocale">
<xsl:with-param name="multi" select="/output/denom/percredit"/>
<xsl:with-param name="value" select="SignedData/Data/Outcome/OutcomeDetail/Payout"/>
<xsl:with-param name="code" select="/output/denom/currencycode"/>
<xsl:with-param name="locale" select="//translation/@language"/>
</xsl:call-template>
</td>
</tr>
</table>
</xsl:template>
<xsl:template match="//Outcome">
<xsl:if test="OutcomeDetail/Stage = 'Scenario'">
<xsl:call-template name="Scenario.Detail"/>
</xsl:if>
</xsl:template>
<xsl:template name="Scenario.Detail">
<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gameDetailsTable">
<tr>
<td class="tablebold" background="">
<xsl:value-of select="//translation/phrase[@key='transactionId']/@value"/>
<xsl:value-of select="': '"/>
<xsl:value-of select="OutcomeDetail/RngTxnId"/>
</td>
</tr>
</table>
<xsl:variable name="odeResponseJson" select="string(//ResultData/JSONOutcome[@name='ODEResponse']/text())"/>
<xsl:variable name="translations" select="lxslt:nodeset(//translation)"/>
<xsl:variable name="wageredPricePoint" select="string(//ResultData/WagerOutcome[@name='Game.Total']/@amount)"/>
<xsl:variable name="bingoColumns">B,I,N,G,O</xsl:variable>
<xsl:variable name="patternNames">BlackOut,Z,X,4Corners,Line</xsl:variable>
<xsl:variable name="patternDef">XXXXX,XXXXX,XXXXX,XXXXX,XXXXX,XXXXX|XXXXX,---X-,--X--,-X---,XXXXX|X---X,-X-X-,--X--,-X-X-,X---X|X---X,-----,-----,-----,X---X|-----,XXXXX,-----,-----,-----</xsl:variable>
<xsl:variable name="pricePoints">200,300,500</xsl:variable>
<xsl:variable name="prizeValuesAllPricePoints">1000000,5000,2500,500,200|2500000,10000,5000,1000,300|5000000,25000,10000,2500,500</xsl:variable>
<xsl:variable name="prizeTable">
<xsl:value-of select="my-ext:retrievePrizeTable($pricePoints, $prizeValuesAllPricePoints, $wageredPricePoint)"/>
</xsl:variable>
<xsl:variable name="patternWins">
<xsl:value-of select="my-ext:retrievePatternWins($odeResponseJson, $prizeTable, $patternNames, $patternDef)"/>
</xsl:variable>
<xsl:variable name="convertedPrizeValues">
<xsl:call-template name="split">
<xsl:with-param name="pText" select="string($prizeTable)"/>
</xsl:call-template>
</xsl:variable>
<xsl:variable name="convertedPatternWins">
<xsl:call-template name="split">
<xsl:with-param name="pText" select="string($patternWins)"/>
</xsl:call-template>
</xsl:variable>
<xsl:value-of select="my-ext:formatJson($odeResponseJson, $translations, $patternDef, string($convertedPrizeValues), $bingoColumns, string($convertedPatternWins), $patternNames)" disable-output-escaping="yes"/>
</xsl:template>
<xsl:template name="split">
<xsl:param name="pText"/>
<xsl:if test="string-length($pText)">
<xsl:text>|</xsl:text>
<xsl:call-template name="Utils.ApplyConversionByLocale">
<xsl:with-param name="multi" select="/output/denom/percredit"/>
<xsl:with-param name="value" select="substring-before(concat($pText,','),',')"/>
<xsl:with-param name="code" select="/output/denom/currencycode"/>
<xsl:with-param name="locale" select="//translation/@language"/>
</xsl:call-template>
<xsl:call-template name="split">
<xsl:with-param name="pText" select="substring-after($pText,',')"/>
</xsl:call-template>
</xsl:if>
</xsl:template>
<xsl:template match="text()"/>
</xsl:stylesheet>
